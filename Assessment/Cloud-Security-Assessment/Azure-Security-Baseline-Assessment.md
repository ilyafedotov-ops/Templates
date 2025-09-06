# Azure Security Baseline Assessment

## Assessment Overview

This template provides a comprehensive framework for conducting security baseline assessments of Azure environments aligned with the Microsoft Cloud Security Benchmark (MCSB), CIS Azure Foundations Benchmark, and Azure Well-Architected Framework security pillar.

### Assessment Scope
- **Target Environment**: Azure subscription(s) and tenant
- **Framework Alignment**: MCSB v1.0, CIS Azure Foundations v2.0.0, Azure WAF
- **Assessment Duration**: 2-4 weeks depending on environment complexity
- **Required Access**: Security Reader + custom policy assessment permissions

### Key Assessment Areas
1. Identity and Access Management
2. Data Protection and Encryption
3. Logging and Monitoring
4. Network Security and Segmentation
5. Security Management and Governance
6. Asset Management and Inventory
7. Vulnerability Management
8. Incident Response and Recovery

## Pre-Assessment Planning

### Required Tools and Access
```bash
# Azure CLI with security extensions
az extension add --name security
az extension add --name azure-devops
az extension add --name resource-graph

# PowerShell modules
Install-Module -Name Az.Security -Force
Install-Module -Name Az.PolicyInsights -Force
Install-Module -Name Az.Monitor -Force
```

### Environment Discovery
```bash
# Subscription inventory
az account list --query '[].{Name:name, Id:id, State:state}' -o table

# Resource inventory by type and location
az graph query -q "Resources | summarize count() by type, location | order by count_ desc"

# Management group hierarchy
az account management-group list --query '[].{Name:displayName, Id:id}' -o table
```

## MCSB Assessment Framework

### NS (Network Security) Controls

#### NS-1: Establish network segmentation boundaries
**Control Objective**: Implement network micro-segmentation with NSGs and application security groups

**Assessment Procedures**:
```bash
# List all virtual networks and subnets
az network vnet list --query '[].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes}' -o table

# Analyze NSG rules for overly permissive access
az network nsg list --query '[].{Name:name, ResourceGroup:resourceGroup}' -o table
for nsg in $(az network nsg list --query '[].name' -o tsv); do
  echo "=== NSG: $nsg ==="
  az network nsg rule list --nsg-name $nsg --query '[?access==`Allow` && direction==`Inbound`].{Priority:priority, Source:sourceAddressPrefix, Destination:destinationAddressPrefix, Port:destinationPortRange}' -o table
done
```

**Key Findings**:
- [ ] Network segmentation implemented with NSGs
- [ ] Application Security Groups used for micro-segmentation
- [ ] Default deny rules implemented
- [ ] Management plane access restricted
- [ ] Hub-spoke or Virtual WAN topology deployed

#### NS-2: Secure cloud services with network controls
**Assessment Procedures**:
```bash
# Check for public endpoints on PaaS services
az graph query -q "Resources | where type contains 'microsoft.storage/storageaccounts' | extend publicAccess = properties.allowBlobPublicAccess | project name, resourceGroup, publicAccess"

# Private endpoint inventory
az network private-endpoint list --query '[].{Name:name, ResourceGroup:resourceGroup, Subnet:subnet.id}' -o table

# Service endpoint analysis
az network vnet subnet list --vnet-name <vnet-name> --resource-group <rg> --query '[].{Name:name, ServiceEndpoints:serviceEndpoints[].service}' -o table
```

**Key Findings**:
- [ ] Private endpoints deployed for PaaS services
- [ ] Service endpoints configured appropriately
- [ ] Public blob access disabled on storage accounts
- [ ] Azure Firewall or NVA deployed for egress control
- [ ] DDoS Protection Standard enabled

### IM (Identity Management) Controls

#### IM-1: Use centralized identity and authentication system
**Assessment Procedures**:
```bash
# Azure AD Connect health status
az ad connect show

# Conditional access policies
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" --headers "Content-Type=application/json"

# MFA status for admin accounts
az rest --method GET --uri "https://graph.microsoft.com/beta/users?$filter=assignedLicenses/any(x:x/skuId eq 6fd2c87f-b296-42f0-b197-1e91e994b900)&$select=displayName,userPrincipalName,strongAuthenticationMethods" --headers "Content-Type=application/json"
```

**Key Findings**:
- [ ] Azure AD Connect health and sync status
- [ ] Conditional access policies covering all users
- [ ] MFA enabled for all privileged accounts
- [ ] Password protection and banned password lists
- [ ] Identity protection policies active

#### IM-2: Manage application identities securely and automatically
**Assessment Procedures**:
```bash
# Service principal inventory and permissions
az ad sp list --all --query '[].{DisplayName:displayName, AppId:appId, ObjectId:objectId}' -o table

# Managed identity usage analysis
az graph query -q "Resources | where identity has 'type' | extend identityType = identity.type | project name, type, resourceGroup, identityType"

# Key Vault access policies
for kv in $(az keyvault list --query '[].name' -o tsv); do
  echo "=== Key Vault: $kv ==="
  az keyvault show --name $kv --query 'properties.accessPolicies[].{ObjectId:objectId, Permissions:permissions}' -o table
done
```

**Key Findings**:
- [ ] Managed identities used instead of service principals where possible
- [ ] Service principals follow least privilege
- [ ] Certificates used instead of secrets for authentication
- [ ] Regular rotation of authentication credentials
- [ ] Orphaned service principals identified and removed

### DP (Data Protection) Controls

#### DP-1: Discover, classify, and label sensitive data
**Assessment Procedures**:
```bash
# Microsoft Purview data discovery
az purview account list --query '[].{Name:name, ResourceGroup:resourceGroup, Status:provisioningState}' -o table

# SQL database sensitivity labels
az sql db classification list --server <server-name> --database <db-name> --resource-group <rg>

# Storage account encryption status
az storage account list --query '[].{Name:name, Encryption:encryption.services.blob.enabled, KeySource:encryption.keySource}' -o table
```

**Key Findings**:
- [ ] Data discovery and classification tools deployed
- [ ] Sensitive data properly labeled and tagged
- [ ] Data Loss Prevention (DLP) policies active
- [ ] Database sensitivity labels applied
- [ ] Automated data classification workflows

#### DP-2: Monitor anomalous activities and unauthorized data access
**Assessment Procedures**:
```bash
# Advanced Threat Protection status
az security atp storage show --resource-group <rg> --storage-account <account-name>
az sql server threat-policy show --resource-group <rg> --server <server-name>

# Diagnostic settings for data services
az monitor diagnostic-settings list --resource "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account-name>"
```

**Key Findings**:
- [ ] Advanced Threat Protection enabled for storage
- [ ] SQL Advanced Threat Protection active
- [ ] Diagnostic logging enabled for data services
- [ ] Anomaly detection rules configured
- [ ] Data access monitoring dashboards deployed

### LT (Logging and Threat Detection) Controls

#### LT-1: Enable threat detection capabilities
**Assessment Procedures**:
```bash
# Microsoft Defender for Cloud status
az security auto-provisioning-setting list
az security pricing list --query '[].{Name:name, PricingTier:pricingTier}' -o table

# Sentinel workspace configuration
az sentinel workspace list --query '[].{Name:name, ResourceGroup:resourceGroup}' -o table

# Security alerts summary
az security alert list --query '[].{AlertName:alertDisplayName, Severity:reportedSeverity, Status:state}' -o table
```

**Key Findings**:
- [ ] Microsoft Defender for Cloud enabled for all resource types
- [ ] Azure Sentinel deployed and configured
- [ ] Custom detection rules aligned with MITRE ATT&CK
- [ ] Threat intelligence feeds integrated
- [ ] Automated response playbooks active

#### LT-2: Enable security monitoring and logging
**Assessment Procedures**:
```bash
# Activity log diagnostic settings
az monitor diagnostic-settings list --resource "/subscriptions/<subscription-id>"

# Log Analytics workspace configuration
az monitor log-analytics workspace list --query '[].{Name:name, ResourceGroup:resourceGroup, RetentionDays:retentionInDays}' -o table

# Security logs collection status
az monitor diagnostic-settings list --resource-type "Microsoft.KeyVault/vaults"
```

**Key Findings**:
- [ ] Centralized logging with Log Analytics
- [ ] Activity logs forwarded to SIEM
- [ ] Resource diagnostic logs enabled
- [ ] Log retention policies meet compliance requirements
- [ ] Security log correlation and analysis capabilities

### AM (Asset Management) Controls

#### AM-1: Track assets and their configurations
**Assessment Procedures**:
```bash
# Resource inventory with tags
az graph query -q "Resources | project name, type, resourceGroup, location, tags | order by resourceGroup asc"

# Configuration drift detection
az policy state list --filter "ComplianceState eq 'NonCompliant'" --query '[].{ResourceId:resourceId, PolicyDefinition:policyDefinitionId, ComplianceState:complianceState}' -o table

# Update management status
az graph query -q "Resources | where type == 'microsoft.compute/virtualmachines' | extend osType = properties.storageProfile.osDisk.osType | project name, resourceGroup, osType, properties.osProfile.computerName"
```

**Key Findings**:
- [ ] Comprehensive asset inventory maintained
- [ ] Consistent resource tagging strategy
- [ ] Configuration management baseline defined
- [ ] Automated configuration drift detection
- [ ] Asset lifecycle management processes

## CIS Azure Foundations Assessment

### CIS Control 1: Identity and Access Management

#### 1.1 Ensure multi-factor authentication is enabled for all privileged users
```bash
# Check MFA status for Global Administrators
az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles" --headers "Content-Type=application/json" | jq -r '.value[] | select(.displayName=="Global Administrator") | .id' | while read roleId; do
  az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles/$roleId/members" --headers "Content-Type=application/json"
done
```

#### 1.2 Ensure guest users are reviewed on a regular basis
```bash
# List all guest users
az ad user list --filter "userType eq 'Guest'" --query '[].{DisplayName:displayName, UserPrincipalName:userPrincipalName, CreatedDateTime:createdDateTime}' -o table
```

#### 1.3 Ensure application access is reviewed on a regular basis
```bash
# Service principal permissions audit
az ad sp list --all --show-mine --query '[].{DisplayName:displayName, AppRoles:appRoles[].value}' -o table
```

### CIS Control 2: Microsoft Defender for Cloud

#### 2.1 Ensure Microsoft Defender for Cloud is set to the Standard tier
```bash
# Check Defender for Cloud pricing tier
az security pricing show --name "VirtualMachines"
az security pricing show --name "StorageAccounts" 
az security pricing show --name "SqlServers"
az security pricing show --name "KeyVaults"
az security pricing show --name "AppServices"
az security pricing show --name "KubernetesService"
az security pricing show --name "ContainerRegistry"
```

### CIS Control 3: Storage Accounts

#### 3.1 Ensure 'Secure transfer required' is set to 'Enabled'
```bash
# Check secure transfer requirement
az storage account list --query '[].{Name:name, SecureTransfer:enableHttpsTrafficOnly, ResourceGroup:resourceGroup}' -o table
```

#### 3.2 Ensure storage account access keys are periodically regenerated
```bash
# Check storage account key rotation (requires custom tracking)
for account in $(az storage account list --query '[].name' -o tsv); do
  echo "Storage Account: $account"
  az storage account keys list --account-name $account --query '[].{KeyName:keyName, CreationTime:creationTime}' -o table
done
```

## Azure Well-Architected Framework Security Assessment

### Security Design Principles

#### Defense in Depth
- [ ] Multiple security layers implemented (network, identity, application, data)
- [ ] No single point of failure in security architecture
- [ ] Security controls complement each other
- [ ] Redundant security measures where critical

#### Zero Trust Model
```bash
# Conditional access policy coverage
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" --headers "Content-Type=application/json" | jq '.value[].conditions'

# Device compliance status
az rest --method GET --uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies" --headers "Content-Type=application/json"
```

#### Least Privilege Access
```bash
# RBAC assignments analysis
az role assignment list --all --query '[].{PrincipalName:principalName, RoleDefinitionName:roleDefinitionName, Scope:scope}' -o table | head -20

# Custom role definitions
az role definition list --custom-role-only --query '[].{RoleName:roleName, Actions:permissions[0].actions[0:3], NotActions:permissions[0].notActions[0:3]}' -o table
```

### Security Monitoring and Analytics

#### Logging Strategy Assessment
```bash
# Diagnostic settings coverage
az monitor diagnostic-settings list --resource-type "Microsoft.Compute/virtualMachines" | jq '.value[].properties.logs[]'
az monitor diagnostic-settings list --resource-type "Microsoft.Network/networkSecurityGroups" | jq '.value[].properties.logs[]'
az monitor diagnostic-settings list --resource-type "Microsoft.KeyVault/vaults" | jq '.value[].properties.logs[]'
```

#### Security Metrics and KPIs
- Security incident MTTR (Mean Time To Respond)
- Security alert false positive rate
- Compliance posture score trends
- Vulnerability remediation SLAs
- Identity risk score improvements

## Automated Assessment Scripts

### Comprehensive Security Baseline Check
```bash
#!/bin/bash
# Azure Security Baseline Assessment Script

SUBSCRIPTION_ID=$1
RESOURCE_GROUP=${2:-""}

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Usage: $0 <subscription-id> [resource-group]"
    exit 1
fi

echo "=== Azure Security Baseline Assessment ==="
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Assessment Date: $(date)"
echo

# Set active subscription
az account set --subscription $SUBSCRIPTION_ID

# Identity and Access Assessment
echo "=== Identity and Access Management ==="
echo "Checking MFA status for privileged accounts..."
az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles" --headers "Content-Type=application/json" > /tmp/roles.json

echo "Conditional Access Policies:"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" --headers "Content-Type=application/json" | jq -r '.value[].displayName'

# Network Security Assessment
echo "=== Network Security ==="
echo "Virtual Networks and Subnets:"
az network vnet list --query '[].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes}' -o table

echo "Network Security Groups with permissive rules:"
az network nsg list --query '[].name' -o tsv | while read nsg; do
    dangerous_rules=$(az network nsg rule list --nsg-name $nsg --query '[?access==`Allow` && direction==`Inbound` && sourceAddressPrefix==`*`]' -o tsv 2>/dev/null | wc -l)
    if [ $dangerous_rules -gt 0 ]; then
        echo "⚠️  NSG $nsg has $dangerous_rules potentially dangerous rules"
    fi
done

# Storage Security Assessment
echo "=== Data Protection ==="
echo "Storage Account Security Configuration:"
az storage account list --query '[].{Name:name, HttpsOnly:enableHttpsTrafficOnly, PublicAccess:allowBlobPublicAccess, MinTls:minimumTlsVersion}' -o table

# Key Vault Security
echo "Key Vault Configuration:"
az keyvault list --query '[].{Name:name, PurgeProtection:properties.enablePurgeProtection, SoftDelete:properties.enableSoftDelete}' -o table

# Defender for Cloud Status
echo "=== Security Monitoring ==="
echo "Microsoft Defender for Cloud Pricing Tiers:"
az security pricing list --query '[].{Name:name, PricingTier:pricingTier}' -o table

echo "Security Alerts (Last 30 days):"
az security alert list --query 'length(@)' -o tsv | xargs echo "Total alerts:"

echo "=== Assessment Complete ==="
echo "Detailed findings should be reviewed manually for compliance gaps."
```

### Policy Compliance Report
```powershell
# PowerShell script for detailed policy compliance
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    [string]$OutputPath = "."
)

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Get policy compliance summary
$complianceData = Get-AzPolicyState -Filter "ComplianceState eq 'NonCompliant'" | 
    Group-Object PolicyDefinitionId | 
    Select-Object @{Name='PolicyDefinition';Expression={$_.Name}}, 
                  @{Name='NonCompliantResources';Expression={$_.Count}}

# Export to CSV
$complianceData | Export-Csv -Path "$OutputPath/policy-compliance-report.csv" -NoTypeInformation

# Generate HTML report
$html = @"
<html>
<head><title>Azure Security Baseline Assessment Report</title></head>
<body>
<h1>Azure Security Baseline Assessment</h1>
<h2>Policy Compliance Summary</h2>
<table border="1">
<tr><th>Policy Definition</th><th>Non-Compliant Resources</th></tr>
"@

$complianceData | ForEach-Object {
    $html += "<tr><td>$($_.PolicyDefinition)</td><td>$($_.NonCompliantResources)</td></tr>"
}

$html += "</table></body></html>"
$html | Out-File -FilePath "$OutputPath/security-assessment-report.html"

Write-Host "Reports generated in $OutputPath"
```

## Risk Assessment and Scoring

### Risk Matrix
| Risk Level | Score Range | Description | Action Required |
|------------|-------------|-------------|-----------------|
| Critical | 9-10 | Immediate security threat | Remediate within 24 hours |
| High | 7-8 | Significant risk exposure | Remediate within 1 week |
| Medium | 4-6 | Moderate risk | Remediate within 1 month |
| Low | 1-3 | Minimal risk | Include in next maintenance cycle |

### Scoring Methodology
```python
# Risk scoring algorithm
def calculate_security_risk_score(finding):
    base_score = finding.severity_level  # 1-10 scale
    
    # Risk amplification factors
    exposure_multiplier = {
        'internet_facing': 1.5,
        'internal_only': 1.0,
        'management_plane': 2.0
    }.get(finding.exposure, 1.0)
    
    data_sensitivity_multiplier = {
        'public': 1.0,
        'internal': 1.2,
        'confidential': 1.5,
        'restricted': 2.0
    }.get(finding.data_classification, 1.0)
    
    # Business impact factors
    business_impact = {
        'low': 1.0,
        'medium': 1.3,
        'high': 1.6,
        'critical': 2.0
    }.get(finding.business_impact, 1.0)
    
    # Calculate final score
    final_score = min(base_score * exposure_multiplier * data_sensitivity_multiplier * business_impact, 10)
    
    return round(final_score, 1)
```

## Remediation Guidance

### High Priority Remediations

#### Enable Microsoft Defender for Cloud Standard Tier
```bash
# Enable Defender for all resource types
az security pricing create --name "VirtualMachines" --tier "Standard"
az security pricing create --name "StorageAccounts" --tier "Standard"
az security pricing create --name "SqlServers" --tier "Standard"
az security pricing create --name "KeyVaults" --tier "Standard"
az security pricing create --name "AppServices" --tier "Standard"
az security pricing create --name "KubernetesService" --tier "Standard"
```

#### Configure Activity Log Forwarding
```bash
# Create diagnostic setting for activity log
az monitor diagnostic-settings create \
    --name "ActivityLogToLAW" \
    --resource "/subscriptions/$SUBSCRIPTION_ID" \
    --workspace "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.OperationalInsights/workspaces/$WORKSPACE" \
    --logs '[
        {
            "category": "Administrative",
            "enabled": true,
            "retentionPolicy": {
                "enabled": true,
                "days": 365
            }
        },
        {
            "category": "Security",
            "enabled": true,
            "retentionPolicy": {
                "enabled": true,
                "days": 365
            }
        }
    ]'
```

#### Implement Network Segmentation
```bash
# Create Network Security Group with default deny
az network nsg create --name "NSG-Web-Tier" --resource-group $RG --location $LOCATION

# Add restrictive inbound rules
az network nsg rule create \
    --name "Allow-HTTPS-Inbound" \
    --nsg-name "NSG-Web-Tier" \
    --resource-group $RG \
    --priority 100 \
    --source-address-prefixes "Internet" \
    --destination-port-ranges "443" \
    --access "Allow" \
    --protocol "Tcp"

az network nsg rule create \
    --name "Deny-All-Inbound" \
    --nsg-name "NSG-Web-Tier" \
    --resource-group $RG \
    --priority 4000 \
    --access "Deny" \
    --protocol "*"
```

## Report Template

### Executive Summary
Based on the Azure Security Baseline Assessment conducted on [DATE], the following key findings have been identified:

**Overall Security Posture**: [RATING]/10
- Critical findings: [COUNT]
- High risk findings: [COUNT]  
- Medium risk findings: [COUNT]
- Low risk findings: [COUNT]

**Top Risk Areas**:
1. [RISK AREA 1] - [BRIEF DESCRIPTION]
2. [RISK AREA 2] - [BRIEF DESCRIPTION]
3. [RISK AREA 3] - [BRIEF DESCRIPTION]

**Immediate Actions Required**:
- [CRITICAL ACTION 1]
- [CRITICAL ACTION 2]
- [CRITICAL ACTION 3]

### Compliance Status
| Framework | Compliant Controls | Total Controls | Compliance % |
|-----------|-------------------|----------------|--------------|
| MCSB v1.0 | [X] | [Y] | [Z]% |
| CIS Azure Foundations v2.0.0 | [X] | [Y] | [Z]% |
| Azure WAF Security | [X] | [Y] | [Z]% |

### Detailed Findings
[Detailed findings would be populated here with specific technical details, evidence, and remediation guidance for each identified security gap or compliance deviation.]

## Post-Assessment Activities

### Remediation Tracking
- Create Azure DevOps work items for each finding
- Assign owners and due dates based on risk priority
- Track remediation progress with weekly status updates
- Validate fix effectiveness before closure

### Continuous Monitoring Setup
- Deploy custom Azure Policy definitions for ongoing compliance
- Configure automated security scanning in CI/CD pipelines
- Establish security metrics dashboards
- Schedule regular re-assessments (quarterly recommended)

### Knowledge Transfer
- Document architecture decisions and security rationale
- Train operations team on new security tooling
- Establish runbooks for incident response procedures
- Create security awareness materials for development teams