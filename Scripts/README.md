# Scripts Documentation

Comprehensive automation scripts for deploying and managing Azure security assessments.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Core Deployment Scripts](#core-deployment-scripts)
- [Policy Management Scripts](#policy-management-scripts)
- [Sentinel Configuration Scripts](#sentinel-configuration-scripts)
- [Assessment & Reporting Scripts](#assessment--reporting-scripts)
- [Utility Scripts](#utility-scripts)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
| Tool | Version | Purpose | Installation |
|------|---------|---------|-------------|
| **Azure CLI** | >= 2.50.0 | Azure resource management | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| **jq** | >= 1.6 | JSON processing | `sudo apt-get install jq` or `brew install jq` |
| **GitHub CLI** | >= 2.0 | GitHub operations | `brew install gh` or see [cli.github.com](https://cli.github.com) |
| **yq** | >= 4.0 | YAML processing | `brew install yq` or `pip install yq` |
| **PowerShell** | >= 7.0 | Azure modules | `brew install --cask powershell` |

### Azure Requirements
- Active Azure subscription
- Appropriate RBAC roles:
  - **Owner** or **Contributor** at subscription/management group level
  - **User Access Administrator** for role assignments
  - **Security Admin** for Security Center operations
- Resources:
  - Log Analytics workspace (for Sentinel)
  - Storage account (for logs/exports)
  - Key Vault (for secrets)

### Authentication
```bash
# Azure CLI authentication
az login
az account set --subscription "<subscription-id>"

# Service Principal authentication (for automation)
az login --service-principal \
  --username $AZURE_CLIENT_ID \
  --password $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# GitHub CLI authentication
gh auth login
```

## Core Deployment Scripts

### deploy-baseline.sh
**Purpose**: Deploys complete security baseline including policies, Sentinel rules, and monitoring.

**Usage**:
```bash
./Scripts/deploy-baseline.sh \
  --scope <scope> \
  --resource-group <rg-name> \
  --workspace <workspace-name> \
  [--location <region>] \
  [--include-builtins true|false] \
  [--dry-run]
```

**Parameters**:
| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `--scope` | Yes | Deployment scope | `/subscriptions/{id}` or `/providers/Microsoft.Management/managementGroups/{mg-id}` |
| `--resource-group` | Yes | Resource group name | `rg-security-assessment` |
| `--workspace` | Yes | Log Analytics workspace | `law-security-001` |
| `--location` | No | Azure region (default: eastus) | `westeurope` |
| `--include-builtins` | No | Include Azure built-in policies | `true` or `false` |
| `--dry-run` | No | Preview changes without deploying | Flag only |

**Example**:
```bash
# Production deployment
./Scripts/deploy-baseline.sh \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012" \
  --resource-group "rg-security-prod" \
  --workspace "law-security-prod" \
  --location "eastus2" \
  --include-builtins true

# Dry run for testing
./Scripts/deploy-baseline.sh \
  --scope "/subscriptions/12345678-1234-1234-1234-123456789012" \
  --resource-group "rg-security-test" \
  --workspace "law-security-test" \
  --dry-run
```

**What it deploys**:
1. Custom Azure Policy definitions (15+ policies)
2. Policy initiative (security baseline)
3. Policy assignments with parameters
4. Sentinel analytics rules (10+ rules)
5. Sentinel playbooks (3+ automations)
6. Security workbooks (dashboards)
7. Diagnostic settings
8. Activity log alerts

## Policy Management Scripts

### resolve-builtins.sh
**Purpose**: Fetches Azure built-in policy definition IDs and resolves placeholders in initiative templates.

**Usage**:
```bash
./Scripts/resolve-builtins.sh \
  [--input <initiative-file>] \
  [--output <resolved-file>]
```

**Example**:
```bash
# Default usage
./Scripts/resolve-builtins.sh

# Custom files
./Scripts/resolve-builtins.sh \
  --input "Policies/initiatives/custom-initiative.json" \
  --output "Policies/initiatives/custom-initiative.resolved.json"
```

### deploy-policies.sh
**Purpose**: Deploy only Azure Policy definitions and initiatives without other components.

**Usage**:
```bash
./Scripts/deploy-policies.sh \
  --definition-path <path> \
  --initiative-path <path> \
  --assignment-scope <scope> \
  [--parameters <file>]
```

**Example**:
```bash
./Scripts/deploy-policies.sh \
  --definition-path "./Policies/definitions" \
  --initiative-path "./Policies/initiatives" \
  --assignment-scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
  --parameters "./Policies/parameters/prod-params.json"
```

### validate-policies.sh
**Purpose**: Validate policy syntax and test policy evaluation before deployment.

**Usage**:
```bash
./Scripts/validate-policies.sh \
  --policy-path <path> \
  [--test-resource <resource-id>]
```

## Sentinel Configuration Scripts

### deploy-sentinel.sh
**Purpose**: Deploy Microsoft Sentinel analytics rules, playbooks, and workbooks.

**Usage**:
```bash
./Scripts/deploy-sentinel.sh \
  --workspace-id <workspace-resource-id> \
  --resource-group <rg> \
  --analytics-rules <path> \
  --playbooks <path> \
  [--workbooks <path>]
```

**Example**:
```bash
./Scripts/deploy-sentinel.sh \
  --workspace-id "/subscriptions/.../workspaces/law-security-001" \
  --resource-group "rg-security-ops" \
  --analytics-rules "./Sentinel/analytics/*.json" \
  --playbooks "./Sentinel/playbooks/*.json" \
  --workbooks "./Sentinel/workbooks/*.json"
```

### configure-connectors.sh
**Purpose**: Configure Sentinel data connectors for various sources.

**Usage**:
```bash
./Scripts/configure-connectors.sh \
  --workspace <name> \
  --resource-group <rg> \
  --connector-type <type> \
  [--config-file <file>]
```

**Supported connector types**:
- `azure-activity`: Azure Activity logs
- `azure-ad`: Azure Active Directory
- `defender`: Microsoft Defender for Cloud
- `office365`: Office 365 audit logs
- `threat-intelligence`: Threat intelligence platforms

## Assessment & Reporting Scripts

### generate-compliance-report.sh
**Purpose**: Generate compliance assessment reports for ISO 27001 or SOC 2.

**Usage**:
```bash
./Scripts/generate-compliance-report.sh \
  --framework <iso27001|soc2> \
  --output <file> \
  [--format <pdf|xlsx|json>] \
  [--include-evidence]
```

**Example**:
```bash
# ISO 27001 report with evidence
./Scripts/generate-compliance-report.sh \
  --framework iso27001 \
  --output "ISO27001-Assessment-$(date +%Y%m%d).pdf" \
  --format pdf \
  --include-evidence

# SOC 2 JSON export
./Scripts/generate-compliance-report.sh \
  --framework soc2 \
  --output "soc2-assessment.json" \
  --format json
```

### check-deployment-status.sh
**Purpose**: Verify deployment status and health of all components.

**Usage**:
```bash
./Scripts/check-deployment-status.sh \
  [--resource-group <rg>] \
  [--verbose]
```

**Output includes**:
- Policy assignment status
- Compliance state summary
- Sentinel rule status
- Workbook deployment status
- Error diagnostics

### export-findings.sh
**Purpose**: Export security findings and assessment results.

**Usage**:
```bash
./Scripts/export-findings.sh \
  --output <file> \
  [--format <csv|json|xlsx>] \
  [--severity <critical|high|medium|low>] \
  [--date-range <days>]
```

## Utility Scripts

### quick-compliance-check.sh
**Purpose**: Run a quick compliance check against deployed policies.

**Usage**:
```bash
./Scripts/quick-compliance-check.sh \
  [--scope <scope>] \
  [--summary]
```

### cleanup-resources.sh
**Purpose**: Remove deployed resources (useful for testing/development).

**Usage**:
```bash
./Scripts/cleanup-resources.sh \
  --resource-group <rg> \
  [--remove-policies] \
  [--remove-sentinel] \
  [--confirm]
```

**Warning**: This is destructive. Always use `--confirm` flag.

### backup-configurations.sh
**Purpose**: Backup current configurations before changes.

**Usage**:
```bash
./Scripts/backup-configurations.sh \
  --output-dir <directory> \
  [--include-policies] \
  [--include-sentinel] \
  [--compress]
```

## Environment Variables

### Required Variables
```bash
export AZURE_SUBSCRIPTION_ID="12345678-1234-1234-1234-123456789012"
export AZURE_TENANT_ID="87654321-4321-4321-4321-210987654321"
export RESOURCE_GROUP="rg-security-assessment"
export LOCATION="eastus2"
export WORKSPACE_NAME="law-security-001"
```

### Optional Variables
```bash
export AZURE_CLIENT_ID="<service-principal-id>"  # For automation
export AZURE_CLIENT_SECRET="<service-principal-secret>"
export KEY_VAULT_NAME="kv-security-001"
export STORAGE_ACCOUNT="stgsecurity001"
export LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
export DRY_RUN="false"   # Set to true for testing
```

### Configuration File
Create `.env` file for persistent configuration:
```bash
# .env file (add to .gitignore)
AZURE_SUBSCRIPTION_ID=12345678-1234-1234-1234-123456789012
RESOURCE_GROUP=rg-security-assessment
LOCATION=eastus2
WORKSPACE_NAME=law-security-001
LOG_LEVEL=INFO
```

Load configuration:
```bash
source .env
```

## Troubleshooting

### Common Issues and Solutions

| Issue | Error Message | Solution |
|-------|---------------|----------|
| **Authentication Failed** | "Please run 'az login'" | Run `az login` and select correct subscription |
| **Insufficient Permissions** | "AuthorizationFailed" | Ensure you have Owner/Contributor role |
| **Resource Not Found** | "ResourceNotFound" | Check resource group and names are correct |
| **Policy Assignment Failed** | "InvalidPolicyDefinition" | Run `resolve-builtins.sh` first |
| **Sentinel Deployment Failed** | "WorkspaceNotFound" | Ensure Log Analytics workspace exists |
| **Script Permission Denied** | "Permission denied" | Run `chmod +x Scripts/*.sh` |
| **JSON Parse Error** | "parse error" | Validate JSON with `jq . < file.json` |
| **Network Timeout** | "Request timeout" | Check network connectivity and retry |

### Debug Mode
Enable debug output for troubleshooting:
```bash
# Set debug mode
export LOG_LEVEL=DEBUG

# Run script with debug
bash -x ./Scripts/deploy-baseline.sh ...

# Verbose Azure CLI output
az --verbose policy assignment create ...
```

### Validation Commands
```bash
# Validate Azure connection
az account show

# Check available subscriptions
az account list --output table

# Verify resource group
az group show --name $RESOURCE_GROUP

# Test policy definition
az policy definition show --name "audit-diagnostic-settings"

# Check Sentinel workspace
az sentinel workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME
```

### Log Files
Scripts create logs in `./logs/` directory:
- `deployment-YYYYMMDD.log`: Main deployment log
- `policy-YYYYMMDD.log`: Policy operations
- `sentinel-YYYYMMDD.log`: Sentinel configuration
- `errors-YYYYMMDD.log`: Error details

View logs:
```bash
# Follow deployment log
tail -f logs/deployment-$(date +%Y%m%d).log

# Check errors
grep ERROR logs/*.log

# Archive old logs
tar -czf logs-archive-$(date +%Y%m).tar.gz logs/*.log
```

## Best Practices

1. **Always run in non-production first**: Test all scripts in dev/test environment
2. **Use dry-run when available**: Preview changes before applying
3. **Backup before changes**: Run `backup-configurations.sh`
4. **Use version control**: Track script modifications
5. **Document customizations**: Note any script modifications
6. **Monitor execution**: Check logs during long-running operations
7. **Use parameter files**: Store complex parameters in JSON files
8. **Implement error handling**: Scripts should handle failures gracefully

## Contributing

To add new scripts:
1. Follow naming convention: `action-resource.sh`
2. Include help text: `--help` flag support
3. Add parameter validation
4. Implement error handling
5. Create log entries
6. Update this documentation
7. Add tests in `Scripts/tests/`

## Support

- Review individual script help: `./Scripts/script-name.sh --help`
- Check [FAQ.md](../FAQ.md) for common questions
- Open issues on [GitHub](https://github.com/your-org/azure-security-assessment-templates/issues)

