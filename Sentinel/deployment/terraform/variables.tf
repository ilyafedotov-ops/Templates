# General Configuration
variable "resource_group_name" {
  description = "Name of the resource group for Sentinel resources"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US 2"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East",
      "North Europe", "West Europe", "UK South", "UK West",
      "France Central", "Germany West Central", "Norway East",
      "Switzerland North", "Switzerland West",
      "Japan East", "Japan West", "Korea Central", "Korea South",
      "Australia East", "Australia Southeast", "Australia Central",
      "Southeast Asia", "East Asia",
      "Central India", "South India", "West India",
      "Brazil South", "South Africa North"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Purpose     = "SecurityMonitoring"
    Owner       = "SecurityTeam"
    Project     = "Sentinel"
  }
}

# Log Analytics Workspace Configuration
variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.workspace_name))
    error_message = "Workspace name must be between 4-63 characters, start and end with alphanumeric, contain only alphanumeric and hyphens."
  }
}

variable "workspace_sku" {
  description = "SKU for the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.workspace_sku)
    error_message = "Workspace SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "retention_in_days" {
  description = "Number of days to retain data in the workspace"
  type        = number
  default     = 90
  
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion limit in GB. Set to -1 for unlimited"
  type        = number
  default     = -1
  
  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 1
    error_message = "Daily quota must be -1 (unlimited) or >= 1 GB."
  }
}

variable "permanently_delete_workspace" {
  description = "Whether to permanently delete workspace on destroy (cannot be recovered)"
  type        = bool
  default     = false
}

# Data Connector Configuration
variable "enable_azure_activity" {
  description = "Enable Azure Activity Log data connector"
  type        = bool
  default     = true
}

variable "enable_azure_ad" {
  description = "Enable Azure Active Directory data connector"
  type        = bool
  default     = true
}

variable "enable_security_center" {
  description = "Enable Microsoft Defender for Cloud data connector"
  type        = bool
  default     = true
}

variable "enable_office365" {
  description = "Enable Office 365 data connector"
  type        = bool
  default     = true
}

variable "enable_identity_protection" {
  description = "Enable Azure AD Identity Protection data connector (requires P2 license)"
  type        = bool
  default     = false
}

# Office 365 Data Types
variable "office365_exchange_enabled" {
  description = "Enable Exchange Online logs in Office 365 connector"
  type        = bool
  default     = true
}

variable "office365_sharepoint_enabled" {
  description = "Enable SharePoint Online logs in Office 365 connector"
  type        = bool
  default     = true
}

variable "office365_teams_enabled" {
  description = "Enable Microsoft Teams logs in Office 365 connector"
  type        = bool
  default     = true
}

# Storage Account Configuration
variable "enable_long_term_storage" {
  description = "Enable storage account for long-term log retention and export"
  type        = bool
  default     = false
}

variable "storage_account_name" {
  description = "Name of the storage account for long-term retention"
  type        = string
  default     = ""
  
  validation {
    condition = var.storage_account_name == "" || (
      length(var.storage_account_name) >= 3 &&
      length(var.storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access storage account"
  type        = list(string)
  default     = []
}

# Network Configuration
variable "enable_private_endpoints" {
  description = "Enable private endpoints for secure connectivity"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = ""
}

# Diagnostics Configuration
variable "enable_workspace_diagnostics" {
  description = "Enable diagnostic settings for the Log Analytics workspace"
  type        = bool
  default     = true
}

# Custom Log Sources Configuration
variable "custom_log_sources" {
  description = "List of custom log sources to configure with Data Collection Rules"
  type = list(object({
    name          = string
    file_patterns = list(string)
    transform_kql = string
  }))
  default = []
  
  # Example:
  # [
  #   {
  #     name          = "WebServerLogs"
  #     file_patterns = ["/var/log/nginx/*.log", "/var/log/apache2/*.log"]
  #     transform_kql = "source | project TimeGenerated=now(), RawData"
  #   }
  # ]
}

# Multi-Cloud Configuration
variable "aws_cloudtrail_config" {
  description = "AWS CloudTrail configuration for multi-cloud monitoring"
  type = object({
    enabled     = bool
    role_arn    = string
    external_id = string
    s3_bucket   = string
    sqs_queue   = string
  })
  default = {
    enabled     = false
    role_arn    = ""
    external_id = ""
    s3_bucket   = ""
    sqs_queue   = ""
  }
}

variable "gcp_audit_config" {
  description = "GCP Audit Logs configuration for multi-cloud monitoring"
  type = object({
    enabled           = bool
    project_id        = string
    pubsub_topic      = string
    service_account   = string
    subscription_name = string
  })
  default = {
    enabled           = false
    project_id        = ""
    pubsub_topic      = ""
    service_account   = ""
    subscription_name = ""
  }
}

# Cost Management
variable "cost_alert_threshold" {
  description = "Monthly cost threshold in USD for alerts"
  type        = number
  default     = 1000
}

variable "enable_cost_alerts" {
  description = "Enable cost alerts for the Sentinel deployment"
  type        = bool
  default     = true
}

# Automation Configuration
variable "enable_automation_account" {
  description = "Enable Azure Automation Account for runbooks and playbooks"
  type        = bool
  default     = false
}

variable "automation_account_name" {
  description = "Name of the Azure Automation Account"
  type        = string
  default     = ""
}