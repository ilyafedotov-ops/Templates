# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.sentinel.name
}

output "resource_group_id" {
  description = "Resource ID of the created resource group"
  value       = azurerm_resource_group.sentinel.id
}

output "location" {
  description = "Azure region where resources were deployed"
  value       = azurerm_resource_group.sentinel.location
}

# Log Analytics Workspace Outputs
output "workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.name
}

output "workspace_id" {
  description = "Workspace ID (Customer ID) for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.workspace_id
  sensitive   = true
}

output "workspace_resource_id" {
  description = "Azure Resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.id
}

output "workspace_primary_shared_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.primary_shared_key
  sensitive   = true
}

output "workspace_secondary_shared_key" {
  description = "Secondary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.sentinel.secondary_shared_key
  sensitive   = true
}

# Microsoft Sentinel Outputs
output "sentinel_id" {
  description = "Resource ID of the Microsoft Sentinel instance"
  value       = azapi_resource.sentinel.id
}

output "sentinel_enabled" {
  description = "Whether Microsoft Sentinel is enabled on the workspace"
  value       = true
}

# Storage Account Outputs (if enabled)
output "storage_account_name" {
  description = "Name of the storage account for long-term retention"
  value       = var.enable_long_term_storage ? azurerm_storage_account.sentinel[0].name : null
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = var.enable_long_term_storage ? azurerm_storage_account.sentinel[0].id : null
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = var.enable_long_term_storage ? azurerm_storage_account.sentinel[0].primary_access_key : null
  sensitive   = true
}

output "storage_account_connection_string" {
  description = "Connection string for the storage account"
  value       = var.enable_long_term_storage ? azurerm_storage_account.sentinel[0].primary_connection_string : null
  sensitive   = true
}

# Data Connector Outputs
output "enabled_data_connectors" {
  description = "List of enabled data connectors"
  value = compact([
    var.enable_azure_activity ? "AzureActivity" : "",
    var.enable_azure_ad ? "AzureActiveDirectory" : "",
    var.enable_security_center ? "AzureSecurityCenter" : "",
    var.enable_office365 ? "Office365" : "",
    var.enable_identity_protection ? "IdentityProtection" : ""
  ])
}

output "azure_activity_connector_id" {
  description = "Resource ID of the Azure Activity connector"
  value       = var.enable_azure_activity ? azapi_resource.activity_connector[0].id : null
}

output "azure_ad_connector_id" {
  description = "Resource ID of the Azure AD connector"
  value       = var.enable_azure_ad ? azapi_resource.aad_connector[0].id : null
}

output "security_center_connector_id" {
  description = "Resource ID of the Security Center connector"
  value       = var.enable_security_center ? azapi_resource.security_center_connector[0].id : null
}

output "office365_connector_id" {
  description = "Resource ID of the Office 365 connector"
  value       = var.enable_office365 ? azapi_resource.office365_connector[0].id : null
}

# Data Collection Rules Outputs
output "data_collection_rules" {
  description = "List of created Data Collection Rules for custom logs"
  value = {
    for rule in azapi_resource.data_collection_rule : rule.name => {
      id   = rule.id
      name = rule.name
    }
  }
}

# Network Outputs
output "private_endpoint_ids" {
  description = "Resource IDs of created private endpoints"
  value       = var.enable_private_endpoints && var.enable_long_term_storage ? [azurerm_private_endpoint.storage[0].id] : []
}

# Configuration Information
output "configuration_summary" {
  description = "Summary of the Sentinel deployment configuration"
  value = {
    workspace = {
      name              = azurerm_log_analytics_workspace.sentinel.name
      sku               = azurerm_log_analytics_workspace.sentinel.sku
      retention_days    = azurerm_log_analytics_workspace.sentinel.retention_in_days
      daily_quota_gb    = var.daily_quota_gb
    }
    data_connectors = {
      azure_activity      = var.enable_azure_activity
      azure_ad           = var.enable_azure_ad
      security_center    = var.enable_security_center
      office365          = var.enable_office365
      identity_protection = var.enable_identity_protection
    }
    office365_data_types = {
      exchange   = var.office365_exchange_enabled
      sharepoint = var.office365_sharepoint_enabled
      teams      = var.office365_teams_enabled
    }
    features = {
      long_term_storage     = var.enable_long_term_storage
      private_endpoints     = var.enable_private_endpoints
      workspace_diagnostics = var.enable_workspace_diagnostics
      cost_alerts          = var.enable_cost_alerts
    }
    custom_log_sources = length(var.custom_log_sources)
  }
}

# Connection Strings and Endpoints
output "connection_info" {
  description = "Connection information for external tools and applications"
  value = {
    workspace_id  = azurerm_log_analytics_workspace.sentinel.workspace_id
    workspace_url = "https://${azurerm_log_analytics_workspace.sentinel.workspace_id}.ods.opinsights.azure.com"
    portal_url    = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource${azurerm_log_analytics_workspace.sentinel.id}/Overview"
    api_endpoint  = "https://management.azure.com${azurerm_log_analytics_workspace.sentinel.id}"
  }
  sensitive = true
}

# Health Check Queries
output "health_check_queries" {
  description = "KQL queries for monitoring Sentinel health"
  value = {
    data_ingestion = "union withsource=TableName * | where TimeGenerated > ago(24h) | summarize Count = count() by TableName | where Count > 0 | order by Count desc"
    connector_health = "union (AzureActivity | where TimeGenerated > ago(1h) | extend Connector = 'AzureActivity'), (SigninLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'), (AuditLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'), (SecurityAlert | where TimeGenerated > ago(1h) | extend Connector = 'SecurityCenter'), (OfficeActivity | where TimeGenerated > ago(1h) | extend Connector = 'Office365') | summarize LastReceived = max(TimeGenerated), Count = count() by Connector | extend Status = case(Count > 0, 'Healthy', 'No Data')"
    cost_monitoring = "Usage | where TimeGenerated > ago(30d) | where IsBillable == true | summarize TotalVolumeGB = sum(Quantity) / 1024 by bin(TimeGenerated, 1d) | order by TimeGenerated asc"
  }
}

# Tags Applied
output "applied_tags" {
  description = "Tags applied to all resources"
  value       = var.tags
}