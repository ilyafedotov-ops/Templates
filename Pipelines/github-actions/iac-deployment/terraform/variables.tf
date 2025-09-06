# General Configuration
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition = can(regex("^(dev|staging|production)$", var.environment))
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myproject"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps Team"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Engineering"
}

variable "git_commit" {
  description = "Git commit hash for deployment tracking"
  type        = string
  default     = "unknown"
}

# Azure Configuration
variable "azure_location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "location_mapping" {
  description = "Mapping of full location names to short codes"
  type        = map(string)
  default = {
    "East US"         = "eus"
    "East US 2"       = "eus2"
    "West US"         = "wus"
    "West US 2"       = "wus2"
    "Central US"      = "cus"
    "North Central US" = "ncus"
    "South Central US" = "scus"
    "West Central US" = "wcus"
    "Canada Central"  = "cac"
    "Canada East"     = "cae"
    "Brazil South"    = "brs"
    "UK South"        = "uks"
    "UK West"         = "ukw"
    "West Europe"     = "weu"
    "North Europe"    = "neu"
    "France Central"  = "frc"
    "Germany West Central" = "gwc"
    "Switzerland North" = "swn"
    "Norway East"     = "noe"
    "Sweden Central"  = "swc"
  }
}

variable "azure_management_group_id" {
  description = "Azure Management Group ID for policy assignments"
  type        = string
  default     = null
}

# Azure Virtual Network Configuration
variable "azure_vnet_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azure_subnet_configurations" {
  description = "Configuration for Azure subnets"
  type = map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = bool
    service_endpoints                         = list(string)
    delegations = list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = {
    "default" = {
      address_prefixes                          = ["10.0.1.0/24"]
      private_endpoint_network_policies_enabled = false
      service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations                              = []
    }
    "aks" = {
      address_prefixes                          = ["10.0.2.0/23"]
      private_endpoint_network_policies_enabled = false
      service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegations                              = []
    }
    "private-endpoints" = {
      address_prefixes                          = ["10.0.4.0/24"]
      private_endpoint_network_policies_enabled = false
      service_endpoints                         = []
      delegations                              = []
    }
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection for VNet"
  type        = bool
  default     = false
}

variable "enable_network_flow_logs" {
  description = "Enable Network Security Group flow logs"
  type        = bool
  default     = true
}

# Azure Storage Configuration
variable "azure_storage_accounts" {
  description = "Configuration for Azure Storage Accounts"
  type = map(object({
    account_tier             = string
    account_replication_type = string
    account_kind            = string
    access_tier             = string
    enable_versioning       = bool
    enable_soft_delete      = bool
    soft_delete_retention   = number
    containers = list(object({
      name                  = string
      container_access_type = string
    }))
  }))
  default = {
    "primary" = {
      account_tier             = "Standard"
      account_replication_type = "LRS"
      account_kind            = "StorageV2"
      access_tier             = "Hot"
      enable_versioning       = true
      enable_soft_delete      = true
      soft_delete_retention   = 30
      containers = [
        {
          name                  = "data"
          container_access_type = "private"
        }
      ]
    }
  }
}

variable "enable_storage_private_endpoints" {
  description = "Enable private endpoints for storage accounts"
  type        = bool
  default     = true
}

variable "enable_storage_threat_protection" {
  description = "Enable Advanced Threat Protection for storage accounts"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for network access"
  type        = list(string)
  default     = []
}

# Azure Key Vault Configuration
variable "key_vault_admin_object_ids" {
  description = "List of object IDs for Key Vault administrators"
  type        = list(string)
  default     = []
}

variable "key_vault_enable_rbac" {
  description = "Enable RBAC authorization for Key Vault"
  type        = bool
  default     = true
}

variable "key_vault_secrets" {
  description = "Map of secrets to store in Key Vault"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# Azure Monitoring Configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Retention period for Log Analytics workspace"
  type        = number
  default     = 30
}

variable "enable_application_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_type" {
  description = "Application Insights application type"
  type        = string
  default     = "web"
}

variable "enable_security_center" {
  description = "Enable Azure Security Center"
  type        = bool
  default     = true
}

variable "security_center_tier" {
  description = "Azure Security Center tier"
  type        = string
  default     = "Standard"
}

variable "security_contact_email" {
  description = "Email for security notifications"
  type        = string
  default     = ""
}

# Azure Kubernetes Service Configuration
variable "enable_aks" {
  description = "Enable Azure Kubernetes Service"
  type        = bool
  default     = false
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.28.3"
}

variable "aks_default_node_pool" {
  description = "Configuration for AKS default node pool"
  type = object({
    name                = string
    node_count          = number
    vm_size            = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    max_pods           = number
    os_disk_size_gb    = number
    os_disk_type       = string
  })
  default = {
    name                = "default"
    node_count          = 2
    vm_size            = "Standard_D2s_v3"
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 5
    max_pods           = 110
    os_disk_size_gb    = 128
    os_disk_type       = "Managed"
  }
}

variable "aks_additional_node_pools" {
  description = "Additional node pools for AKS cluster"
  type = map(object({
    node_count          = number
    vm_size            = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    max_pods           = number
    os_disk_size_gb    = number
    os_disk_type       = string
    node_labels        = map(string)
    node_taints        = list(string)
  }))
  default = {}
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS cluster"
  type        = string
  default     = "10.0.0.10"
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_pod_cidr" {
  description = "Pod CIDR for AKS cluster"
  type        = string
  default     = "10.244.0.0/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC for AKS cluster"
  type        = bool
  default     = true
}

variable "aks_enable_azure_policy" {
  description = "Enable Azure Policy for AKS cluster"
  type        = bool
  default     = true
}

variable "aks_enable_oms_agent" {
  description = "Enable OMS Agent for AKS cluster"
  type        = bool
  default     = true
}

variable "aks_identity_type" {
  description = "Identity type for AKS cluster"
  type        = string
  default     = "SystemAssigned"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "aws_availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "aws_private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Use one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC Flow Logs"
  type        = number
  default     = 14
}

# AWS S3 Configuration
variable "s3_versioning_enabled" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_encryption_enabled" {
  description = "Enable encryption for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_lifecycle_rules" {
  description = "Lifecycle rules for S3 bucket"
  type = list(object({
    id     = string
    status = string
    transitions = list(object({
      days          = number
      storage_class = string
    }))
    expiration = object({
      days = number
    })
  }))
  default = [
    {
      id     = "default"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 2555 # 7 years
      }
    }
  ]
}

variable "s3_enable_access_logging" {
  description = "Enable server access logging for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_access_log_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

# AWS KMS Configuration
variable "kms_deletion_window_days" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "kms_enable_key_rotation" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}

variable "kms_key_administrators" {
  description = "List of ARNs for KMS key administrators"
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "List of ARNs for KMS key users"
  type        = list(string)
  default     = []
}

# AWS ECS Configuration
variable "enable_ecs" {
  description = "Enable Amazon ECS"
  type        = bool
  default     = false
}

variable "ecs_capacity_providers" {
  description = "List of capacity providers for ECS cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "ecs_enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "ecs_services" {
  description = "ECS services configuration"
  type = map(object({
    task_definition_family = string
    desired_count         = number
    cpu                   = number
    memory                = number
    requires_compatibilities = list(string)
    network_mode          = string
    container_definitions = string
  }))
  default = {}
}

variable "ecs_enable_execute_command" {
  description = "Enable execute command for ECS services"
  type        = bool
  default     = false
}

# AWS CloudWatch Configuration
variable "cloudwatch_widgets" {
  description = "CloudWatch dashboard widgets configuration"
  type        = any
  default     = []
}

variable "cloudwatch_alarms" {
  description = "CloudWatch alarms configuration"
  type = map(object({
    alarm_description   = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name        = string
    namespace          = string
    period             = number
    statistic          = string
    threshold          = number
    alarm_actions      = list(string)
  }))
  default = {}
}

# AWS SNS Configuration
variable "sns_email_subscriptions" {
  description = "List of email addresses for SNS notifications"
  type        = list(string)
  default     = []
}

# Azure Policy Configuration
variable "azure_policy_definitions" {
  description = "List of Azure policy definitions to assign"
  type = list(object({
    id         = string
    parameters = map(any)
  }))
  default = []
}

# AWS Config Configuration
variable "enable_aws_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "aws_config_rules" {
  description = "List of AWS Config rules"
  type = list(object({
    name        = string
    description = string
    source = object({
      owner             = string
      source_identifier = string
    })
    depends_on = list(string)
  }))
  default = [
    {
      name        = "s3-bucket-ssl-requests-only"
      description = "Checks whether S3 buckets have policies that require SSL requests"
      source = {
        owner             = "AWS"
        source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
      }
      depends_on = []
    },
    {
      name        = "encrypted-volumes"
      description = "Checks whether EBS volumes are encrypted"
      source = {
        owner             = "AWS"
        source_identifier = "ENCRYPTED_VOLUMES"
      }
      depends_on = []
    }
  ]
}

# Security Groups Configuration
variable "security_group_configurations" {
  description = "Security group configurations"
  type = map(object({
    description = string
    ingress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  default = {
    "web" = {
      description = "Security group for web servers"
      ingress_rules = [
        {
          description = "HTTP"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTPS"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          description = "All outbound traffic"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

# Budget Configuration
variable "aws_budgets" {
  description = "AWS budget configurations"
  type = map(object({
    budget_type  = string
    limit_amount = string
    limit_unit   = string
    time_unit    = string
    time_period_start = string
    cost_filters = map(list(string))
  }))
  default = {}
}

variable "azure_budgets" {
  description = "Azure budget configurations"
  type = map(object({
    amount     = number
    time_grain = string
    time_period = object({
      start_date = string
      end_date   = string
    })
    notifications = list(object({
      enabled        = bool
      threshold      = number
      operator       = string
      threshold_type = string
      contact_emails = list(string)
    }))
  }))
  default = {}
}

variable "budget_notification_emails" {
  description = "List of email addresses for budget notifications"
  type        = list(string)
  default     = []
}