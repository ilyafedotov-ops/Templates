# Production Environment Configuration
environment    = "production"
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
    service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
    delegations                              = []
  }
  "aks" = {
    address_prefixes                          = ["10.0.2.0/22"]  # Larger subnet for production
    private_endpoint_network_policies_enabled = false
    service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
    delegations                              = []
  }
  "private-endpoints" = {
    address_prefixes                          = ["10.0.8.0/24"]
    private_endpoint_network_policies_enabled = false
    service_endpoints                         = []
    delegations                              = []
  }
  "database" = {
    address_prefixes                          = ["10.0.9.0/24"]
    private_endpoint_network_policies_enabled = false
    service_endpoints                         = ["Microsoft.Sql"]
    delegations = [
      {
        name = "sql-delegation"
        service_delegation = {
          name    = "Microsoft.Sql/managedInstances"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
}

# Production environment - Full security features
enable_ddos_protection = true
enable_network_flow_logs = true

# Azure Storage - Production configuration
azure_storage_accounts = {
  "primary" = {
    account_tier             = "Standard"
    account_replication_type = "GRS"  # Geo-redundant for production
    account_kind            = "StorageV2"
    access_tier             = "Hot"
    enable_versioning       = true
    enable_soft_delete      = true
    soft_delete_retention   = 90     # Extended retention for production
    containers = [
      {
        name                  = "application-data"
        container_access_type = "private"
      },
      {
        name                  = "backups"
        container_access_type = "private"
      },
      {
        name                  = "logs"
        container_access_type = "private"
      }
    ]
  }
  "archive" = {
    account_tier             = "Standard"
    account_replication_type = "GRS"
    account_kind            = "StorageV2"
    access_tier             = "Archive"  # Archive tier for long-term storage
    enable_versioning       = true
    enable_soft_delete      = true
    soft_delete_retention   = 365    # 1 year retention for archives
    containers = [
      {
        name                  = "long-term-archive"
        container_access_type = "private"
      }
    ]
  }
}

enable_storage_private_endpoints = true
enable_storage_threat_protection = true

# Key Vault Configuration - Production security
key_vault_enable_rbac = true
key_vault_admin_object_ids = [
  # Add production Azure AD user/group object IDs here
  # "00000000-0000-0000-0000-000000000000"
]

# Production secrets should be managed through CI/CD or manual process
key_vault_secrets = {
  # Secrets will be added through deployment process
}

# Monitoring Configuration - Production grade
log_analytics_sku = "PerGB2018"
log_analytics_retention_days = 90
enable_application_insights = true
application_insights_type = "web"

# Security Center - Standard tier for production
enable_security_center = true
security_center_tier = "Standard"
security_contact_email = "security@company.com"

# AKS Configuration - Production cluster
enable_aks = true

aks_kubernetes_version = "1.28.3"

aks_default_node_pool = {
  name                = "system"
  node_count          = 3
  vm_size            = "Standard_D4s_v3"  # Production-grade VMs
  availability_zones  = ["1", "2", "3"]
  enable_auto_scaling = true
  min_count          = 3
  max_count          = 10
  max_pods           = 110
  os_disk_size_gb    = 128
  os_disk_type       = "Premium_LRS"  # Premium SSD for production
}

aks_additional_node_pools = {
  "worker" = {
    node_count          = 6
    vm_size            = "Standard_D8s_v3"
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count          = 3
    max_count          = 20
    max_pods           = 110
    os_disk_size_gb    = 256
    os_disk_type       = "Premium_LRS"
    node_labels = {
      "node-type" = "worker"
      "workload"  = "application"
    }
    node_taints = []
  }
  "memory-optimized" = {
    node_count          = 2
    vm_size            = "Standard_E8s_v3"
    availability_zones  = ["1", "2"]
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 5
    max_pods           = 30
    os_disk_size_gb    = 256
    os_disk_type       = "Premium_LRS"
    node_labels = {
      "node-type" = "memory-optimized"
      "workload"  = "data-processing"
    }
    node_taints = ["workload=memory-intensive:NoSchedule"]
  }
}

aks_enable_rbac = true
aks_enable_azure_policy = true
aks_enable_oms_agent = true

# AWS Configuration - Production
aws_region = "us-east-1"
aws_vpc_cidr = "10.1.0.0/16"
aws_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

aws_public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
aws_private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]

# NAT Gateway - High availability for production
enable_nat_gateway = true
single_nat_gateway = false
one_nat_gateway_per_az = true

# VPC Flow Logs with extended retention
enable_vpc_flow_logs = true
flow_log_retention_days = 90

# S3 Configuration - Production
s3_versioning_enabled = true
s3_encryption_enabled = true
s3_enable_access_logging = true

s3_lifecycle_rules = [
  {
    id     = "production-lifecycle"
    status = "Enabled"
    transitions = [
      {
        days          = 30
        storage_class = "STANDARD_IA"
      },
      {
        days          = 90
        storage_class = "GLACIER"
      },
      {
        days          = 365
        storage_class = "DEEP_ARCHIVE"
      }
    ]
    expiration = {
      days = 2555  # 7 years
    }
  }
]

# KMS Configuration - Production security
kms_deletion_window_days = 30
kms_enable_key_rotation = true

# ECS Configuration - Production container platform
enable_ecs = true

ecs_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
ecs_enable_container_insights = true
ecs_enable_execute_command = false  # Disabled for security in production

ecs_services = {
  "web-service" = {
    task_definition_family   = "web-app"
    desired_count           = 3
    cpu                     = 1024
    memory                  = 2048
    requires_compatibilities = ["FARGATE"]
    network_mode           = "awsvpc"
    container_definitions   = jsonencode([
      {
        name  = "web-app"
        image = "nginx:latest"
        portMappings = [
          {
            containerPort = 80
            protocol     = "tcp"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/web-app"
            "awslogs-region"        = "us-east-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
      }
    ])
  }
}

# CloudWatch Configuration - Production monitoring
cloudwatch_alarms = {
  "high-cpu" = {
    alarm_description   = "High CPU utilization in production"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name        = "CPUUtilization"
    namespace          = "AWS/EC2"
    period             = 300
    statistic          = "Average"
    threshold          = 70
    alarm_actions      = ["arn:aws:sns:us-east-1:123456789012:production-alerts"]
  }
  "high-memory" = {
    alarm_description   = "High memory utilization in production"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 3
    metric_name        = "MemoryUtilization"
    namespace          = "AWS/EC2"
    period             = 300
    statistic          = "Average"
    threshold          = 80
    alarm_actions      = ["arn:aws:sns:us-east-1:123456789012:production-alerts"]
  }
  "disk-space" = {
    alarm_description   = "Low disk space in production"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 1
    metric_name        = "DiskSpaceUtilization"
    namespace          = "AWS/EC2"
    period             = 300
    statistic          = "Average"
    threshold          = 20
    alarm_actions      = ["arn:aws:sns:us-east-1:123456789012:production-alerts"]
  }
}

# SNS Configuration - Production notifications
sns_email_subscriptions = [
  "production-alerts@company.com",
  "devops@company.com",
  "sre-team@company.com"
]

# Security Groups - Production security
security_group_configurations = {
  "prod-web" = {
    description = "Production web security group"
    ingress_rules = [
      {
        description = "HTTPS only"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        description = "HTTPS outbound"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "HTTP outbound"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  "prod-database" = {
    description = "Production database security group"
    ingress_rules = [
      {
        description = "MySQL/Aurora from app tier"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
      },
      {
        description = "PostgreSQL from app tier"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
      }
    ]
    egress_rules = []  # No outbound rules for database
  }
  "prod-load-balancer" = {
    description = "Production load balancer security group"
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

# AWS Config - Comprehensive compliance for production
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
  },
  {
    name        = "encrypted-volumes"
    description = "Checks whether EBS volumes are encrypted"
    source = {
      owner             = "AWS"
      source_identifier = "ENCRYPTED_VOLUMES"
    }
    depends_on = []
  },
  {
    name        = "rds-storage-encrypted"
    description = "Checks whether storage encryption is enabled for RDS instances"
    source = {
      owner             = "AWS"
      source_identifier = "RDS_STORAGE_ENCRYPTED"
    }
    depends_on = []
  },
  {
    name        = "cloudtrail-enabled"
    description = "Checks whether CloudTrail is enabled"
    source = {
      owner             = "AWS"
      source_identifier = "CLOUD_TRAIL_ENABLED"
    }
    depends_on = []
  },
  {
    name        = "iam-password-policy"
    description = "Checks whether IAM password policy meets requirements"
    source = {
      owner             = "AWS"
      source_identifier = "IAM_PASSWORD_POLICY"
    }
    depends_on = []
  }
]

# Budget Configuration - Production limits with alerts
aws_budgets = {
  "prod-monthly" = {
    budget_type  = "COST"
    limit_amount = "5000"
    limit_unit   = "USD"
    time_unit    = "MONTHLY"
    time_period_start = "2024-01-01_00:00"
    cost_filters = {
      "TagKey" = ["Environment"]
      "TagValue" = ["production"]
    }
  }
  "prod-quarterly" = {
    budget_type  = "COST"
    limit_amount = "14000"
    limit_unit   = "USD"
    time_unit    = "QUARTERLY"
    time_period_start = "2024-01-01_00:00"
    cost_filters = {
      "TagKey" = ["Environment"]
      "TagValue" = ["production"]
    }
  }
}

azure_budgets = {
  "prod-monthly" = {
    amount     = 3000
    time_grain = "Monthly"
    time_period = {
      start_date = "2024-01-01T00:00:00Z"
      end_date   = "2024-12-31T23:59:59Z"
    }
    notifications = [
      {
        enabled        = true
        threshold      = 50
        operator       = "GreaterThan"
        threshold_type = "Forecasted"
        contact_emails = ["finance@company.com", "devops@company.com"]
      },
      {
        enabled        = true
        threshold      = 80
        operator       = "GreaterThan"
        threshold_type = "Actual"
        contact_emails = ["finance@company.com", "devops@company.com", "management@company.com"]
      },
      {
        enabled        = true
        threshold      = 100
        operator       = "GreaterThan"
        threshold_type = "Actual"
        contact_emails = ["finance@company.com", "devops@company.com", "management@company.com"]
      }
    ]
  }
}

budget_notification_emails = [
  "finance@company.com",
  "devops@company.com",
  "management@company.com"
]

# Network Access - Production restrictions
allowed_ip_ranges = [
  "203.0.113.0/24",  # Corporate public IP range
  "198.51.100.0/24"  # Backup office network
]

# Azure Policy - Comprehensive security policies for production
azure_policy_definitions = [
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"  # Secure transfer to storage accounts should be enabled
    parameters = {}
  },
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/53503636-bcc9-4748-9663-5348217f160f"  # Storage accounts should restrict network access
    parameters = {}
  },
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"  # Storage accounts should have the specified minimum TLS version
    parameters = {
      "minimumTlsVersion" = {
        "value" = "TLS1_2"
      }
    }
  },
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693"  # Enforce SSL connection should be enabled for PostgreSQL database servers
    parameters = {}
  },
  {
    id = "/providers/Microsoft.Authorization/policyDefinitions/e802a67a-daf5-4436-9ea6-f6d821dd0c5d"  # Enforce SSL connection should be enabled for MySQL database servers
    parameters = {}
  }
]