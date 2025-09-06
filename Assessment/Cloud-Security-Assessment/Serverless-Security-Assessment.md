# Serverless Security Assessment

## Assessment Overview

This template provides a comprehensive framework for conducting security assessments of serverless and Function-as-a-Service (FaaS) environments, focusing on Azure Functions, AWS Lambda, Google Cloud Functions, and associated serverless services aligned with OWASP Serverless Top 10 and cloud security best practices.

### Assessment Scope
- **Target Environment**: Serverless functions, event sources, API gateways, storage triggers
- **Platform Coverage**: Azure Functions, AWS Lambda, Google Cloud Functions
- **Framework Alignment**: OWASP Serverless Top 10, NIST Cybersecurity Framework
- **Assessment Duration**: 1-3 weeks depending on function complexity and count
- **Required Access**: Function app contributor, Lambda execution role, Cloud Functions admin

### Key Assessment Areas
1. Function Identity and Access Management
2. Event Source Security and Injection Risks  
3. Insecure Secrets Management
4. Over-Privileged Function Permissions
5. Inadequate Function Monitoring and Logging
6. Insecure Application Dependencies
7. Configuration Security Issues
8. Business Logic Security Flaws

## Pre-Assessment Planning

### Serverless Environment Discovery

#### Azure Functions Discovery
```bash
# Azure Functions inventory
az functionapp list --query '[].{Name:name, ResourceGroup:resourceGroup, Location:location, Runtime:siteConfig.linuxFxVersion, HttpsOnly:httpsOnly, State:state}' -o table

# Function app configuration assessment
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "=== Function App: $funcapp ==="
    
    # Basic configuration
    az functionapp show --name $funcapp --query '{
        ResourceGroup: resourceGroup,
        RuntimeVersion: siteConfig.linuxFxVersion,
        HttpsOnly: httpsOnly,
        FtpsState: siteConfig.ftpsState,
        MinTlsVersion: siteConfig.minTlsVersion,
        Identity: identity,
        VnetIntegration: virtualNetworkSubnetId
    }' -o yaml
    
    # Application settings (potential secrets)
    echo "Application Settings:"
    az functionapp config appsettings list --name $funcapp --query '[].{Name:name, SlotSetting:slotSetting}' -o table | head -10
    
    # Network restrictions
    echo "Access Restrictions:"
    az functionapp config access-restriction list --name $funcapp --query '[].{Name:name, IpAddress:ipAddress, Action:action, Priority:priority}' -o table
    
    echo
done

# Azure Logic Apps (related serverless)
az logic workflow list --query '[].{Name:name, ResourceGroup:resourceGroup, State:state, Location:location}' -o table
```

#### AWS Lambda Discovery
```bash
# AWS Lambda functions inventory
aws lambda list-functions --query 'Functions[].{FunctionName:FunctionName, Runtime:Runtime, Handler:Handler, Role:Role, VpcConfig:VpcConfig.VpcId}' --output table

# Lambda function detailed assessment
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    echo "=== Lambda Function: $function ==="
    
    # Function configuration
    aws lambda get-function-configuration --function-name $function --query '{
        Runtime: Runtime,
        Handler: Handler,
        Role: Role,
        Environment: Environment,
        VpcConfig: VpcConfig,
        DeadLetterConfig: DeadLetterConfig,
        TracingConfig: TracingConfig,
        KMSKeyArn: KMSKeyArn
    }' --output yaml
    
    # Function policy
    aws lambda get-policy --function-name $function --query 'Policy' --output text 2>/dev/null || echo "No resource-based policy"
    
    # Event source mappings
    aws lambda list-event-source-mappings --function-name $function --query 'EventSourceMappings[].{EventSourceArn:EventSourceArn, State:State}' --output table
    
    echo
done

# API Gateway integration assessment
aws apigateway get-rest-apis --query 'items[].{Id:id, Name:name, CreatedDate:createdDate}' --output table

# Step Functions (serverless workflows)
aws stepfunctions list-state-machines --query 'stateMachines[].{Name:name, StateMachineArn:stateMachineArn, Status:status}' --output table
```

#### Google Cloud Functions Discovery
```bash
# Google Cloud Functions inventory
gcloud functions list --format="table(name,status,trigger.httpsTrigger.url,runtime,availableMemoryMb)" 2>/dev/null || echo "Cloud Functions access not available"

# Cloud Functions detailed assessment
gcloud functions list --format="value(name)" 2>/dev/null | while read function; do
    echo "=== Cloud Function: $function ==="
    
    # Function details
    gcloud functions describe $function --format="yaml(
        name,
        status,
        runtime,
        availableMemoryMb,
        timeout,
        serviceAccountEmail,
        environmentVariables,
        vpcConnector,
        ingressSettings
    )" 2>/dev/null || echo "Function details not accessible"
    
    # Function IAM policy
    gcloud functions get-iam-policy $function --format="yaml" 2>/dev/null || echo "IAM policy not accessible"
    
    echo
done

# Cloud Run services (container-based serverless)
gcloud run services list --format="table(metadata.name,status.url,spec.template.spec.serviceAccountName)" 2>/dev/null || echo "Cloud Run access not available"
```

### Event Source and Integration Discovery
```bash
# Azure Event Sources
echo "=== Azure Event Sources ==="

# Event Grid topics and subscriptions
az eventgrid topic list --query '[].{Name:name, ResourceGroup:resourceGroup, Endpoint:endpoint}' -o table
az eventgrid event-subscription list --query '[].{Name:name, Topic:topic, EndpointType:destination.endpointType}' -o table

# Service Bus queues and topics
az servicebus namespace list --query '[].{Name:name, ResourceGroup:resourceGroup, Status:status}' -o table
az servicebus queue list --namespace-name myNamespace --query '[].name' -o tsv 2>/dev/null || echo "Service Bus access required"

# Storage account triggers
az storage account list --query '[].name' -o tsv | while read account; do
    echo "Storage Account: $account"
    # This would require checking blob/queue triggers on functions
done

# AWS Event Sources
echo "=== AWS Event Sources ==="

# SQS queues
aws sqs list-queues --query 'QueueUrls' --output text | while read queue; do
    queue_name=$(basename $queue)
    echo "SQS Queue: $queue_name"
    aws sqs get-queue-attributes --queue-url $queue --attribute-names All --query 'Attributes.{Policy:Policy, VisibilityTimeoutSeconds:VisibilityTimeoutSeconds}' --output yaml 2>/dev/null || echo "  Access denied"
done

# SNS topics
aws sns list-topics --query 'Topics[].TopicArn' --output text | while read topic; do
    echo "SNS Topic: $(basename $topic)"
    aws sns get-topic-attributes --topic-arn $topic --query 'Attributes.Policy' --output text 2>/dev/null || echo "  Access denied"
done

# EventBridge rules
aws events list-rules --query 'Rules[].{Name:Name, State:State, EventPattern:EventPattern}' --output table

# GCP Event Sources
echo "=== GCP Event Sources ==="

# Pub/Sub topics
gcloud pubsub topics list --format="table(name)" 2>/dev/null || echo "Pub/Sub access not available"

# Cloud Scheduler jobs
gcloud scheduler jobs list --format="table(name,schedule,timeZone,state)" 2>/dev/null || echo "Cloud Scheduler access not available"
```

## OWASP Serverless Top 10 Assessment

### SAS-01: Function Event-Data Injection

#### Event Source Validation Assessment
```bash
# Azure Functions - Check for input validation
echo "=== Azure Functions Input Validation ==="
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "Function App: $funcapp"
    
    # Get function definitions (requires app service editor or deployment center access)
    # This would typically require examining the function code directly
    echo "  Manual code review required for input validation patterns"
    
    # Check for dangerous event sources
    az eventgrid event-subscription list --query '[?contains(destination.endpointUrl, `'$funcapp'`)].{Name:name, EndpointUrl:destination.endpointUrl, Filters:filter}' -o yaml
done

# AWS Lambda - Event source security
echo "=== AWS Lambda Event Source Security ==="
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    echo "Lambda Function: $function"
    
    # Check event source mappings for potential injection vectors
    aws lambda list-event-source-mappings --function-name $function --query 'EventSourceMappings[].{
        EventSourceArn: EventSourceArn,
        BatchSize: BatchSize,
        FilterCriteria: FilterCriteria
    }' --output yaml
    
    # Check for HTTP triggers via API Gateway
    aws apigateway get-rest-apis --query 'items[].id' --output text | while read api_id; do
        aws apigateway get-resources --rest-api-id $api_id --query 'items[?resourceMethods.POST || resourceMethods.PUT].{Path:path, Methods:resourceMethods}' --output table 2>/dev/null
    done
done
```

**Key Assessment Points**:
- [ ] Input validation implemented for all event sources
- [ ] Event payload size limits enforced
- [ ] Dangerous event sources (direct HTTP without API Gateway) avoided
- [ ] Event schema validation implemented
- [ ] SQL injection prevention in database queries

### SAS-02: Broken Authentication

#### Serverless Authentication Assessment
```bash
# Azure Functions authentication configuration
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "=== Function App: $funcapp ==="
    
    # Authentication/authorization configuration
    az functionapp auth show --name $funcapp --query '{
        Enabled: enabled,
        DefaultAction: unauthenticatedClientAction,
        Providers: identityProviders
    }' -o yaml 2>/dev/null || echo "No auth configuration or access denied"
    
    # Function-level authorization
    echo "Function Keys and Authorization:"
    az functionapp keys list --name $funcapp --query '{
        MasterKey: masterKey,
        FunctionKeys: functionKeys,
        SystemKeys: systemKeys
    }' -o yaml 2>/dev/null || echo "Unable to access function keys"
    
    # CORS configuration
    az functionapp cors show --name $funcapp --query 'allowedOrigins' -o yaml
done

# AWS Lambda authentication via API Gateway
aws apigateway get-rest-apis --query 'items[].id' --output text | while read api_id; do
    echo "=== API Gateway: $api_id ==="
    
    # Get authorizers
    aws apigateway get-authorizers --rest-api-id $api_id --query 'items[].{Name:name, Type:type, AuthorizerUri:authorizerUri}' --output table 2>/dev/null
    
    # Check method authorization
    aws apigateway get-resources --rest-api-id $api_id --query 'items[].id' --output text | while read resource_id; do
        for method in GET POST PUT DELETE; do
            aws apigateway get-method --rest-api-id $api_id --resource-id $resource_id --http-method $method --query 'authorizationType' --output text 2>/dev/null | grep -v None || continue
            echo "Resource $resource_id $method has authorization"
        done
    done 2>/dev/null
done
```

**Key Assessment Points**:
- [ ] Authentication required for sensitive functions
- [ ] Function keys properly managed and rotated
- [ ] API Gateway/Application Gateway authentication configured
- [ ] JWT token validation implemented where applicable
- [ ] CORS properly configured to prevent CSRF

### SAS-03: Insecure Serverless Deployment Configuration

#### Configuration Security Assessment
```bash
# Azure Functions configuration security
echo "=== Azure Functions Configuration Security ==="
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "Function App: $funcapp"
    
    # Security-related configuration
    config=$(az functionapp show --name $funcapp --query '{
        HttpsOnly: httpsOnly,
        MinTlsVersion: siteConfig.minTlsVersion,
        FtpsState: siteConfig.ftpsState,
        RemoteDebuggingEnabled: siteConfig.remoteDebuggingEnabled,
        DetailedErrorLoggingEnabled: siteConfig.detailedErrorLoggingEnabled,
        HttpLoggingEnabled: siteConfig.httpLoggingEnabled,
        Identity: identity.type,
        VnetIntegration: virtualNetworkSubnetId
    }' -o json)
    
    echo "$config" | jq .
    
    # Check for insecure configurations
    if echo "$config" | jq -r '.HttpsOnly' | grep -q false; then
        echo "⚠️  HTTPS not enforced"
    fi
    
    if echo "$config" | jq -r '.MinTlsVersion' | grep -v "1.2"; then
        echo "⚠️  TLS version below 1.2"
    fi
    
    if echo "$config" | jq -r '.RemoteDebuggingEnabled' | grep -q true; then
        echo "⚠️  Remote debugging enabled"
    fi
    
    echo
done

# AWS Lambda configuration security
echo "=== AWS Lambda Configuration Security ==="
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    echo "Lambda Function: $function"
    
    config=$(aws lambda get-function-configuration --function-name $function)
    
    # Check for insecure configurations
    runtime=$(echo "$config" | jq -r '.Runtime')
    if echo "$runtime" | grep -E "(python2|nodejs10|nodejs12|dotnetcore2)"; then
        echo "⚠️  Deprecated runtime version: $runtime"
    fi
    
    # Check environment variables for potential secrets
    env_vars=$(echo "$config" | jq -r '.Environment.Variables // {} | keys[]' 2>/dev/null)
    for var in $env_vars; do
        if echo "$var" | grep -iE "(password|secret|key|token|api)"; then
            echo "⚠️  Potential secret in environment variable: $var"
        fi
    done
    
    # Check for unencrypted environment variables
    kms_key=$(echo "$config" | jq -r '.KMSKeyArn // "none"')
    if [ "$kms_key" = "none" ] && [ -n "$env_vars" ]; then
        echo "⚠️  Environment variables not encrypted with KMS"
    fi
    
    echo
done
```

**Key Assessment Points**:
- [ ] HTTPS enforcement enabled
- [ ] Minimum TLS 1.2 configured
- [ ] Remote debugging disabled in production
- [ ] Runtime versions current and supported
- [ ] Environment variables encrypted with customer-managed keys

### SAS-04: Over-Privileged Function Permissions & Roles

#### Function Permissions Assessment
```bash
# Azure Functions managed identity and permissions
echo "=== Azure Function Identity and Permissions ==="
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "Function App: $funcapp"
    
    # Get managed identity information
    identity=$(az functionapp show --name $funcapp --query 'identity' -o json)
    echo "Identity Configuration:"
    echo "$identity" | jq .
    
    if echo "$identity" | jq -r '.type' | grep -q "SystemAssigned\|UserAssigned"; then
        # Get role assignments for the managed identity
        principal_id=$(echo "$identity" | jq -r '.principalId')
        if [ "$principal_id" != "null" ]; then
            echo "Role Assignments:"
            az role assignment list --assignee $principal_id --query '[].{Role:roleDefinitionName, Scope:scope}' -o table
            
            # Check for overprivileged roles
            az role assignment list --assignee $principal_id --query '[?contains(roleDefinitionName, `Owner`) || contains(roleDefinitionName, `Contributor`)].roleDefinitionName' -o tsv | while read role; do
                echo "⚠️  Overprivileged role assigned: $role"
            done
        fi
    fi
    
    echo
done

# AWS Lambda execution role assessment
echo "=== AWS Lambda Execution Roles ==="
aws lambda list-functions --query 'Functions[].{FunctionName:FunctionName, Role:Role}' --output text | while read function role; do
    echo "Lambda Function: $function"
    echo "Execution Role: $role"
    
    role_name=$(basename $role)
    
    # Get attached policies
    echo "Managed Policies:"
    aws iam list-attached-role-policies --role-name $role_name --query 'AttachedPolicies[].{PolicyName:PolicyName, PolicyArn:PolicyArn}' --output table 2>/dev/null || echo "Access denied to role policies"
    
    # Get inline policies
    echo "Inline Policies:"
    aws iam list-role-policies --role-name $role_name --query 'PolicyNames' --output text 2>/dev/null || echo "Access denied to inline policies"
    
    # Check for overprivileged policies
    aws iam list-attached-role-policies --role-name $role_name --query 'AttachedPolicies[?contains(PolicyArn, `AdministratorAccess`) || contains(PolicyArn, `PowerUserAccess`)].PolicyName' --output text 2>/dev/null | while read policy; do
        echo "⚠️  Overprivileged managed policy: $policy"
    done
    
    echo
done

# Google Cloud Functions service account permissions
echo "=== GCP Cloud Functions Service Accounts ==="
gcloud functions list --format="value(name)" 2>/dev/null | while read function; do
    echo "Cloud Function: $function"
    
    # Get service account
    service_account=$(gcloud functions describe $function --format="value(serviceAccountEmail)" 2>/dev/null)
    echo "Service Account: $service_account"
    
    if [ "$service_account" != "" ]; then
        # Get IAM policy bindings for the service account
        echo "IAM Roles:"
        gcloud projects get-iam-policy $(gcloud config get-value project) --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$service_account" 2>/dev/null || echo "Unable to retrieve IAM policies"
        
        # Check for overprivileged roles
        gcloud projects get-iam-policy $(gcloud config get-value project) --flatten="bindings[].members" --format="value(bindings.role)" --filter="bindings.members:$service_account" 2>/dev/null | grep -E "(Owner|Editor)" | while read role; do
            echo "⚠️  Overprivileged role: $role"
        done
    fi
    
    echo
done
```

**Key Assessment Points**:
- [ ] Principle of least privilege applied to function execution roles
- [ ] No overprivileged roles (Owner, Administrator) assigned
- [ ] Managed identities used instead of connection strings where possible
- [ ] Cross-account access properly secured with external ID
- [ ] Regular review and cleanup of unused permissions

### SAS-05: Inadequate Function Monitoring & Logging

#### Monitoring and Logging Assessment
```bash
# Azure Functions monitoring configuration
echo "=== Azure Functions Monitoring and Logging ==="
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "Function App: $funcapp"
    
    # Application Insights integration
    app_insights=$(az functionapp config appsettings list --name $funcapp --query '[?name==`APPINSIGHTS_INSTRUMENTATIONKEY`].value' -o tsv)
    if [ -n "$app_insights" ]; then
        echo "✅ Application Insights configured"
    else
        echo "⚠️  Application Insights not configured"
    fi
    
    # Diagnostic settings
    resource_id=$(az functionapp show --name $funcapp --query 'id' -o tsv)
    az monitor diagnostic-settings list --resource "$resource_id" --query '[].{Name:name, Logs:logs[].enabled, Metrics:metrics[].enabled}' -o table 2>/dev/null || echo "No diagnostic settings configured"
    
    # Log Analytics workspace connection
    workspace_id=$(az functionapp config appsettings list --name $funcapp --query '[?name==`WEBSITE_CONTENTAZUREFILECONNECTIONSTRING`].value' -o tsv)
    echo "Storage connection configured: $([ -n "$workspace_id" ] && echo "Yes" || echo "No")"
    
    echo
done

# AWS Lambda monitoring assessment
echo "=== AWS Lambda Monitoring and Logging ==="
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    echo "Lambda Function: $function"
    
    # CloudWatch Logs configuration
    log_group="/aws/lambda/$function"
    log_retention=$(aws logs describe-log-groups --log-group-name-prefix $log_group --query 'logGroups[0].retentionInDays' --output text 2>/dev/null)
    if [ "$log_retention" != "None" ]; then
        echo "Log retention: $log_retention days"
    else
        echo "⚠️  No log retention configured (logs kept indefinitely)"
    fi
    
    # X-Ray tracing configuration
    tracing=$(aws lambda get-function-configuration --function-name $function --query 'TracingConfig.Mode' --output text)
    if [ "$tracing" = "Active" ]; then
        echo "✅ X-Ray tracing enabled"
    else
        echo "⚠️  X-Ray tracing not enabled"
    fi
    
    # Dead letter queue configuration
    dlq=$(aws lambda get-function-configuration --function-name $function --query 'DeadLetterConfig.TargetArn' --output text)
    if [ "$dlq" != "None" ]; then
        echo "✅ Dead letter queue configured: $dlq"
    else
        echo "⚠️  No dead letter queue configured"
    fi
    
    # CloudWatch alarms for the function
    aws cloudwatch describe-alarms --alarm-name-prefix "$function" --query 'MetricAlarms[].{AlarmName:AlarmName, MetricName:MetricName, Threshold:Threshold}' --output table 2>/dev/null || echo "No CloudWatch alarms found"
    
    echo
done

# GCP Cloud Functions monitoring
echo "=== GCP Cloud Functions Monitoring ==="
gcloud functions list --format="value(name)" 2>/dev/null | while read function; do
    echo "Cloud Function: $function"
    
    # Check if Cloud Logging is enabled (default for Cloud Functions)
    echo "✅ Cloud Logging enabled by default"
    
    # Check for custom monitoring/alerting policies
    gcloud alpha monitoring policies list --filter="displayName:$function" --format="table(displayName,enabled)" 2>/dev/null || echo "No custom monitoring policies found"
    
    echo
done
```

**Key Assessment Points**:
- [ ] Comprehensive logging enabled for all functions
- [ ] Log retention policies configured appropriately
- [ ] Structured logging implemented for better analysis
- [ ] Application performance monitoring (APM) integrated
- [ ] Security monitoring and alerting configured
- [ ] Dead letter queues configured for async processing

### SAS-06: Insecure Third-Party Dependencies

#### Dependency Security Assessment
```bash
# Analyze function dependencies for vulnerabilities
echo "=== Dependency Security Assessment ==="

# For Azure Functions (requires access to function code)
echo "Azure Functions dependency analysis requires code repository access"
echo "Common vulnerability scanning commands:"
echo "  npm audit (Node.js)"
echo "  pip check / safety check (Python)"
echo "  dotnet list package --vulnerable (C#)"

# For AWS Lambda layers assessment
aws lambda list-layers --query 'Layers[].{LayerName:LayerName, LatestVersion:LatestMatchingVersion.Version}' --output table

# Check Lambda layers for functions
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    layers=$(aws lambda get-function-configuration --function-name $function --query 'Layers[].Arn' --output text)
    if [ -n "$layers" ]; then
        echo "Function $function uses layers: $layers"
    fi
done

# Sample dependency scanning script
cat << 'EOF' > /tmp/scan_dependencies.sh
#!/bin/bash
# Dependency vulnerability scanning script
# This would typically be run in the function's code directory

echo "=== Dependency Vulnerability Scan ==="

# Node.js projects
if [ -f "package.json" ]; then
    echo "Scanning Node.js dependencies..."
    npm audit --audit-level=moderate 2>/dev/null || echo "npm audit failed or not available"
    
    # Alternative with yarn
    if command -v yarn >/dev/null; then
        yarn audit --level moderate 2>/dev/null || echo "yarn audit failed"
    fi
fi

# Python projects
if [ -f "requirements.txt" ]; then
    echo "Scanning Python dependencies..."
    if command -v safety >/dev/null; then
        safety check -r requirements.txt
    elif command -v pip >/dev/null; then
        pip list --outdated
    fi
fi

# .NET projects
if [ -f "*.csproj" ] || [ -f "*.sln" ]; then
    echo "Scanning .NET dependencies..."
    dotnet list package --vulnerable --include-transitive 2>/dev/null || echo "dotnet vulnerability check failed"
fi

# Java projects
if [ -f "pom.xml" ]; then
    echo "Scanning Java dependencies..."
    if command -v mvn >/dev/null; then
        mvn dependency:check 2>/dev/null || echo "Maven dependency check failed"
    fi
fi

# Generic Trivy scan (if available)
if command -v trivy >/dev/null; then
    echo "Running Trivy filesystem scan..."
    trivy fs --severity HIGH,CRITICAL .
fi

EOF

chmod +x /tmp/scan_dependencies.sh
echo "Dependency scanning script created at /tmp/scan_dependencies.sh"
echo "Run this script in function code directories"
```

**Key Assessment Points**:
- [ ] Dependency vulnerability scanning integrated into CI/CD
- [ ] Regular updates of third-party libraries
- [ ] Pinned dependency versions to prevent supply chain attacks
- [ ] Lambda layers regularly updated and scanned
- [ ] Minimal dependency sets to reduce attack surface

### SAS-07: Insecure Application Secrets Storage

#### Secrets Management Assessment
```bash
# Azure Functions secrets management
echo "=== Azure Functions Secrets Management ==="
az functionapp list --query '[].name' -o tsv | while read funcapp; do
    echo "Function App: $funcapp"
    
    # Get application settings
    settings=$(az functionapp config appsettings list --name $funcapp -o json)
    
    # Check for potential secrets in app settings
    echo "$settings" | jq -r '.[].name' | while read setting_name; do
        if echo "$setting_name" | grep -iE "(password|secret|key|token|connectionstring|api)"; then
            # Check if it's a Key Vault reference
            setting_value=$(echo "$settings" | jq -r ".[] | select(.name==\"$setting_name\") | .value")
            if echo "$setting_value" | grep -q "@Microsoft.KeyVault"; then
                echo "✅ $setting_name: Key Vault reference"
            else
                echo "⚠️  $setting_name: Potential plaintext secret"
            fi
        fi
    done
    
    # Check for Key Vault integration
    key_vault_refs=$(echo "$settings" | jq -r '.[].value' | grep -c "@Microsoft.KeyVault" || echo "0")
    echo "Key Vault references: $key_vault_refs"
    
    echo
done

# AWS Lambda secrets management
echo "=== AWS Lambda Secrets Management ==="
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    echo "Lambda Function: $function"
    
    # Check environment variables
    env_vars=$(aws lambda get-function-configuration --function-name $function --query 'Environment.Variables' --output json 2>/dev/null)
    if [ "$env_vars" != "null" ] && [ "$env_vars" != "{}" ]; then
        echo "Environment Variables:"
        echo "$env_vars" | jq -r 'keys[]' | while read var_name; do
            if echo "$var_name" | grep -iE "(password|secret|key|token|api)"; then
                echo "⚠️  Potential secret in environment variable: $var_name"
            else
                echo "  $var_name"
            fi
        done
        
        # Check if KMS encryption is enabled
        kms_key=$(aws lambda get-function-configuration --function-name $function --query 'KMSKeyArn' --output text)
        if [ "$kms_key" != "None" ]; then
            echo "✅ Environment variables encrypted with KMS: $kms_key"
        else
            echo "⚠️  Environment variables not encrypted with KMS"
        fi
    fi
    
    # Check for Secrets Manager integration in code (would require code analysis)
    echo "Note: Code analysis required to detect Secrets Manager usage"
    
    echo
done

# AWS Systems Manager Parameter Store usage analysis
echo "Checking Parameter Store parameters..."
aws ssm describe-parameters --query 'Parameters[?contains(Name, `/lambda/`) || contains(Name, `/function/`)].{Name:Name, Type:Type, KeyId:KeyId}' --output table 2>/dev/null || echo "SSM Parameter Store not accessible"

# GCP Cloud Functions secrets management
echo "=== GCP Cloud Functions Secrets Management ==="
gcloud functions list --format="value(name)" 2>/dev/null | while read function; do
    echo "Cloud Function: $function"
    
    # Get environment variables
    env_vars=$(gcloud functions describe $function --format="json(environmentVariables)" 2>/dev/null)
    if [ "$env_vars" != "null" ] && [ "$env_vars" != "{}" ]; then
        echo "Environment Variables:"
        echo "$env_vars" | jq -r '.environmentVariables | keys[]?' 2>/dev/null | while read var_name; do
            if echo "$var_name" | grep -iE "(password|secret|key|token|api)"; then
                echo "⚠️  Potential secret in environment variable: $var_name"
            else
                echo "  $var_name"
            fi
        done
    fi
    
    # Check for Secret Manager integration (requires code analysis)
    echo "Note: Code analysis required to detect Secret Manager usage"
    
    echo
done
```

**Key Assessment Points**:
- [ ] No hardcoded secrets in function code or environment variables
- [ ] Cloud-native secret management services used (Key Vault, Secrets Manager, Secret Manager)
- [ ] Secrets encrypted with customer-managed keys
- [ ] Secret rotation policies implemented
- [ ] Least privilege access to secrets

## Advanced Serverless Security Assessment

### Cold Start Security Analysis
```bash
# Analyze cold start behavior and security implications
echo "=== Cold Start Security Analysis ==="

# AWS Lambda provisioned concurrency assessment
aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do
    provisioned=$(aws lambda get-provisioned-concurrency-config --function-name $function --query 'AllocatedProvisionedConcurrencyExecutions' --output text 2>/dev/null)
    if [ "$provisioned" != "None" ]; then
        echo "Function $function has provisioned concurrency: $provisioned"
    else
        echo "Function $function uses cold starts"
    fi
done

# Check for initialization security issues
echo "Cold start security considerations:"
echo "- Secrets fetched during cold start may increase latency"
echo "- Connection pooling and caching implications"
echo "- Initialization code security review required"
```

### Event Source Security Deep Dive
```bash
# Advanced event source security assessment
echo "=== Event Source Security Deep Dive ==="

# AWS API Gateway security
aws apigateway get-rest-apis --query 'items[].id' --output text | while read api_id; do
    echo "API Gateway: $api_id"
    
    # Check API Gateway resource policies
    policy=$(aws apigateway get-rest-api --rest-api-id $api_id --query 'policy' --output text 2>/dev/null)
    if [ "$policy" != "None" ]; then
        echo "✅ Resource policy configured"
    else
        echo "⚠️  No resource policy configured"
    fi
    
    # Check for WAF integration
    aws wafv2 list-web-acls --scope=REGIONAL --query 'WebACLs[?contains(Description, `'$api_id'`) || contains(Name, `'$api_id'`)].Name' --output text | while read waf_name; do
        echo "✅ WAF associated: $waf_name"
    done
    
    # Check request validation
    aws apigateway get-request-validators --rest-api-id $api_id --query 'items[].{Name:name, ValidateRequestBody:validateRequestBody, ValidateRequestParameters:validateRequestParameters}' --output table 2>/dev/null
done

# Azure API Management integration
az apim list --query '[].{Name:name, ResourceGroup:resourceGroup, GatewayUrl:gatewayUrl}' -o table 2>/dev/null || echo "No API Management instances found"

# Event filtering and validation
echo "Event Source Filtering Assessment:"
echo "- Input validation at event source level"
echo "- Message filtering to prevent unwanted triggers"
echo "- Rate limiting and throttling configuration"
echo "- Event source access controls"
```

### Serverless Security Architecture Review
```python
# Python script for serverless security architecture assessment
import json
import subprocess
import re

def assess_serverless_architecture():
    """Comprehensive serverless security architecture assessment"""
    
    results = {
        'functions_count': 0,
        'security_score': 0,
        'findings': [],
        'recommendations': []
    }
    
    # Function inventory and basic security checks
    try:
        # AWS Lambda assessment
        lambda_functions = json.loads(subprocess.check_output([
            'aws', 'lambda', 'list-functions', '--output', 'json'
        ]).decode('utf-8'))
        
        results['functions_count'] = len(lambda_functions.get('Functions', []))
        
        for function in lambda_functions.get('Functions', []):
            function_name = function['FunctionName']
            
            # Runtime version check
            runtime = function.get('Runtime', '')
            if any(deprecated in runtime for deprecated in ['python2', 'nodejs10', 'nodejs12']):
                results['findings'].append({
                    'severity': 'High',
                    'function': function_name,
                    'issue': f'Deprecated runtime: {runtime}'
                })
            
            # Environment variables check
            env_vars = function.get('Environment', {}).get('Variables', {})
            for var_name in env_vars.keys():
                if re.search(r'(password|secret|key|token)', var_name, re.IGNORECASE):
                    results['findings'].append({
                        'severity': 'Medium',
                        'function': function_name,
                        'issue': f'Potential secret in environment variable: {var_name}'
                    })
            
            # VPC configuration
            if not function.get('VpcConfig', {}).get('VpcId'):
                results['findings'].append({
                    'severity': 'Low',
                    'function': function_name,
                    'issue': 'Function not in VPC - may allow unrestricted internet access'
                })
            
            # Dead letter queue check
            if not function.get('DeadLetterConfig', {}).get('TargetArn'):
                results['findings'].append({
                    'severity': 'Medium',
                    'function': function_name,
                    'issue': 'No dead letter queue configured'
                })
        
        # Calculate security score
        total_checks = results['functions_count'] * 4  # 4 checks per function
        failed_checks = len(results['findings'])
        results['security_score'] = max(0, ((total_checks - failed_checks) / total_checks) * 100)
        
        # Generate recommendations
        if any(f['severity'] == 'High' for f in results['findings']):
            results['recommendations'].append('Immediately update deprecated runtime versions')
        
        if any('secret' in f['issue'] for f in results['findings']):
            results['recommendations'].append('Migrate secrets to AWS Secrets Manager or Systems Manager Parameter Store')
        
        if any('VPC' in f['issue'] for f in results['findings']):
            results['recommendations'].append('Consider VPC integration for functions accessing private resources')
        
    except subprocess.CalledProcessError:
        results['findings'].append({
            'severity': 'Critical',
            'function': 'N/A',
            'issue': 'Unable to access AWS Lambda functions - check AWS CLI configuration'
        })
    
    return results

# Example usage
if __name__ == "__main__":
    assessment = assess_serverless_architecture()
    print(f"Serverless Security Assessment Results:")
    print(f"Functions Assessed: {assessment['functions_count']}")
    print(f"Security Score: {assessment['security_score']:.1f}%")
    print(f"Findings: {len(assessment['findings'])}")
    
    for finding in assessment['findings'][:5]:  # Show top 5 findings
        print(f"  [{finding['severity']}] {finding['function']}: {finding['issue']}")
```

## Automated Assessment Tools

### Comprehensive Serverless Security Scanner
```bash
#!/bin/bash
# Comprehensive Serverless Security Assessment Script

set -e

ASSESSMENT_DATE=$(date +%Y-%m-%d-%H%M)
REPORT_DIR="./serverless-security-assessment-$ASSESSMENT_DATE"
mkdir -p "$REPORT_DIR"

echo "=== Serverless Security Assessment ==="
echo "Assessment Date: $(date)"
echo "Report Directory: $REPORT_DIR"
echo

# Function to run assessment and save output
run_assessment() {
    local test_name=$1
    local command=$2
    local output_file="$REPORT_DIR/${test_name}.txt"
    
    echo "Running: $test_name"
    echo "=== $test_name ===" > "$output_file"
    echo "Generated: $(date)" >> "$output_file"
    echo >> "$output_file"
    
    if eval "$command" >> "$output_file" 2>&1; then
        echo "✅ $test_name completed"
    else
        echo "⚠️  $test_name failed or had issues"
    fi
}

# Azure Functions Assessment
if command -v az >/dev/null 2>&1; then
    run_assessment "azure-functions-inventory" "az functionapp list --query '[].{Name:name, ResourceGroup:resourceGroup, Runtime:siteConfig.linuxFxVersion, HttpsOnly:httpsOnly}' -o table"
    
    run_assessment "azure-functions-security-config" "az functionapp list --query '[].name' -o tsv | while read funcapp; do echo \"=== \$funcapp ===\"; az functionapp show --name \$funcapp --query '{HttpsOnly:httpsOnly, MinTlsVersion:siteConfig.minTlsVersion, Identity:identity.type}' -o yaml; echo; done"
    
    run_assessment "azure-functions-app-settings" "az functionapp list --query '[].name' -o tsv | while read funcapp; do echo \"=== \$funcapp ===\"; az functionapp config appsettings list --name \$funcapp --query '[?contains(name, \"password\") || contains(name, \"secret\") || contains(name, \"key\")].name' -o table; echo; done"
fi

# AWS Lambda Assessment
if command -v aws >/dev/null 2>&1; then
    run_assessment "aws-lambda-inventory" "aws lambda list-functions --query 'Functions[].{FunctionName:FunctionName, Runtime:Runtime, Role:Role}' --output table"
    
    run_assessment "aws-lambda-security-config" "aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do echo \"=== \$function ===\"; aws lambda get-function-configuration --function-name \$function --query '{Runtime:Runtime, KMSKeyArn:KMSKeyArn, VpcConfig:VpcConfig, DeadLetterConfig:DeadLetterConfig}' --output yaml; echo; done"
    
    run_assessment "aws-lambda-environment-variables" "aws lambda list-functions --query 'Functions[].FunctionName' --output text | while read function; do echo \"=== \$function ===\"; aws lambda get-function-configuration --function-name \$function --query 'Environment.Variables' --output json | jq -r 'keys[]' | grep -iE '(password|secret|key|token)' || echo 'No obvious secrets found'; echo; done"
    
    run_assessment "aws-lambda-execution-roles" "aws lambda list-functions --query 'Functions[].Role' --output text | sort -u | while read role; do echo \"=== \$role ===\"; role_name=\$(basename \$role); aws iam list-attached-role-policies --role-name \$role_name --query 'AttachedPolicies[].PolicyName' --output text 2>/dev/null || echo 'Access denied'; echo; done"
fi

# GCP Cloud Functions Assessment
if command -v gcloud >/dev/null 2>&1; then
    run_assessment "gcp-functions-inventory" "gcloud functions list --format='table(name,status,runtime,trigger.httpsTrigger.url)' 2>/dev/null || echo 'Cloud Functions access not available'"
    
    run_assessment "gcp-functions-security-config" "gcloud functions list --format='value(name)' 2>/dev/null | while read function; do echo \"=== \$function ===\"; gcloud functions describe \$function --format='yaml(serviceAccountEmail,environmentVariables,ingressSettings)' 2>/dev/null || echo 'Function details not accessible'; echo; done"
fi

# Event Sources Assessment
run_assessment "event-sources-analysis" "echo 'Azure Event Grid:'; az eventgrid topic list --query '[].{Name:name, Endpoint:endpoint}' -o table 2>/dev/null || echo 'EventGrid not accessible'; echo; echo 'AWS SQS Queues:'; aws sqs list-queues --output table 2>/dev/null || echo 'SQS not accessible'; echo; echo 'GCP Pub/Sub Topics:'; gcloud pubsub topics list --format='table(name)' 2>/dev/null || echo 'Pub/Sub not accessible'"

# API Gateway Security Assessment
run_assessment "api-gateway-security" "echo 'AWS API Gateway:'; aws apigateway get-rest-apis --query 'items[].{Id:id, Name:name, CreatedDate:createdDate}' --output table 2>/dev/null || echo 'API Gateway not accessible'; echo; echo 'Azure API Management:'; az apim list --query '[].{Name:name, GatewayUrl:gatewayUrl}' -o table 2>/dev/null || echo 'APIM not accessible'"

# Generate summary report
echo "=== Generating Summary Report ==="
{
    echo "=== Serverless Security Assessment Summary ==="
    echo "Assessment completed: $(date)"
    echo "Report directory: $REPORT_DIR"
    echo
    
    echo "Assessment files generated:"
    ls -la "$REPORT_DIR/"*.txt | wc -l | xargs echo "Total files:"
    echo
    
    echo "Key findings summary:"
    echo "- Review function runtime versions for deprecated versions"
    echo "- Check for secrets in environment variables"
    echo "- Verify proper IAM/RBAC permissions"
    echo "- Ensure monitoring and logging are configured"
    echo "- Validate event source security configurations"
    echo
    
    echo "Next steps:"
    echo "1. Review detailed findings in individual assessment files"
    echo "2. Prioritize critical and high-severity findings"
    echo "3. Implement security hardening recommendations"
    echo "4. Establish continuous security monitoring"
    echo "5. Schedule regular security assessments"
    
} > "$REPORT_DIR/summary.txt"

echo
echo "=== Serverless Security Assessment Complete ==="
echo "Results saved in: $REPORT_DIR"
echo "Review the summary.txt file for an overview"

# Optional: Generate HTML report if Python is available
if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import os
import glob
from datetime import datetime

report_dir = '$REPORT_DIR'
html_content = f'''
<!DOCTYPE html>
<html>
<head>
    <title>Serverless Security Assessment Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        .header {{ background-color: #f0f0f0; padding: 20px; border-radius: 5px; }}
        .section {{ margin: 20px 0; }}
        .finding {{ margin: 10px 0; padding: 10px; border-left: 4px solid #orange; background-color: #fff3cd; }}
        pre {{ background-color: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }}
    </style>
</head>
<body>
    <div class=\"header\">
        <h1>Serverless Security Assessment Report</h1>
        <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>Report Directory: {report_dir}</p>
    </div>
'''

# Add assessment results
for txt_file in glob.glob(f'{report_dir}/*.txt'):
    with open(txt_file, 'r') as f:
        content = f.read()
        filename = os.path.basename(txt_file)
        html_content += f'''
    <div class=\"section\">
        <h2>{filename.replace('.txt', '').replace('-', ' ').title()}</h2>
        <pre>{content}</pre>
    </div>
'''

html_content += '''
</body>
</html>
'''

with open(f'{report_dir}/assessment-report.html', 'w') as f:
    f.write(html_content)

print('HTML report generated: {}/assessment-report.html'.format(report_dir))
"
fi

echo "Assessment artifact location: $REPORT_DIR"
```

## Risk Assessment and Remediation

### Serverless Risk Scoring Matrix
| Risk Category | Low (1-3) | Medium (4-6) | High (7-8) | Critical (9-10) |
|---------------|-----------|--------------|------------|-----------------|
| **Function Permissions** | Minimal permissions | Some excess permissions | Overprivileged roles | Admin/Owner permissions |
| **Event Injection** | Input validation implemented | Basic validation | Limited validation | No input validation |
| **Secrets Management** | External secret store | Encrypted env vars | Plaintext env vars | Hardcoded secrets |
| **Monitoring** | Comprehensive logging/monitoring | Basic monitoring | Limited logging | No monitoring |
| **Dependencies** | Regular updates, vulnerability scanning | Occasional updates | Outdated dependencies | Known vulnerabilities |

### Remediation Priority Framework
```python
def calculate_serverless_remediation_priority(finding):
    """Calculate remediation priority for serverless security findings"""
    
    # Base severity mapping
    severity_scores = {
        'critical': 10,
        'high': 7,
        'medium': 4,
        'low': 2
    }
    
    base_score = severity_scores.get(finding.severity.lower(), 1)
    
    # Function exposure multiplier
    exposure_multipliers = {
        'internet_facing': 2.0,
        'internal_api': 1.5,
        'event_driven': 1.2,
        'scheduled': 1.0
    }
    
    exposure = exposure_multipliers.get(finding.exposure_type, 1.0)
    
    # Business impact multiplier
    impact_multipliers = {
        'revenue_critical': 2.0,
        'customer_facing': 1.5,
        'internal_operations': 1.2,
        'development': 1.0
    }
    
    business_impact = impact_multipliers.get(finding.business_impact, 1.0)
    
    # Remediation complexity factor (easier fixes get higher priority)
    complexity_factors = {
        'configuration': 1.3,  # Easy config changes
        'code_change': 1.0,    # Moderate effort
        'architecture': 0.8,   # Complex changes
        'process': 0.6         # Long-term process changes
    }
    
    complexity = complexity_factors.get(finding.remediation_type, 1.0)
    
    final_score = min(base_score * exposure * business_impact * complexity, 10)
    
    return {
        'priority_score': round(final_score, 1),
        'priority_level': get_priority_level(final_score),
        'estimated_effort': get_effort_estimate(finding.remediation_type),
        'timeline': get_remediation_timeline(final_score)
    }

def get_priority_level(score):
    if score >= 8:
        return 'Critical - Immediate Action Required'
    elif score >= 6:
        return 'High - Address Within 1 Week'
    elif score >= 4:
        return 'Medium - Address Within 1 Month'
    else:
        return 'Low - Include in Next Planning Cycle'

def get_effort_estimate(remediation_type):
    effort_map = {
        'configuration': '1-4 hours',
        'code_change': '1-3 days',
        'architecture': '1-2 weeks',
        'process': '1-3 months'
    }
    return effort_map.get(remediation_type, 'Unknown')

def get_remediation_timeline(score):
    if score >= 8:
        return '24-48 hours'
    elif score >= 6:
        return '1 week'
    elif score >= 4:
        return '1 month'
    else:
        return '3 months'
```

## Report Template

### Executive Summary
**Serverless Security Assessment Summary**
- **Assessment Date**: [Date]
- **Functions Assessed**: [Number] serverless functions across [Azure/AWS/GCP]
- **Overall Risk Rating**: [Rating]/10
- **Critical Security Issues**: [Count]

**OWASP Serverless Top 10 Compliance**:
1. SAS-01 Function Event-Data Injection: [Status]
2. SAS-02 Broken Authentication: [Status] 
3. SAS-03 Insecure Serverless Deployment Configuration: [Status]
4. SAS-04 Over-Privileged Function Permissions & Roles: [Status]
5. SAS-05 Inadequate Function Monitoring & Logging: [Status]
6. SAS-06 Insecure Third-Party Dependencies: [Status]

**Top Security Risks Identified**:
1. **Overprivileged Execution Roles**: [X] functions with excessive permissions
2. **Insecure Secrets Management**: [Y] functions with hardcoded/plaintext secrets
3. **Inadequate Input Validation**: [Z] functions vulnerable to injection attacks
4. **Missing Security Monitoring**: [A] functions without proper logging/alerting

### Detailed Technical Findings

#### Function Security Configuration
| Platform | Total Functions | HTTPS Only | Runtime Current | Encrypted Secrets | Monitoring Enabled |
|----------|-----------------|------------|-----------------|-------------------|-------------------|
| Azure Functions | [X] | [Y]% | [Z]% | [A]% | [B]% |
| AWS Lambda | [X] | N/A | [Z]% | [A]% | [B]% |
| Google Cloud Functions | [X] | [Y]% | [Z]% | [A]% | [B]% |

#### Permission Analysis
| Permission Level | Function Count | Risk Level | Remediation Priority |
|------------------|----------------|------------|---------------------|
| Admin/Owner | [X] | Critical | Immediate |
| Contributor/Editor | [Y] | High | 1 Week |
| Custom Overprivileged | [Z] | Medium | 1 Month |
| Least Privilege | [A] | Low | Monitor |

#### Event Source Security
| Event Source Type | Count | Input Validation | Rate Limiting | Authentication |
|-------------------|-------|------------------|---------------|----------------|
| HTTP/API Gateway | [X] | [Y]% | [Z]% | [A]% |
| Message Queue | [X] | [Y]% | [Z]% | [A]% |
| Storage Events | [X] | [Y]% | [Z]% | [A]% |
| Scheduled | [X] | [Y]% | [Z]% | [A]% |

### Remediation Roadmap

#### Phase 1: Critical Issues (Week 1-2)
- [ ] Remove admin/owner permissions from function execution roles
- [ ] Migrate hardcoded secrets to cloud secret management services
- [ ] Enable HTTPS enforcement on all HTTP-triggered functions
- [ ] Implement basic input validation for high-risk functions

#### Phase 2: High Priority (Month 1-2)
- [ ] Deploy comprehensive monitoring and alerting
- [ ] Implement network security controls (VPC integration, private endpoints)
- [ ] Establish dead letter queues for async processing
- [ ] Update deprecated runtime versions

#### Phase 3: Security Hardening (Month 2-3)
- [ ] Implement advanced threat detection and response
- [ ] Deploy API security controls (WAF, rate limiting)
- [ ] Establish vulnerability scanning for dependencies
- [ ] Create security testing integration in CI/CD pipelines

#### Phase 4: Governance and Compliance (Month 3-6)
- [ ] Establish serverless security policies and standards
- [ ] Implement automated compliance monitoring
- [ ] Create security training for development teams
- [ ] Regular security assessment and testing procedures

### Cost-Benefit Analysis
**Security Investment Required**: $[X] over 6 months
- Secret management service: $[Y]/month
- Monitoring and logging: $[Z]/month
- Security tooling: $[A]/month
- Professional services: $[B] one-time

**Risk Reduction Value**: $[X] in avoided incident costs
**Compliance Benefits**: Reduced audit preparation time and costs
**Operational Efficiency**: Automated security controls reduce manual overhead

### Long-term Security Strategy
1. **Zero Trust Serverless Architecture**: Implement comprehensive authentication and authorization for all function access
2. **Supply Chain Security**: Establish secure development lifecycle with vulnerability scanning and dependency management
3. **Runtime Security**: Deploy advanced runtime protection and anomaly detection
4. **Continuous Compliance**: Automate compliance validation and remediation

This comprehensive assessment provides the foundation for establishing robust security practices in your serverless environment while maintaining the agility and cost benefits of serverless computing.