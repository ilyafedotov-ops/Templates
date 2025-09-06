# Infrastructure as Code (IaC) Deployment Pipelines

This repository contains enterprise-grade Infrastructure as Code deployment pipelines for GitHub Actions, supporting Terraform, Azure Bicep, and ARM Templates with comprehensive security, governance, and compliance features.

## 🏗️ Architecture Overview

The IaC deployment pipelines provide:

- **Multi-environment deployment** (dev, staging, production)
- **Remote state management** with Azure Storage, AWS S3, and Terraform Cloud
- **Comprehensive security scanning** with Checkov, tfsec, Terrascan, and OPA
- **Policy as Code enforcement** with Azure Policy and AWS Config
- **Cost estimation and FinOps integration**
- **Drift detection and automated remediation**
- **Compliance validation and reporting**
- **Automated documentation generation**

## 📁 Repository Structure

```
github-actions/iac-deployment/
├── terraform-deploy.yml          # Terraform deployment pipeline
├── bicep-deploy.yml              # Azure Bicep deployment pipeline  
├── arm-template-deploy.yml       # ARM Template deployment pipeline
├── terraform/                    # Terraform configuration
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output definitions
│   ├── environments/             # Environment-specific configs
│   │   ├── dev.tfvars           # Development environment
│   │   ├── staging.tfvars       # Staging environment (template)
│   │   └── production.tfvars    # Production environment
│   ├── modules/                  # Reusable Terraform modules
│   └── policies/                 # OPA/Sentinel policies
├── bicep/                        # Azure Bicep templates
│   ├── main.bicep               # Main Bicep template
│   └── parameters/              # Environment parameters
│       ├── dev.json             # Development parameters
│       ├── staging.json         # Staging parameters
│       └── production.json      # Production parameters
└── arm-templates/                # ARM templates directory
    ├── main.json                # Main ARM template
    └── parameters/              # ARM template parameters
```

## 🚀 Quick Start

### Prerequisites

1. **GitHub Repository Setup**
   - Fork or clone this repository
   - Set up GitHub environments (dev, staging, production)
   - Configure environment protection rules and approvals

2. **Azure Prerequisites** (for Bicep/ARM)
   - Azure subscription with appropriate permissions
   - Azure AD application for OIDC authentication
   - Azure Storage Account for Terraform state (if using Terraform)
   - Log Analytics workspace for monitoring

3. **AWS Prerequisites** (for Terraform AWS resources)
   - AWS account with appropriate IAM permissions
   - AWS IAM role for OIDC authentication
   - S3 bucket for Terraform state (optional)
   - DynamoDB table for state locking (optional)

### GitHub Secrets Configuration

Configure the following secrets in your GitHub repository:

#### Azure Secrets
```bash
AZURE_CLIENT_ID           # Azure AD App Registration Client ID
AZURE_TENANT_ID           # Azure AD Tenant ID  
AZURE_SUBSCRIPTION_ID     # Azure Subscription ID
TF_STATE_STORAGE_ACCOUNT  # Storage account for Terraform state
TF_STATE_CONTAINER        # Container name for Terraform state
TF_STATE_RESOURCE_GROUP   # Resource group for state storage
```

#### AWS Secrets
```bash
AWS_ROLE_ARN              # AWS IAM Role ARN for OIDC
```

#### Optional Secrets
```bash
INFRACOST_API_KEY         # Infracost API key for cost estimation
TEAMS_WEBHOOK_URL         # Microsoft Teams webhook for notifications
```

### Environment Configuration

Each pipeline supports three environments with different configurations:

- **Development**: Cost-optimized, permissive security, single-region
- **Staging**: Production-like, moderate security, disaster recovery testing
- **Production**: High availability, maximum security, multi-region

## 🔧 Pipeline Usage

### Terraform Deployment Pipeline

The Terraform pipeline (`terraform-deploy.yml`) provides comprehensive Infrastructure as Code deployment with:

#### Features
- **Multi-cloud support** (Azure + AWS)
- **Remote state management** with Azure Storage backend
- **Security scanning** with Checkov, tfsec, Terrascan
- **Policy validation** with OPA/Sentinel
- **Cost estimation** with Infracost
- **Drift detection** and automated remediation
- **Module testing** capabilities

#### Trigger the Pipeline

**Manual Deployment:**
```bash
# Go to GitHub Actions → Terraform Enterprise Deployment Pipeline
# Click "Run workflow" and select:
# - Environment: dev/staging/production  
# - Action: plan/apply/destroy/drift-detect
# - Cost threshold: USD amount for approval gate
```

**Automatic Triggers:**
- Push to `main` branch (auto-applies to dev)
- Pull request to `main` (runs plan and validation)
- Push to Terraform files triggers validation

#### Sample Commands

```bash
# Plan deployment to staging
gh workflow run "Terraform Enterprise Deployment Pipeline" \
  -f environment=staging \
  -f terraform_action=plan \
  -f cost_threshold=2000

# Apply to production (requires approval)
gh workflow run "Terraform Enterprise Deployment Pipeline" \
  -f environment=production \
  -f terraform_action=apply \
  -f cost_threshold=5000

# Detect configuration drift
gh workflow run "Terraform Enterprise Deployment Pipeline" \
  -f environment=production \
  -f terraform_action=drift-detect
```

### Bicep Deployment Pipeline

The Bicep pipeline (`bicep-deploy.yml`) provides Azure-native Infrastructure as Code:

#### Features
- **Azure-optimized** deployment pipeline
- **What-If analysis** for change preview
- **PSRule for Azure** security analysis
- **Azure Policy compliance** validation
- **Cost estimation** based on resources
- **Private endpoint support**

#### Trigger the Pipeline

```bash
# Manual deployment
gh workflow run "Azure Bicep Deployment Pipeline" \
  -f environment=production \
  -f bicep_action=deploy \
  -f cost_threshold=500

# What-if analysis only
gh workflow run "Azure Bicep Deployment Pipeline" \
  -f environment=staging \
  -f bicep_action=what-if
```

### ARM Template Deployment Pipeline

The ARM Template pipeline (`arm-template-deploy.yml`) provides traditional Azure deployment:

#### Features
- **ARM Template Toolkit (ARM-TTK)** validation
- **Incremental and Complete** deployment modes
- **Template parameter validation**
- **Resource health checks**
- **Deployment rollback** capabilities

#### Trigger the Pipeline

```bash
# Deploy ARM templates
gh workflow run "ARM Template Deployment Pipeline" \
  -f environment=dev \
  -f arm_action=deploy \
  -f deployment_mode=Incremental

# Validate templates only  
gh workflow run "ARM Template Deployment Pipeline" \
  -f environment=staging \
  -f arm_action=validate
```

## 🛡️ Security Features

### Security Scanning Tools

| Tool | Purpose | Pipeline | Threshold |
|------|---------|----------|-----------|
| **Checkov** | IaC security analysis | All | Configurable |
| **tfsec** | Terraform security scanner | Terraform | High/Critical |
| **Terrascan** | Multi-IaC security scanner | Terraform | Medium+ |
| **PSRule** | Azure-specific rules | Bicep | Recommendations |
| **ARM-TTK** | ARM template validation | ARM | Best practices |
| **OPA** | Policy as Code validation | Terraform | Custom policies |

### Security Gates

1. **Pre-deployment Validation**
   - Syntax and schema validation
   - Security vulnerability scanning
   - Policy compliance checks
   - Cost threshold validation

2. **Deployment Gates**
   - Environment-specific approvals
   - Manual approval for production
   - Cost limit enforcement
   - Change review requirements

3. **Post-deployment Validation**
   - Resource deployment verification
   - Configuration drift detection
   - Compliance posture assessment
   - Monitoring setup validation

## 💰 Cost Management

### FinOps Integration

- **Infracost** integration for Terraform cost estimation
- **Azure Cost Management** budgets and alerts
- **AWS Budgets** with notification thresholds
- **Resource tagging** for cost allocation
- **Cost optimization** recommendations

### Budget Configuration

**Development Environment:**
- Monthly limit: $50-100
- Alert at 80% threshold
- Basic monitoring

**Production Environment:**
- Monthly limit: $3000-5000
- Multi-level alerts (50%, 80%, 100%)
- Detailed cost breakdown by service

## 🔍 Monitoring and Observability

### Deployed Monitoring Stack

- **Azure Log Analytics** workspace
- **Application Insights** for application monitoring
- **Azure Security Center** for security posture
- **AWS CloudWatch** dashboards and alarms
- **VPC Flow Logs** for network monitoring

### Alerting Configuration

- **Microsoft Teams** notifications
- **Email alerts** for budget thresholds
- **GitHub status** updates
- **Security incident** notifications

## 🏛️ Governance and Compliance

### Policy as Code

**Azure Policy Definitions:**
- Secure transfer for storage accounts
- Network access restrictions
- Minimum TLS version enforcement
- SSL connection requirements

**AWS Config Rules:**
- S3 bucket SSL requirements
- EBS volume encryption
- RDS storage encryption
- CloudTrail enablement
- IAM password policies

### Compliance Frameworks

- **ISO 27001** control mapping
- **SOC 2** compliance checks  
- **CIS Benchmarks** validation
- **PCI DSS** considerations

## 📊 Terraform Configuration

### Multi-Cloud Architecture

The Terraform configuration deploys a comprehensive multi-cloud infrastructure:

#### Azure Resources
- **Resource Groups** with proper tagging
- **Virtual Networks** with security groups
- **Storage Accounts** with private endpoints
- **Key Vault** with RBAC and network restrictions
- **Log Analytics** and Application Insights
- **Azure Kubernetes Service** (optional)
- **Azure Policy** assignments

#### AWS Resources  
- **VPC** with public/private subnets
- **S3 buckets** with encryption and lifecycle policies
- **KMS keys** with rotation enabled
- **ECS clusters** with Fargate support (optional)
- **CloudWatch** dashboards and alarms
- **AWS Config** rules for compliance
- **Security Groups** with least privilege

### Environment Configuration

#### Development (`dev.tfvars`)
- **Cost-optimized** resource sizing
- **Minimal redundancy** (LRS storage, single AZ)
- **Relaxed security** for development productivity
- **Shorter retention** periods
- **Simplified monitoring**

#### Production (`production.tfvars`)
- **High availability** configuration
- **Geo-redundant** storage (GRS)
- **Maximum security** controls
- **Extended retention** periods
- **Comprehensive monitoring**
- **Multi-region** deployment

### Remote State Management

**Azure Storage Backend:**
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "tfstateXXXXX"
    container_name      = "tfstate"  
    key                 = "terraform-{environment}.tfstate"
    resource_group_name = "rg-terraform-state"
  }
}
```

**AWS S3 Backend (Alternative):**
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform/{environment}.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 🔄 CI/CD Integration

### Pipeline Flow

1. **Code Push/PR** → Trigger pipeline
2. **Validation Stage** → Syntax, security, policy checks
3. **Plan Stage** → Generate deployment plan
4. **Cost Analysis** → Estimate infrastructure costs
5. **Approval Gate** → Manual approval for production
6. **Deploy Stage** → Apply infrastructure changes
7. **Validation Stage** → Verify deployment success
8. **Notification** → Send status updates

### Branch Strategy

- **main**: Production deployments (auto-deploy to dev)
- **develop**: Development deployments
- **feature/***: PR validation only
- **hotfix/***: Emergency production fixes

### Approval Gates

**Development:** Auto-deployment
**Staging:** Auto-deployment from main branch
**Production:** Manual approval required + cost threshold check

## 📈 Advanced Features

### Drift Detection

Automatically detects configuration drift between deployed infrastructure and Terraform state:

```yaml
# Schedule drift detection
- cron: '0 6 * * 1-5'  # Weekdays at 6 AM UTC

# Manual drift detection
terraform_action: drift-detect
```

### Module Testing

Supports automated testing of Terraform modules:

```bash
# Install Terratest dependencies
go mod init terratest
go get github.com/gruntwork-io/terratest

# Run module tests
go test -v -timeout 30m ./test/
```

### Documentation Generation

Automatically generates and updates documentation:

```bash
# Terraform documentation
terraform-docs markdown table --output-file TERRAFORM.md .

# Bicep documentation  
az bicep generate-params --file main.bicep --output-format json
```

## 🚨 Troubleshooting

### Common Issues

**State Lock Issues:**
```bash
# Force unlock Terraform state
terraform force-unlock LOCK_ID

# Azure Backend
az storage blob lease break --container-name tfstate --name terraform.tflock
```

**Permission Issues:**
```bash
# Azure RBAC
az role assignment create --assignee $AZURE_CLIENT_ID --role Contributor --scope $AZURE_SUBSCRIPTION_ID

# AWS IAM  
aws iam attach-role-policy --role-name GitHubActions --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

**Pipeline Failures:**
- Check environment secrets configuration
- Verify OIDC trust relationships
- Review resource quotas and limits
- Check network connectivity and firewall rules

### Debug Commands

```bash
# Terraform debugging
export TF_LOG=DEBUG
terraform plan -var-file=environments/dev.tfvars

# Azure CLI debugging  
az config set core.only_show_errors=false
az deployment group create --debug

# GitHub CLI debugging
gh api repos/:owner/:repo/actions/runs/:run_id --paginate
```

## 🔐 Security Best Practices

### Secret Management

1. **Use GitHub Secrets** for sensitive values
2. **Rotate secrets regularly** (quarterly minimum)
3. **Principle of least privilege** for service accounts
4. **Audit secret access** through GitHub audit logs

### Network Security

1. **Private endpoints** for Azure services
2. **VPC endpoints** for AWS services  
3. **Network Security Groups** with minimal rules
4. **Firewall rules** for production environments

### Access Control

1. **RBAC** for all cloud resources
2. **Conditional access** policies
3. **Multi-factor authentication** required
4. **Regular access reviews** (quarterly)

## 📚 Additional Resources

### Documentation Links

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [ARM Template Reference](https://docs.microsoft.com/en-us/azure/templates/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### Security Tools

- [Checkov](https://www.checkov.io/) - Infrastructure security scanner
- [tfsec](https://github.com/aquasecurity/tfsec) - Terraform security scanner
- [Terrascan](https://github.com/accurics/terrascan) - Multi-cloud security scanner
- [Open Policy Agent](https://www.openpolicyagent.org/) - Policy as Code engine

### Cost Management

- [Infracost](https://www.infracost.io/) - Cloud cost estimation
- [Azure Cost Management](https://docs.microsoft.com/en-us/azure/cost-management-billing/)
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes in development environment
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Development Guidelines

- Follow IaC best practices and naming conventions
- Add comprehensive tests for new modules
- Update documentation for configuration changes
- Ensure security scanning passes before merging
- Test in development environment before production

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions, issues, or contributions:

- **GitHub Issues**: [Create an issue](https://github.com/your-org/iac-pipelines/issues)
- **Documentation**: Check this README and inline code comments
- **Security Issues**: Report privately to security@company.com

---

**🚀 Happy Infrastructure Coding!** 🚀