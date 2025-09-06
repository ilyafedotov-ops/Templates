# General Outputs
output "deployment_info" {
  description = "Deployment information"
  value = {
    environment     = var.environment
    project_name    = var.project_name
    git_commit      = var.git_commit
    deployment_date = timestamp()
  }
}

output "infrastructure_url" {
  description = "URL to view infrastructure in cloud console"
  value = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource${azurerm_resource_group.main.id}/overview"
}

# Azure Outputs
output "azure_resource_group" {
  description = "Azure Resource Group information"
  value = {
    name     = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    id       = azurerm_resource_group.main.id
  }
}

output "azure_network" {
  description = "Azure Virtual Network information"
  value = {
    vnet_id        = module.azure_network.vnet_id
    vnet_name      = module.azure_network.vnet_name
    subnet_ids     = module.azure_network.subnet_ids
    nsg_ids        = module.azure_network.nsg_ids
  }
  sensitive = false
}

output "azure_storage" {
  description = "Azure Storage Account information"
  value = {
    storage_account_names = module.azure_storage.storage_account_names
    storage_account_ids   = module.azure_storage.storage_account_ids
    primary_endpoints     = module.azure_storage.primary_endpoints
  }
  sensitive = false
}

output "azure_key_vault" {
  description = "Azure Key Vault information"
  value = {
    key_vault_id   = module.azure_key_vault.key_vault_id
    key_vault_name = module.azure_key_vault.key_vault_name
    key_vault_uri  = module.azure_key_vault.key_vault_uri
  }
  sensitive = false
}

output "azure_monitoring" {
  description = "Azure Monitoring information"
  value = {
    log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
    log_analytics_workspace_name = module.monitoring.log_analytics_workspace_name
    application_insights_id      = module.monitoring.application_insights_id
    application_insights_app_id  = module.monitoring.application_insights_app_id
  }
  sensitive = false
}

output "azure_aks" {
  description = "Azure Kubernetes Service information"
  value = var.enable_aks ? {
    cluster_id        = module.azure_aks[0].cluster_id
    cluster_name      = module.azure_aks[0].cluster_name
    cluster_fqdn      = module.azure_aks[0].cluster_fqdn
    kubelet_identity  = module.azure_aks[0].kubelet_identity
    node_resource_group = module.azure_aks[0].node_resource_group
  } : null
  sensitive = false
}

# AWS Outputs
output "aws_vpc" {
  description = "AWS VPC information"
  value = {
    vpc_id               = module.aws_vpc.vpc_id
    vpc_cidr             = module.aws_vpc.vpc_cidr
    public_subnet_ids    = module.aws_vpc.public_subnet_ids
    private_subnet_ids   = module.aws_vpc.private_subnet_ids
    internet_gateway_id  = module.aws_vpc.internet_gateway_id
    nat_gateway_ids      = module.aws_vpc.nat_gateway_ids
  }
}

output "aws_s3" {
  description = "AWS S3 bucket information"
  value = {
    bucket_name         = module.aws_s3.bucket_name
    bucket_id          = module.aws_s3.bucket_id
    bucket_arn         = module.aws_s3.bucket_arn
    bucket_domain_name = module.aws_s3.bucket_domain_name
  }
}

output "aws_kms" {
  description = "AWS KMS key information"
  value = {
    kms_key_id  = module.aws_kms.kms_key_id
    kms_key_arn = module.aws_kms.kms_key_arn
    kms_aliases = module.aws_kms.kms_aliases
  }
  sensitive = false
}

output "aws_ecs" {
  description = "AWS ECS cluster information"
  value = var.enable_ecs ? {
    cluster_id   = module.aws_ecs[0].cluster_id
    cluster_name = module.aws_ecs[0].cluster_name
    cluster_arn  = module.aws_ecs[0].cluster_arn
  } : null
}

output "aws_cloudwatch" {
  description = "AWS CloudWatch information"
  value = {
    dashboard_arn = module.aws_cloudwatch.dashboard_arn
    alarm_arns   = module.aws_cloudwatch.alarm_arns
  }
}

output "aws_sns" {
  description = "AWS SNS topic information"
  value = {
    topic_arn  = module.aws_sns.topic_arn
    topic_name = module.aws_sns.topic_name
  }
  sensitive = false
}

# Security and Compliance Outputs
output "azure_policy_assignments" {
  description = "Azure Policy assignment information"
  value = {
    policy_assignment_ids = [for assignment in azurerm_management_group_policy_assignment.security_policies : assignment.id]
  }
}

output "aws_config" {
  description = "AWS Config information"
  value = {
    config_recorder_name = module.aws_config.config_recorder_name
    config_rules        = module.aws_config.config_rule_names
    config_s3_bucket    = module.aws_config.config_s3_bucket
  }
}

output "security_groups" {
  description = "AWS Security Groups information"
  value = {
    security_group_ids = module.security_groups.security_group_ids
  }
}

# Cost Management Outputs
output "aws_budgets" {
  description = "AWS Budget information"
  value = {
    budget_names = module.aws_budgets.budget_names
    budget_arns  = module.aws_budgets.budget_arns
  }
}

output "azure_budgets" {
  description = "Azure Budget information"
  value = {
    budget_ids = module.azure_cost_management.budget_ids
  }
}

# Connection Strings and Endpoints (Sensitive)
output "azure_storage_connection_strings" {
  description = "Azure Storage Account connection strings"
  value       = module.azure_storage.connection_strings
  sensitive   = true
}

output "azure_key_vault_secrets" {
  description = "Azure Key Vault secret information"
  value       = module.azure_key_vault.secret_ids
  sensitive   = true
}

output "database_connection_strings" {
  description = "Database connection strings"
  value = {
    # Add database connection strings here if databases are deployed
  }
  sensitive = true
}

# Resource Counts for Cost Tracking
output "resource_counts" {
  description = "Count of deployed resources by type"
  value = {
    azure_storage_accounts = length(module.azure_storage.storage_account_names)
    aws_s3_buckets        = 1
    azure_key_vaults      = 1
    aws_kms_keys          = 1
    security_groups       = length(module.security_groups.security_group_ids)
    aks_clusters          = var.enable_aks ? 1 : 0
    ecs_clusters          = var.enable_ecs ? 1 : 0
  }
}

# Health Check Endpoints
output "health_check_endpoints" {
  description = "Health check endpoints for deployed services"
  value = {
    azure_key_vault_status = "https://${module.azure_key_vault.key_vault_name}.vault.azure.net/"
    # Add more health check endpoints as needed
  }
}

# Terraform State Information
output "terraform_state_info" {
  description = "Information about Terraform state"
  value = {
    terraform_version = "1.6.4"
    provider_versions = {
      azurerm = "~> 3.80.0"
      aws     = "~> 5.20.0"
      random  = "~> 3.4.0"
      tls     = "~> 4.0.0"
    }
  }
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    azure_resources = {
      resource_group = azurerm_resource_group.main.name
      location      = var.azure_location
      vnet_cidr     = var.azure_vnet_cidr
      storage_accounts = length(var.azure_storage_accounts)
      subnets       = length(var.azure_subnet_configurations)
    }
    aws_resources = {
      region        = var.aws_region
      vpc_cidr      = var.aws_vpc_cidr
      availability_zones = length(var.aws_availability_zones)
      public_subnets    = length(var.aws_public_subnet_cidrs)
      private_subnets   = length(var.aws_private_subnet_cidrs)
    }
    security_features = {
      azure_key_vault_enabled = true
      aws_kms_enabled        = true
      network_security_groups = true
      azure_policy_enabled   = length(var.azure_policy_definitions) > 0
      aws_config_enabled     = var.enable_aws_config
      monitoring_enabled     = var.enable_application_insights
    }
    optional_services = {
      aks_enabled = var.enable_aks
      ecs_enabled = var.enable_ecs
      budgets_configured = {
        azure = length(var.azure_budgets) > 0
        aws   = length(var.aws_budgets) > 0
      }
    }
  }
}