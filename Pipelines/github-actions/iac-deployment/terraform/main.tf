terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

  # Remote state configuration for Azure Storage
  backend "azurerm" {
    # Configuration will be provided via backend-config during terraform init
    # storage_account_name = "tfstateXXXXX"
    # container_name      = "tfstate"
    # key                 = "terraform-{environment}.tfstate"
    # resource_group_name = "rg-terraform-state"
  }

  # Alternative: Terraform Cloud backend
  # cloud {
  #   organization = "your-org"
  #   workspaces {
  #     name = "infrastructure-{environment}"
  #   }
  # }

  # Alternative: AWS S3 backend
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "terraform/{environment}.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Data sources
data "azurerm_client_config" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  common_tags = {
    Environment   = var.environment
    ManagedBy     = "Terraform"
    Owner         = var.owner
    Project       = var.project_name
    CostCenter    = var.cost_center
    CreatedDate   = timestamp()
    GitCommit     = var.git_commit
  }
  
  resource_prefix = "${var.project_name}-${var.environment}"
  location_short  = var.location_mapping[var.azure_location]
}

# Random resources for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "admin_password" {
  length  = 24
  special = true
}

#
# Azure Resources
#

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}-${local.location_short}"
  location = var.azure_location
  tags     = local.common_tags
}

# Virtual Network Module
module "azure_network" {
  source = "./modules/azure-network"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  resource_prefix    = local.resource_prefix
  environment        = var.environment
  
  # Network configuration
  vnet_cidr              = var.azure_vnet_cidr
  subnet_configurations  = var.azure_subnet_configurations
  enable_ddos_protection = var.enable_ddos_protection
  
  # Security configuration
  enable_flow_logs    = var.enable_network_flow_logs
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  
  tags = local.common_tags
}

# Storage Module
module "azure_storage" {
  source = "./modules/azure-storage"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  resource_prefix    = local.resource_prefix
  environment        = var.environment
  
  # Storage configuration
  storage_accounts = var.azure_storage_accounts
  enable_private_endpoint = var.enable_storage_private_endpoints
  subnet_id = module.azure_network.private_endpoint_subnet_id
  
  # Security configuration
  enable_advanced_threat_protection = var.enable_storage_threat_protection
  allowed_ip_ranges = var.allowed_ip_ranges
  
  tags = local.common_tags
}

# Key Vault Module
module "azure_key_vault" {
  source = "./modules/azure-key-vault"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  resource_prefix    = local.resource_prefix
  environment        = var.environment
  
  # Key Vault configuration
  tenant_id = data.azurerm_client_config.current.tenant_id
  admin_object_ids = var.key_vault_admin_object_ids
  
  # Security configuration
  enable_rbac_authorization = var.key_vault_enable_rbac
  network_acls = {
    default_action = "Deny"
    ip_rules      = var.allowed_ip_ranges
    virtual_network_subnet_ids = [module.azure_network.private_endpoint_subnet_id]
  }
  
  # Secrets
  secrets = var.key_vault_secrets
  
  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/azure-monitoring"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  resource_prefix    = local.resource_prefix
  environment        = var.environment
  
  # Log Analytics configuration
  log_analytics_sku           = var.log_analytics_sku
  log_analytics_retention_days = var.log_analytics_retention_days
  
  # Application Insights configuration
  enable_application_insights = var.enable_application_insights
  application_type           = var.application_insights_type
  
  # Security Center configuration
  enable_security_center = var.enable_security_center
  security_center_tier   = var.security_center_tier
  security_contact_email = var.security_contact_email
  
  tags = local.common_tags
}

# Azure Kubernetes Service Module (Optional)
module "azure_aks" {
  source = "./modules/azure-aks"
  count  = var.enable_aks ? 1 : 0
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  resource_prefix    = local.resource_prefix
  environment        = var.environment
  
  # AKS configuration
  kubernetes_version    = var.aks_kubernetes_version
  default_node_pool     = var.aks_default_node_pool
  additional_node_pools = var.aks_additional_node_pools
  
  # Network configuration
  vnet_subnet_id         = module.azure_network.aks_subnet_id
  dns_service_ip        = var.aks_dns_service_ip
  service_cidr          = var.aks_service_cidr
  pod_cidr              = var.aks_pod_cidr
  
  # Security configuration
  enable_rbac                    = var.aks_enable_rbac
  azure_policy_enabled          = var.aks_enable_azure_policy
  oms_agent_enabled             = var.aks_enable_oms_agent
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  
  # Identity configuration
  identity_type = var.aks_identity_type
  
  tags = local.common_tags
}

#
# AWS Resources
#

# VPC Module
module "aws_vpc" {
  source = "./modules/aws-vpc"
  
  vpc_name = "${local.resource_prefix}-vpc"
  environment = var.environment
  
  # VPC configuration
  vpc_cidr             = var.aws_vpc_cidr
  availability_zones   = var.aws_availability_zones
  public_subnet_cidrs  = var.aws_public_subnet_cidrs
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  
  # NAT Gateway configuration
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  
  # VPC Flow Logs
  enable_flow_log                      = var.enable_vpc_flow_logs
  flow_log_destination_type           = "cloud-watch-logs"
  flow_log_log_group_retention_in_days = var.flow_log_retention_days
  
  tags = local.common_tags
}

# S3 Module
module "aws_s3" {
  source = "./modules/aws-s3"
  
  bucket_name = "${local.resource_prefix}-s3-${random_string.suffix.result}"
  environment = var.environment
  
  # Bucket configuration
  versioning_enabled = var.s3_versioning_enabled
  encryption_enabled = var.s3_encryption_enabled
  kms_key_id        = module.aws_kms.kms_key_id
  
  # Lifecycle configuration
  lifecycle_rules = var.s3_lifecycle_rules
  
  # Public access configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  # Server access logging
  enable_server_access_logging = var.s3_enable_access_logging
  access_log_bucket           = var.s3_access_log_bucket
  
  tags = local.common_tags
}

# KMS Module
module "aws_kms" {
  source = "./modules/aws-kms"
  
  key_description = "KMS key for ${local.resource_prefix} resources"
  environment     = var.environment
  
  # Key configuration
  key_usage                = "ENCRYPT_DECRYPT"
  key_spec                 = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_deletion_window_days
  enable_key_rotation      = var.kms_enable_key_rotation
  
  # Key policy
  key_administrators = var.kms_key_administrators
  key_users          = var.kms_key_users
  
  # Aliases
  aliases = [
    "${local.resource_prefix}-key",
    "${local.resource_prefix}-${var.environment}"
  ]
  
  tags = local.common_tags
}

# ECS Module (Optional)
module "aws_ecs" {
  source = "./modules/aws-ecs"
  count  = var.enable_ecs ? 1 : 0
  
  cluster_name = "${local.resource_prefix}-ecs"
  environment  = var.environment
  
  # Cluster configuration
  capacity_providers = var.ecs_capacity_providers
  
  # Container Insights
  enable_container_insights = var.ecs_enable_container_insights
  
  # Service configuration
  services = var.ecs_services
  
  # Network configuration
  vpc_id          = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnet_ids
  
  # Security configuration
  enable_execute_command = var.ecs_enable_execute_command
  
  tags = local.common_tags
}

# CloudWatch Dashboard
module "aws_cloudwatch" {
  source = "./modules/aws-cloudwatch"
  
  dashboard_name = "${local.resource_prefix}-dashboard"
  environment    = var.environment
  
  # Dashboard configuration
  widgets = var.cloudwatch_widgets
  
  # Alarms configuration
  alarms = var.cloudwatch_alarms
  sns_topic_arn = module.aws_sns.topic_arn
  
  tags = local.common_tags
}

# SNS Module for notifications
module "aws_sns" {
  source = "./modules/aws-sns"
  
  topic_name  = "${local.resource_prefix}-alerts"
  environment = var.environment
  
  # Topic configuration
  kms_key_id = module.aws_kms.kms_key_id
  
  # Subscriptions
  email_subscriptions = var.sns_email_subscriptions
  
  tags = local.common_tags
}

#
# Security and Compliance
#

# Azure Policy Assignments
resource "azurerm_management_group_policy_assignment" "security_policies" {
  count = length(var.azure_policy_definitions)
  
  name                 = "policy-${local.resource_prefix}-${count.index}"
  management_group_id  = var.azure_management_group_id
  policy_definition_id = var.azure_policy_definitions[count.index].id
  
  parameters = jsonencode(var.azure_policy_definitions[count.index].parameters)
  
  identity {
    type = "SystemAssigned"
  }
  
  location = var.azure_location
}

# AWS Config Rules
module "aws_config" {
  source = "./modules/aws-config"
  
  config_name = "${local.resource_prefix}-config"
  environment = var.environment
  
  # Configuration recorder
  enable_config_recorder = var.enable_aws_config
  
  # S3 Bucket for Config
  config_s3_bucket_name = "${local.resource_prefix}-config-${random_string.suffix.result}"
  
  # Config rules
  config_rules = var.aws_config_rules
  
  # SNS notifications
  sns_topic_arn = module.aws_sns.topic_arn
  
  tags = local.common_tags
}

# Security Groups with least privilege
module "security_groups" {
  source = "./modules/aws-security-groups"
  
  vpc_id      = module.aws_vpc.vpc_id
  environment = var.environment
  
  # Security group configurations
  security_groups = var.security_group_configurations
  
  tags = local.common_tags
}

# Cost Management and Budgets
module "aws_budgets" {
  source = "./modules/aws-budgets"
  
  budgets = var.aws_budgets
  
  # Notification configuration
  sns_topic_arn = module.aws_sns.topic_arn
  
  tags = local.common_tags
}

module "azure_cost_management" {
  source = "./modules/azure-cost-management"
  
  resource_group_id = azurerm_resource_group.main.id
  budgets          = var.azure_budgets
  
  # Notification configuration
  notification_emails = var.budget_notification_emails
  
  tags = local.common_tags
}