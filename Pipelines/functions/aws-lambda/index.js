// AWS Lambda Function with comprehensive features
// Demonstrates best practices for production serverless functions

const AWS = require('aws-sdk');
const AWSXRay = require('aws-xray-sdk-core');
const { Logger } = require('@aws-lambda-powertools/logger');
const { Metrics } = require('@aws-lambda-powertools/metrics');
const { Tracer } = require('@aws-lambda-powertools/tracer');
const middy = require('@middy/core');
const httpJsonBodyParser = require('@middy/http-json-body-parser');
const httpErrorHandler = require('@middy/http-error-handler');
const validator = require('@middy/validator');
const warmup = require('@middy/warmup');
const ssm = require('@middy/ssm');
const secretsManager = require('@middy/secrets-manager');
const cors = require('@middy/http-cors');
const httpHeaderNormalizer = require('@middy/http-header-normalizer');
const httpResponseSerializer = require('@middy/http-response-serializer');

// Initialize AWS SDK with X-Ray tracing
const aws = AWSXRay.captureAWS(AWS);

// Initialize AWS Lambda Powertools
const logger = new Logger({
    serviceName: process.env.SERVICE_NAME || 'serverless-api',
    logLevel: process.env.LOG_LEVEL || 'INFO',
});

const metrics = new Metrics({
    namespace: process.env.METRICS_NAMESPACE || 'ServerlessApp',
    serviceName: process.env.SERVICE_NAME || 'serverless-api',
});

const tracer = new Tracer({
    serviceName: process.env.SERVICE_NAME || 'serverless-api',
});

// Initialize AWS services
const dynamodb = new aws.DynamoDB.DocumentClient({
    region: process.env.AWS_REGION,
    maxRetries: 3,
    httpOptions: {
        timeout: 5000,
        connectTimeout: 5000,
    },
});

const s3 = new aws.S3({
    region: process.env.AWS_REGION,
    signatureVersion: 'v4',
});

const sqs = new aws.SQS({
    region: process.env.AWS_REGION,
});

const sns = new aws.SNS({
    region: process.env.AWS_REGION,
});

const eventBridge = new aws.EventBridge({
    region: process.env.AWS_REGION,
});

const comprehend = new aws.Comprehend({
    region: process.env.AWS_REGION,
});

// Constants
const TABLE_NAME = process.env.DYNAMODB_TABLE || 'serverless-items';
const BUCKET_NAME = process.env.S3_BUCKET || 'serverless-storage';
const QUEUE_URL = process.env.SQS_QUEUE_URL;
const TOPIC_ARN = process.env.SNS_TOPIC_ARN;
const EVENT_BUS_NAME = process.env.EVENT_BUS_NAME || 'default';

// Input validation schemas
const inputSchema = {
    type: 'object',
    properties: {
        body: {
            type: 'object',
            properties: {
                id: { type: 'string', pattern: '^[a-zA-Z0-9-]+$' },
                category: { type: 'string', enum: ['product', 'user', 'order'] },
                data: { type: 'object' },
                tags: { type: 'array', items: { type: 'string' } },
            },
            required: ['category', 'data'],
        },
        pathParameters: {
            type: 'object',
            properties: {
                id: { type: 'string' },
            },
        },
        queryStringParameters: {
            type: 'object',
            properties: {
                limit: { type: 'string', pattern: '^[0-9]+$' },
                offset: { type: 'string', pattern: '^[0-9]+$' },
                filter: { type: 'string' },
            },
        },
    },
};

// Helper functions
const generateId = () => {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

const sanitizeInput = (input) => {
    // Remove any potential XSS or injection attempts
    if (typeof input === 'string') {
        return input.replace(/[<>]/g, '');
    }
    return input;
};

const checkRateLimit = async (clientId) => {
    const key = `rate-limit:${clientId}`;
    const window = 60; // 60 seconds
    const limit = 100; // 100 requests per minute
    
    // Implement token bucket algorithm
    // This is a simplified example - use Redis or DynamoDB for production
    return true;
};

const detectPII = async (text) => {
    try {
        const params = {
            Text: text,
            LanguageCode: 'en',
        };
        
        const result = await comprehend.detectPiiEntities(params).promise();
        return result.Entities.length > 0;
    } catch (error) {
        logger.error('PII detection failed', { error });
        return false;
    }
};

// Business logic functions
const createItem = async (category, data, userId) => {
    const segment = tracer.getSegment();
    const subsegment = segment.addNewSubsegment('createItem');
    
    try {
        const itemId = generateId();
        const timestamp = new Date().toISOString();
        
        // Check for PII in data
        const dataString = JSON.stringify(data);
        if (await detectPII(dataString)) {
            throw new Error('Potential PII detected in input data');
        }
        
        const item = {
            id: itemId,
            category,
            data: sanitizeInput(data),
            userId,
            createdAt: timestamp,
            updatedAt: timestamp,
            version: 1,
            ttl: Math.floor(Date.now() / 1000) + 86400 * 30, // 30 days TTL
        };
        
        // Store in DynamoDB with condition check
        await dynamodb.put({
            TableName: TABLE_NAME,
            Item: item,
            ConditionExpression: 'attribute_not_exists(id)',
        }).promise();
        
        // Store backup in S3
        await s3.putObject({
            Bucket: BUCKET_NAME,
            Key: `items/${category}/${itemId}.json`,
            Body: JSON.stringify(item),
            ServerSideEncryption: 'AES256',
            Metadata: {
                category,
                userId,
                timestamp,
            },
        }).promise();
        
        // Send to SQS for async processing
        if (QUEUE_URL) {
            await sqs.sendMessage({
                QueueUrl: QUEUE_URL,
                MessageBody: JSON.stringify({
                    action: 'item_created',
                    item,
                }),
                MessageAttributes: {
                    category: {
                        DataType: 'String',
                        StringValue: category,
                    },
                },
            }).promise();
        }
        
        // Publish event to EventBridge
        await eventBridge.putEvents({
            Entries: [{
                Source: 'serverless.api',
                DetailType: 'ItemCreated',
                Detail: JSON.stringify({
                    itemId,
                    category,
                    userId,
                }),
                EventBusName: EVENT_BUS_NAME,
            }],
        }).promise();
        
        // Emit custom metrics
        metrics.addMetric('ItemCreated', 'Count', 1);
        metrics.addMetadata('category', category);
        
        subsegment.close();
        return item;
    } catch (error) {
        subsegment.addError(error);
        subsegment.close();
        throw error;
    }
};

const getItem = async (itemId, category) => {
    const segment = tracer.getSegment();
    const subsegment = segment.addNewSubsegment('getItem');
    
    try {
        // Try to get from DynamoDB
        const result = await dynamodb.get({
            TableName: TABLE_NAME,
            Key: { id: itemId },
            ConsistentRead: false,
        }).promise();
        
        if (!result.Item) {
            // Try to recover from S3
            try {
                const s3Result = await s3.getObject({
                    Bucket: BUCKET_NAME,
                    Key: `items/${category}/${itemId}.json`,
                }).promise();
                
                const item = JSON.parse(s3Result.Body.toString());
                
                // Restore to DynamoDB
                await dynamodb.put({
                    TableName: TABLE_NAME,
                    Item: item,
                }).promise();
                
                subsegment.close();
                return item;
            } catch (s3Error) {
                logger.warn('Item not found in S3 backup', { itemId, error: s3Error });
                subsegment.close();
                return null;
            }
        }
        
        metrics.addMetric('ItemRetrieved', 'Count', 1);
        subsegment.close();
        return result.Item;
    } catch (error) {
        subsegment.addError(error);
        subsegment.close();
        throw error;
    }
};

const listItems = async (category, limit = 20, offset = 0, filter = {}) => {
    const segment = tracer.getSegment();
    const subsegment = segment.addNewSubsegment('listItems');
    
    try {
        const params = {
            TableName: TABLE_NAME,
            IndexName: 'category-index',
            KeyConditionExpression: 'category = :category',
            ExpressionAttributeValues: {
                ':category': category,
            },
            Limit: Math.min(limit, 100), // Max 100 items
            ExclusiveStartKey: offset ? { id: offset } : undefined,
            ScanIndexForward: false, // Most recent first
        };
        
        // Add filter conditions if provided
        if (filter.startDate) {
            params.FilterExpression = 'createdAt >= :startDate';
            params.ExpressionAttributeValues[':startDate'] = filter.startDate;
        }
        
        const result = await dynamodb.query(params).promise();
        
        metrics.addMetric('ItemsListed', 'Count', result.Items.length);
        subsegment.close();
        
        return {
            items: result.Items,
            nextOffset: result.LastEvaluatedKey?.id,
            count: result.Count,
        };
    } catch (error) {
        subsegment.addError(error);
        subsegment.close();
        throw error;
    }
};

const updateItem = async (itemId, updates, userId) => {
    const segment = tracer.getSegment();
    const subsegment = segment.addNewSubsegment('updateItem');
    
    try {
        const timestamp = new Date().toISOString();
        
        // Build update expression
        const updateExpression = [];
        const expressionAttributeNames = {};
        const expressionAttributeValues = {
            ':updatedAt': timestamp,
            ':updatedBy': userId,
            ':increment': 1,
        };
        
        Object.keys(updates).forEach((key) => {
            const placeholder = `:${key}`;
            updateExpression.push(`#${key} = ${placeholder}`);
            expressionAttributeNames[`#${key}`] = key;
            expressionAttributeValues[placeholder] = sanitizeInput(updates[key]);
        });
        
        updateExpression.push('updatedAt = :updatedAt');
        updateExpression.push('updatedBy = :updatedBy');
        updateExpression.push('version = version + :increment');
        
        const result = await dynamodb.update({
            TableName: TABLE_NAME,
            Key: { id: itemId },
            UpdateExpression: `SET ${updateExpression.join(', ')}`,
            ExpressionAttributeNames: expressionAttributeNames,
            ExpressionAttributeValues: expressionAttributeValues,
            ConditionExpression: 'attribute_exists(id)',
            ReturnValues: 'ALL_NEW',
        }).promise();
        
        // Update S3 backup
        await s3.putObject({
            Bucket: BUCKET_NAME,
            Key: `items/${result.Attributes.category}/${itemId}.json`,
            Body: JSON.stringify(result.Attributes),
            ServerSideEncryption: 'AES256',
        }).promise();
        
        // Publish update event
        await eventBridge.putEvents({
            Entries: [{
                Source: 'serverless.api',
                DetailType: 'ItemUpdated',
                Detail: JSON.stringify({
                    itemId,
                    userId,
                    changes: Object.keys(updates),
                }),
                EventBusName: EVENT_BUS_NAME,
            }],
        }).promise();
        
        metrics.addMetric('ItemUpdated', 'Count', 1);
        subsegment.close();
        
        return result.Attributes;
    } catch (error) {
        subsegment.addError(error);
        subsegment.close();
        throw error;
    }
};

const deleteItem = async (itemId, userId) => {
    const segment = tracer.getSegment();
    const subsegment = segment.addNewSubsegment('deleteItem');
    
    try {
        // Get item before deletion for audit
        const item = await getItem(itemId);
        
        if (!item) {
            subsegment.close();
            return null;
        }
        
        // Soft delete - move to archive
        const archiveItem = {
            ...item,
            deletedAt: new Date().toISOString(),
            deletedBy: userId,
        };
        
        // Archive in S3
        await s3.putObject({
            Bucket: BUCKET_NAME,
            Key: `archive/${item.category}/${itemId}.json`,
            Body: JSON.stringify(archiveItem),
            ServerSideEncryption: 'AES256',
            StorageClass: 'GLACIER',
        }).promise();
        
        // Delete from DynamoDB
        await dynamodb.delete({
            TableName: TABLE_NAME,
            Key: { id: itemId },
            ConditionExpression: 'attribute_exists(id)',
        }).promise();
        
        // Delete from S3 active storage
        await s3.deleteObject({
            Bucket: BUCKET_NAME,
            Key: `items/${item.category}/${itemId}.json`,
        }).promise();
        
        // Publish deletion event
        await eventBridge.putEvents({
            Entries: [{
                Source: 'serverless.api',
                DetailType: 'ItemDeleted',
                Detail: JSON.stringify({
                    itemId,
                    category: item.category,
                    userId,
                }),
                EventBusName: EVENT_BUS_NAME,
            }],
        }).promise();
        
        // Send notification
        if (TOPIC_ARN) {
            await sns.publish({
                TopicArn: TOPIC_ARN,
                Subject: 'Item Deleted',
                Message: JSON.stringify({
                    itemId,
                    category: item.category,
                    deletedBy: userId,
                    timestamp: archiveItem.deletedAt,
                }),
                MessageAttributes: {
                    eventType: {
                        DataType: 'String',
                        StringValue: 'deletion',
                    },
                },
            }).promise();
        }
        
        metrics.addMetric('ItemDeleted', 'Count', 1);
        subsegment.close();
        
        return archiveItem;
    } catch (error) {
        subsegment.addError(error);
        subsegment.close();
        throw error;
    }
};

// Main Lambda handler
const baseHandler = async (event, context) => {
    // Add request ID to logs
    logger.appendKeys({
        requestId: context.requestId,
        functionName: context.functionName,
        functionVersion: context.functionVersion,
    });
    
    logger.info('Processing request', { event });
    
    try {
        // Check for warmup
        if (event.source === 'serverless-plugin-warmup') {
            logger.info('Warmup request received');
            return { statusCode: 200, body: 'Function warmed up' };
        }
        
        // Extract user information from authorizer
        const userId = event.requestContext?.authorizer?.principalId || 'anonymous';
        const clientId = event.requestContext?.identity?.sourceIp || 'unknown';
        
        // Rate limiting
        if (!await checkRateLimit(clientId)) {
            metrics.addMetric('RateLimitExceeded', 'Count', 1);
            return {
                statusCode: 429,
                body: JSON.stringify({
                    error: 'Too many requests',
                    retryAfter: 60,
                }),
                headers: {
                    'Retry-After': '60',
                    'X-RateLimit-Limit': '100',
                    'X-RateLimit-Remaining': '0',
                },
            };
        }
        
        // Route based on HTTP method and path
        const method = event.httpMethod || event.requestContext?.http?.method;
        const path = event.path || event.rawPath;
        const pathParams = event.pathParameters || {};
        const queryParams = event.queryStringParameters || {};
        const body = event.body ? JSON.parse(event.body) : {};
        
        let response;
        
        switch (method) {
            case 'POST':
                if (path.includes('/items')) {
                    const item = await createItem(body.category, body.data, userId);
                    response = {
                        statusCode: 201,
                        body: JSON.stringify(item),
                        headers: {
                            'Location': `/items/${item.id}`,
                        },
                    };
                }
                break;
                
            case 'GET':
                if (pathParams.id) {
                    const item = await getItem(pathParams.id, queryParams.category);
                    if (!item) {
                        response = {
                            statusCode: 404,
                            body: JSON.stringify({ error: 'Item not found' }),
                        };
                    } else {
                        response = {
                            statusCode: 200,
                            body: JSON.stringify(item),
                            headers: {
                                'Cache-Control': 'private, max-age=300',
                                'ETag': `"${item.version}"`,
                            },
                        };
                    }
                } else {
                    const result = await listItems(
                        queryParams.category || 'all',
                        parseInt(queryParams.limit) || 20,
                        queryParams.offset,
                        queryParams
                    );
                    response = {
                        statusCode: 200,
                        body: JSON.stringify(result),
                        headers: {
                            'Cache-Control': 'private, max-age=60',
                        },
                    };
                }
                break;
                
            case 'PUT':
            case 'PATCH':
                if (pathParams.id) {
                    const updated = await updateItem(pathParams.id, body, userId);
                    response = {
                        statusCode: 200,
                        body: JSON.stringify(updated),
                    };
                }
                break;
                
            case 'DELETE':
                if (pathParams.id) {
                    const deleted = await deleteItem(pathParams.id, userId);
                    if (!deleted) {
                        response = {
                            statusCode: 404,
                            body: JSON.stringify({ error: 'Item not found' }),
                        };
                    } else {
                        response = {
                            statusCode: 204,
                            body: '',
                        };
                    }
                }
                break;
                
            default:
                response = {
                    statusCode: 405,
                    body: JSON.stringify({ error: 'Method not allowed' }),
                    headers: {
                        'Allow': 'GET, POST, PUT, PATCH, DELETE',
                    },
                };
        }
        
        // Add common headers
        response.headers = {
            ...response.headers,
            'X-Request-Id': context.requestId,
            'X-Correlation-Id': event.headers?.['X-Correlation-Id'] || context.requestId,
            'X-Response-Time': `${Date.now() - context.getRemainingTimeInMillis() + context.getRemainingTimeInMillis()}ms`,
        };
        
        // Log successful response
        logger.info('Request processed successfully', {
            statusCode: response.statusCode,
            method,
            path,
        });
        
        // Publish metrics
        metrics.addMetric('RequestProcessed', 'Count', 1);
        metrics.addMetadata('statusCode', response.statusCode.toString());
        metrics.addMetadata('method', method);
        
        return response;
        
    } catch (error) {
        logger.error('Request processing failed', { error });
        
        metrics.addMetric('RequestFailed', 'Count', 1);
        metrics.addMetadata('errorType', error.name);
        
        // Send error notification for critical errors
        if (error.name === 'ProvisionedThroughputExceededException') {
            await sns.publish({
                TopicArn: TOPIC_ARN,
                Subject: 'Critical Error: DynamoDB Throughput Exceeded',
                Message: JSON.stringify({
                    functionName: context.functionName,
                    error: error.message,
                    requestId: context.requestId,
                }),
            }).promise();
        }
        
        return {
            statusCode: error.statusCode || 500,
            body: JSON.stringify({
                error: error.message || 'Internal server error',
                requestId: context.requestId,
            }),
            headers: {
                'X-Request-Id': context.requestId,
            },
        };
    } finally {
        // Publish metrics
        metrics.publishStoredMetrics();
    }
};

// Apply middleware
const handler = middy(baseHandler)
    .use(httpHeaderNormalizer())
    .use(httpJsonBodyParser())
    .use(validator({ inputSchema }))
    .use(warmup())
    .use(ssm({
        fetchData: {
            dbConnectionString: `/${process.env.STAGE}/db/connection-string`,
            apiKey: `/${process.env.STAGE}/api/key`,
        },
        cache: true,
        cacheExpiry: 5 * 60 * 1000, // 5 minutes
    }))
    .use(secretsManager({
        fetchData: {
            authSecret: `${process.env.STAGE}/auth/secret`,
        },
        cache: true,
    }))
    .use(cors({
        origins: process.env.ALLOWED_ORIGINS?.split(',') || ['*'],
        credentials: true,
    }))
    .use(httpResponseSerializer({
        serializers: [
            {
                regex: /^application\/json$/,
                serializer: ({ body }) => JSON.stringify(body),
            },
            {
                regex: /^text\/plain$/,
                serializer: ({ body }) => body,
            },
        ],
        default: 'application/json',
    }))
    .use(httpErrorHandler())
    .use(tracer.captureLambdaHandler());

// Export handler
module.exports = { handler };

// Export individual functions for testing
module.exports.createItem = createItem;
module.exports.getItem = getItem;
module.exports.listItems = listItems;
module.exports.updateItem = updateItem;
module.exports.deleteItem = deleteItem;