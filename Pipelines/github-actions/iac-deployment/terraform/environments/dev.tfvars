# Development Environment Configuration
environment    = "dev"
project_name   = "myproject"
owner         = "DevOps Team"
cost_center   = "Engineering"

# Azure Configuration
azure_location = "East US 2"
azure_vnet_cidr = "10.0.0.0/16"

azure_subnet_configurations = {
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

# Development environment - minimal DDoS protection
enable_ddos_protection = false
enable_network_flow_logs = true

# Azure Storage - Development configuration
azure_storage_accounts = {
  "dev" = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind            = "StorageV2"
    access_tier             = "Hot"
    enable_versioning       = false  # Disabled in dev for cost savings
    enable_soft_delete      = true
    soft_delete_retention   = 7      # Shorter retention in dev
    containers = [
      {
        name                  = "development-data"
        container_access_type = "private"
      },
      {
        name                  = "logs"
        container_access_type = "private"
      }
    ]
  }
}

enable_storage_private_endpoints = false  # Disabled in dev for simplicity
enable_storage_threat_protection = false  # Disabled in dev for cost savings

# Key Vault Configuration
key_vault_enable_rbac = true
key_vault_admin_object_ids = [
  # Add your Azure AD user/group object IDs here
]

# Development secrets (use Azure Key Vault in production)
key_vault_secrets = {
  "database-connection-string" = "Server=dev-db;Database=myapp;Integrated Security=true"
  "api-key-development"       = "dev-api-key-placeholder"
}

# Monitoring Configuration - Basic for development
log_analytics_sku = "PerGB2018"
log_analytics_retention_days = 30
enable_application_insights = true
application_insights_type = "web"

# Security Center - Free tier for development
enable_security_center = true
security_center_tier = "Free"
security_contact_email = "devops@company.com"

# AKS Configuration - Disabled by default in dev
enable_aks = false

aks_default_node_pool = {
  name                = "default"
  node_count          = 1          # Single node for dev
  vm_size            = "Standard_B2s"  # Cheaper VM size for dev
  availability_zones  = ["1"]      # Single AZ for dev
  enable_auto_scaling = false      # Disabled for cost control
  min_count          = 1
  max_count          = 2
  max_pods           = 30
  os_disk_size_gb    = 64          # Smaller disk for dev
  os_disk_type       = "Standard_LRS"
}

# AWS Configuration
aws_region = "us-east-1"
aws_vpc_cidr = "10.1.0.0/16"
aws_availability_zones = ["us-east-1a", "us-east-1b"]  # Reduced AZs for dev

aws_public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
aws_private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]

# NAT Gateway - Single for cost savings in dev
enable_nat_gateway = true
single_nat_gateway = true
one_nat_gateway_per_az = false

# VPC Flow Logs with shorter retention
enable_vpc_flow_logs = true
flow_log_retention_days = 7

# S3 Configuration - Development
s3_versioning_enabled = false  # Disabled for cost savings
s3_encryption_enabled = true
s3_enable_access_logging = false  # Disabled in dev

s3_lifecycle_rules = [
  {
    id     = "dev-lifecycle"
    status = "Enabled"
    transitions = [
      {
        days          = 7           # Faster transition in dev
        storage_class = "STANDARD_IA"
      }
    ]
    expiration = {
      days = 30                    # Shorter retention in dev
    }
  }
]

# KMS Configuration
kms_deletion_window_days = 7      # Shorter window for dev
kms_enable_key_rotation = false   # Disabled for simplicity in dev

# ECS Configuration - Disabled in dev
enable_ecs = false

# CloudWatch Configuration - Basic monitoring
cloudwatch_alarms = {
  "high-cpu" = {
    alarm_description   = "High CPU utilization in development"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name        = "CPUUtilization"
    namespace          = "AWS/EC2"
    period             = 300
    statistic          = "Average"
    threshold          = 80
    alarm_actions      = []  # No actions in dev
  }
}

# SNS Configuration
sns_email_subscriptions = [
  "devops@company.com"
]

# Security Groups - Permissive for development
security_group_configurations = {
  "dev-web" = {
    description = "Development web security group"
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
      },
      {
        description = "SSH for development"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]  # VPC only
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
  "dev-database" = {
    description = "Development database security group"
    ingress_rules = [
      {
        description = "MySQL/Aurora"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
      },
      {
        description = "PostgreSQL"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.1.0.0/16"]
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

# AWS Config - Simplified for development
enable_aws_config = true
aws_config_rules = [
  {
    name        = "s3-bucket-ssl-requests-only"
    description = "Checks whether S3 buckets have policies that require SSL requests"
    source = {
      owner             = "AWS"
      source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
    }
    depends_on = []
  }
]

# Budget Configuration - Development limits
aws_budgets = {
  "dev-monthly" = {
    budget_type  = "COST"
    limit_amount = "100"
    limit_unit   = "USD"
    time_unit    = "MONTHLY"
    time_period_start = "2024-01-01_00:00"
    cost_filters = {
      "TagKey" = ["Environment"]
      "TagValue" = ["dev"]
    }
  }
}

azure_budgets = {
  "dev-monthly" = {
    amount     = 50
    time_grain = "Monthly"
    time_period = {
      start_date = "2024-01-01T00:00:00Z"
      end_date   = "2024-12-31T23:59:59Z"
    }
    notifications = [
      {
        enabled        = true
        threshold      = 80
        operator       = "GreaterThan"
        threshold_type = "Actual"
        contact_emails = ["devops@company.com"]
      }
    ]
  }
}

budget_notification_emails = ["devops@company.com"]

# Network Access - Development IP ranges
allowed_ip_ranges = [
  "192.168.1.0/24",  # Office network
  "10.0.0.0/8",      # Private networks
]

# Azure Policy - Basic policies for development
azure_policy_definitions = [
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"  # Secure transfer to storage accounts should be enabled
    parameters = {}
  }
]