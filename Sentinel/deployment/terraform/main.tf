terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.9"
    }
  }
}

provider "azurerm" {
  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = var.permanently_delete_workspace
    }
  }
}

provider "azapi" {}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "sentinel" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = var.workspace_name
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  sku                 = var.workspace_sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

# Microsoft Sentinel
resource "azapi_resource" "sentinel" {
  type      = "Microsoft.SecurityInsights/onboardingStates@2023-02-01"
  name      = "default"
  parent_id = azurerm_log_analytics_workspace.sentinel.id

  depends_on = [
    azurerm_log_analytics_workspace.sentinel
  ]
}

# Storage Account for long-term retention (optional)
resource "azurerm_storage_account" "sentinel" {
  count                    = var.enable_long_term_storage ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.sentinel.name
  location                = azurerm_resource_group.sentinel.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    change_feed_retention_in_days = 30
    
    container_delete_retention_policy {
      days = 365
    }
    
    delete_retention_policy {
      days = 365
    }
  }

  network_rules {
    default_action = "Deny"
    ip_rules       = var.allowed_ip_ranges
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Private Endpoint for Storage Account (if enabled)
resource "azurerm_private_endpoint" "storage" {
  count               = var.enable_long_term_storage && var.enable_private_endpoints ? 1 : 0
  name                = "${var.storage_account_name}-pe"
  location            = azurerm_resource_group.sentinel.location
  resource_group_name = azurerm_resource_group.sentinel.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-psc"
    private_connection_resource_id = azurerm_storage_account.sentinel[0].id
    subresource_names              = ["blob"]
    is_manual_connection          = false
  }

  tags = var.tags
}

# Diagnostic Settings for Workspace
resource "azurerm_monitor_diagnostic_setting" "workspace" {
  count              = var.enable_workspace_diagnostics ? 1 : 0
  name               = "diag-${var.workspace_name}"
  target_resource_id = azurerm_log_analytics_workspace.sentinel.id
  storage_account_id = var.enable_long_term_storage ? azurerm_storage_account.sentinel[0].id : null

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
  }
}

# Data Collection Rules for custom logs
resource "azapi_resource" "data_collection_rule" {
  count     = length(var.custom_log_sources)
  type      = "Microsoft.Insights/dataCollectionRules@2022-06-01"
  name      = "dcr-${var.custom_log_sources[count.index].name}"
  location  = azurerm_resource_group.sentinel.location
  parent_id = azurerm_resource_group.sentinel.id

  body = jsonencode({
    properties = {
      dataSources = {
        logFiles = [
          {
            streams      = ["Custom-${var.custom_log_sources[count.index].name}"]
            filePatterns = var.custom_log_sources[count.index].file_patterns
            format       = "text"
            settings = {
              text = {
                recordStartTimestampFormat = "ISO 8601"
              }
            }
            name = var.custom_log_sources[count.index].name
          }
        ]
      }
      destinations = {
        logAnalytics = [
          {
            workspaceResourceId = azurerm_log_analytics_workspace.sentinel.id
            name               = "la-destination"
          }
        ]
      }
      dataFlows = [
        {
          streams      = ["Custom-${var.custom_log_sources[count.index].name}"]
          destinations = ["la-destination"]
          transformKql = var.custom_log_sources[count.index].transform_kql
          outputStream = "Custom-${var.custom_log_sources[count.index].name}_CL"
        }
      ]
    }
  })

  tags = var.tags
}

# Azure Activity Log Data Connector
resource "azapi_resource" "activity_connector" {
  count     = var.enable_azure_activity ? 1 : 0
  type      = "Microsoft.SecurityInsights/dataConnectors@2023-02-01"
  name      = "AzureActivity-${random_uuid.activity_connector[0].result}"
  parent_id = azurerm_log_analytics_workspace.sentinel.id

  body = jsonencode({
    kind = "AzureActivityLog"
    properties = {
      tenantId       = data.azurerm_client_config.current.tenant_id
      subscriptionId = data.azurerm_client_config.current.subscription_id
      dataTypes = {
        logs = [
          {
            state = "Enabled"
          }
        ]
      }
    }
  })

  depends_on = [azapi_resource.sentinel]
}

resource "random_uuid" "activity_connector" {
  count = var.enable_azure_activity ? 1 : 0
}

# Azure AD Data Connector
resource "azapi_resource" "aad_connector" {
  count     = var.enable_azure_ad ? 1 : 0
  type      = "Microsoft.SecurityInsights/dataConnectors@2023-02-01"
  name      = "AzureActiveDirectory-${random_uuid.aad_connector[0].result}"
  parent_id = azurerm_log_analytics_workspace.sentinel.id

  body = jsonencode({
    kind = "AzureActiveDirectory"
    properties = {
      tenantId = data.azurerm_client_config.current.tenant_id
      dataTypes = {
        signInLogs = {
          state = "Enabled"
        }
        auditLogs = {
          state = "Enabled"
        }
        nonInteractiveUserSignInLogs = {
          state = "Enabled"
        }
        servicePrincipalSignInLogs = {
          state = "Enabled"
        }
        managedIdentitySignInLogs = {
          state = "Enabled"
        }
        provisioningLogs = {
          state = "Enabled"
        }
        adfsSignInLogs = {
          state = "Enabled"
        }
        riskyUsers = {
          state = "Enabled"
        }
        userRiskEvents = {
          state = "Enabled"
        }
      }
    }
  })

  depends_on = [azapi_resource.sentinel]
}

resource "random_uuid" "aad_connector" {
  count = var.enable_azure_ad ? 1 : 0
}

# Security Center Data Connector
resource "azapi_resource" "security_center_connector" {
  count     = var.enable_security_center ? 1 : 0
  type      = "Microsoft.SecurityInsights/dataConnectors@2023-02-01"
  name      = "AzureSecurityCenter-${random_uuid.security_center_connector[0].result}"
  parent_id = azurerm_log_analytics_workspace.sentinel.id

  body = jsonencode({
    kind = "AzureSecurityCenter"
    properties = {
      subscriptionId = data.azurerm_client_config.current.subscription_id
      dataTypes = {
        alerts = {
          state = "Enabled"
        }
        recommendations = {
          state = "Enabled"
        }
      }
    }
  })

  depends_on = [azapi_resource.sentinel]
}

resource "random_uuid" "security_center_connector" {
  count = var.enable_security_center ? 1 : 0
}

# Office 365 Data Connector
resource "azapi_resource" "office365_connector" {
  count     = var.enable_office365 ? 1 : 0
  type      = "Microsoft.SecurityInsights/dataConnectors@2023-02-01"
  name      = "Office365-${random_uuid.office365_connector[0].result}"
  parent_id = azurerm_log_analytics_workspace.sentinel.id

  body = jsonencode({
    kind = "Office365"
    properties = {
      tenantId = data.azurerm_client_config.current.tenant_id
      dataTypes = {
        exchange = {
          state = var.office365_exchange_enabled ? "Enabled" : "Disabled"
        }
        sharepoint = {
          state = var.office365_sharepoint_enabled ? "Enabled" : "Disabled"
        }
        teams = {
          state = var.office365_teams_enabled ? "Enabled" : "Disabled"
        }
      }
    }
  })

  depends_on = [azapi_resource.sentinel]
}

resource "random_uuid" "office365_connector" {
  count = var.enable_office365 ? 1 : 0
}

# Saved Searches for Health Monitoring
resource "azurerm_log_analytics_saved_search" "health_check" {
  name                       = "SentinelHealthCheck"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  category                   = "Sentinel Health"
  display_name              = "Sentinel Health Check"
  
  query = <<-EOT
    union withsource=TableName *
    | where TimeGenerated > ago(24h)
    | summarize Count = count() by TableName
    | where Count > 0
    | order by Count desc
  EOT

  tags = {
    Group = "Sentinel"
  }
}

resource "azurerm_log_analytics_saved_search" "connector_health" {
  name                       = "DataConnectorHealth"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sentinel.id
  category                   = "Sentinel Health"
  display_name              = "Data Connector Health Check"
  
  query = <<-EOT
    union 
    (AzureActivity | where TimeGenerated > ago(1h) | extend Connector = 'AzureActivity'),
    (SigninLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'),
    (AuditLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'),
    (SecurityAlert | where TimeGenerated > ago(1h) | extend Connector = 'SecurityCenter'),
    (OfficeActivity | where TimeGenerated > ago(1h) | extend Connector = 'Office365'),
    (CommonSecurityLog | where TimeGenerated > ago(1h) | extend Connector = 'CommonEventFormat'),
    (Syslog | where TimeGenerated > ago(1h) | extend Connector = 'Syslog')
    | summarize LastReceived = max(TimeGenerated), Count = count() by Connector
    | extend Status = case(Count > 0, 'Healthy', 'No Data')
  EOT

  tags = {
    Group = "Sentinel"
  }
}