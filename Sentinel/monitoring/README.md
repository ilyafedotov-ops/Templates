# Microsoft Sentinel Monitoring and Health Check Framework

This directory contains comprehensive monitoring solutions for Microsoft Sentinel deployments, including health checks, cost optimization, and performance monitoring capabilities.

## Overview

The monitoring framework provides:

- **Health Monitoring**: Real-time status of data connectors and ingestion
- **Cost Analysis**: Detailed cost breakdowns and optimization opportunities  
- **Performance Monitoring**: Query performance, resource utilization, and system efficiency
- **Automated Alerting**: Proactive notifications for issues and anomalies
- **Optimization Recommendations**: Data-driven suggestions for improvements

## Directory Structure

```
monitoring/
├── health-checks/
│   ├── data-ingestion-monitoring.kql      # Data connector health queries
│   ├── connector-status-dashboard.json    # Workbook for health visualization
│   └── health-check-automation.ps1        # Automated health check script
├── cost-optimization/
│   ├── cost-analysis-queries.kql          # Cost analysis and optimization
│   ├── cost-dashboard.json                # Cost visualization workbook
│   └── cost-alerts.json                   # Cost-based alert rules
├── performance/
│   ├── performance-monitoring.kql         # Performance analysis queries
│   ├── performance-dashboard.json         # Performance metrics workbook
│   └── query-optimization-guide.md        # Query optimization best practices
└── README.md                              # This file
```

## Quick Start

### 1. Health Monitoring

Monitor the health of your Sentinel deployment:

```kql
// Quick health check - run in Sentinel workspace
union withsource=TableName *
| where TimeGenerated > ago(24h)
| summarize 
    RecordCount = count(),
    LastRecord = max(TimeGenerated)
by TableName
| extend Status = iff(LastRecord > ago(1h), "✅ Healthy", "⚠️ Stale Data")
| project TableName, Status, RecordCount, LastRecord
| order by RecordCount desc
```

### 2. Cost Analysis

Analyze your current costs and identify optimization opportunities:

```kql
// Daily cost breakdown
Usage
| where TimeGenerated > ago(30d)
| where IsBillable == true
| summarize 
    DataVolumeGB = sum(Quantity) / 1024,
    EstimatedCostUSD = sum(Quantity) / 1024 * 2.30
by bin(TimeGenerated, 1d), DataType
| order by TimeGenerated desc, EstimatedCostUSD desc
```

### 3. Performance Monitoring

Monitor query performance and system efficiency:

```kql
// Slow query analysis
LAQueryLogs
| where TimeGenerated > ago(24h)
| where DurationMs > 30000  // Queries taking >30 seconds
| summarize 
    QueryCount = count(),
    AvgDurationSeconds = avg(DurationMs) / 1000,
    AvgDataScannedGB = avg(DataScanned_GB)
by QueryHash_g
| order by AvgDurationSeconds desc
```

## Key Monitoring Areas

### Data Ingestion Health

Monitor the health of all data connectors:

- **Azure Native Connectors**: Activity logs, Azure AD, Security Center
- **Office 365**: Exchange, SharePoint, Teams activity
- **Multi-Cloud**: AWS CloudTrail, GCP Audit Logs
- **Custom Sources**: CEF, Syslog, Custom logs

Key metrics:
- Data freshness and ingestion latency
- Volume trends and anomalies
- Connector connectivity status
- Data quality issues

### Cost Optimization

Track and optimize costs across:

- **Ingestion Costs**: Per-GB data ingestion charges
- **Storage Costs**: Hot, warm, and archive tier utilization
- **Query Costs**: Data scanning and processing charges
- **Retention Costs**: Long-term storage expenses

Optimization opportunities:
- Data filtering and sampling
- Retention policy adjustments
- Query efficiency improvements
- Archive tier utilization

### Performance Monitoring

Monitor system performance including:

- **Query Performance**: Execution time, data scanning efficiency
- **Resource Utilization**: CPU, memory, and storage usage
- **Concurrent Load**: System capacity and response times
- **Analytics Rules**: Detection performance and efficiency

Performance metrics:
- Query execution times and trends
- Data scanning patterns
- System resource consumption
- Alert generation efficiency

## Automated Monitoring Setup

### 1. Create Monitoring Workbooks

Deploy the included workbooks for visual monitoring:

```bash
# Deploy health check workbook
az sentinel workbook create \
  --resource-group "rg-sentinel" \
  --workspace-name "law-sentinel" \
  --workbook-id "sentinel-health-dashboard" \
  --display-name "Sentinel Health Dashboard" \
  --serialized-data @health-checks/connector-status-dashboard.json
```

### 2. Configure Alert Rules

Set up automated alerts for critical conditions:

```bash
# Create cost alert rule
az monitor scheduled-query create \
  --resource-group "rg-sentinel" \
  --scopes "/subscriptions/{subscription}/resourceGroups/rg-sentinel/providers/Microsoft.OperationalInsights/workspaces/law-sentinel" \
  --display-name "High Daily Cost Alert" \
  --description "Alert when daily costs exceed threshold" \
  --condition "count 'gt' 0" \
  --condition-query "Usage | where IsBillable | summarize DailyCost = sum(Quantity)/1024*2.30 by bin(TimeGenerated,1d) | where DailyCost > 100" \
  --evaluation-frequency "PT1H" \
  --window-size "P1D" \
  --severity 2
```

### 3. Health Check Automation

Schedule regular health checks using Azure Automation or Logic Apps:

```powershell
# Example PowerShell runbook for health checks
$HealthQuery = @"
union withsource=TableName *
| where TimeGenerated > ago(2h)
| summarize LastData = max(TimeGenerated) by TableName
| extend Status = iff(LastData > ago(1h), "Healthy", "Stale")
| where Status == "Stale"
"@

$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $HealthQuery

if ($Results.Results.Count -gt 0) {
    # Send alert notification
    Send-HealthAlert -Issues $Results.Results
}
```

## Query Templates

### Health Check Queries

The health check queries provide comprehensive monitoring:

1. **Overall Health Status**: High-level view of all data sources
2. **Connector-Specific Checks**: Detailed analysis per connector
3. **Data Quality Monitoring**: Missing fields and data validation
4. **Ingestion Latency**: Time between event generation and availability
5. **Anomaly Detection**: Unusual patterns in data volume or timing

### Cost Analysis Queries

Cost optimization queries help manage expenses:

1. **Daily/Monthly Cost Breakdown**: Spending patterns over time
2. **Cost by Data Source**: Identify highest-cost connectors
3. **Cost Trends**: Anomaly detection for unexpected increases
4. **Retention Analysis**: Storage costs by data age
5. **Query Cost Analysis**: Expensive queries and optimization opportunities
6. **Optimization Recommendations**: Data-driven cost reduction suggestions

### Performance Monitoring Queries

Performance queries ensure optimal system operation:

1. **Slow Query Analysis**: Identify and optimize poor-performing queries
2. **Resource Utilization**: CPU, memory, and storage usage patterns
3. **Concurrent Load**: System capacity and bottleneck identification
4. **Data Freshness**: Ingestion delays and data availability
5. **Analytics Performance**: Rule execution efficiency
6. **Baseline Comparison**: Performance trends over time

## Best Practices

### Monitoring Strategy

1. **Layered Approach**: Implement monitoring at multiple levels
   - Real-time health checks (every 5-15 minutes)
   - Daily cost and performance analysis
   - Weekly optimization reviews
   - Monthly capacity planning

2. **Alerting Strategy**: 
   - Critical: Data ingestion stopped, security alerts
   - Warning: Performance degradation, cost increases
   - Info: Optimization opportunities, capacity updates

3. **Documentation**: Maintain runbooks for common issues
   - Connector troubleshooting procedures
   - Performance optimization steps
   - Cost optimization playbooks

### Query Optimization

1. **Time Filtering**: Always include time ranges to reduce data scanning
2. **Early Filtering**: Apply filters as early as possible in queries
3. **Summarization**: Use summarize operations to reduce result sets
4. **Materialized Views**: Pre-calculate expensive aggregations
5. **Indexing**: Leverage table indexing for common query patterns

### Cost Management

1. **Regular Reviews**: Weekly cost analysis and optimization
2. **Data Lifecycle**: Implement proper retention and archival policies
3. **Query Efficiency**: Monitor and optimize expensive queries
4. **Capacity Planning**: Forecast growth and budget requirements
5. **Tagging Strategy**: Use consistent tagging for cost allocation

## Troubleshooting

### Common Issues

1. **No Data in Connector**
   - Check connector configuration
   - Verify permissions and authentication
   - Review diagnostic logs
   - Validate network connectivity

2. **High Costs**
   - Analyze cost breakdown by source
   - Review retention policies
   - Optimize data collection rules
   - Implement data filtering

3. **Poor Query Performance**
   - Add time filters to queries
   - Optimize KQL syntax
   - Review concurrent query load
   - Check for expensive operations

4. **Data Delays**
   - Monitor ingestion pipeline
   - Check source system health
   - Verify connector status
   - Review network latency

### Health Check Failures

If health checks indicate issues:

1. **Data Connector Issues**: Review configuration and credentials
2. **Performance Problems**: Analyze query patterns and load
3. **Cost Overruns**: Implement optimization strategies
4. **Security Concerns**: Review access patterns and anomalies

## Integration with External Tools

### ITSM Integration

Connect monitoring to your IT Service Management system:

```json
{
  "alert_webhook": "https://your-itsm.com/api/incidents",
  "severity_mapping": {
    "critical": "P1",
    "high": "P2", 
    "medium": "P3",
    "low": "P4"
  }
}
```

### Slack/Teams Notifications

Configure chat notifications for alerts:

```powershell
# Teams webhook example
$TeamsMessage = @{
    title = "Sentinel Health Alert"
    text = "Data ingestion issue detected"
    themeColor = "FF0000"
}
Invoke-RestMethod -Uri $TeamsWebhook -Method Post -Body ($TeamsMessage | ConvertTo-Json)
```

## Maintenance

### Regular Tasks

1. **Weekly**:
   - Review health dashboards
   - Analyze cost trends
   - Check performance metrics

2. **Monthly**:
   - Update optimization recommendations
   - Review alert thresholds
   - Analyze capacity trends

3. **Quarterly**:
   - Update monitoring queries
   - Review and optimize dashboards
   - Plan capacity increases

### Updates and Improvements

Keep monitoring current by:

1. Updating KQL queries for new features
2. Adding monitoring for new data connectors
3. Enhancing performance baselines
4. Incorporating feedback from operations teams

## Support and Documentation

For additional support:

- Microsoft Sentinel Documentation: https://docs.microsoft.com/azure/sentinel/
- KQL Reference: https://docs.microsoft.com/azure/data-explorer/kusto/
- Azure Monitor Logs: https://docs.microsoft.com/azure/azure-monitor/logs/
- Cost Management: https://docs.microsoft.com/azure/cost-management-billing/