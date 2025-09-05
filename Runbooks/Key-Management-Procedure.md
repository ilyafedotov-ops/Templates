# Cryptographic Key Management Operational Runbook

## Document Control
- **Version**: 2.0
- **Classification**: CONFIDENTIAL - Internal Use Only
- **Owner**: Information Security Team
- **Approved By**: Chief Information Security Officer
- **Review Cycle**: Annual
- **Last Updated**: 2024-12-01
- **Next Review**: 2025-12-01

## Executive Summary

This operational runbook establishes comprehensive procedures for cryptographic key management in Azure cloud environments, ensuring compliance with ISO 27001:2022, SOC 2 Type II, NIST Cybersecurity Framework, and FIPS 140-2 standards. The procedures cover the complete key lifecycle from generation through destruction, supporting both Azure Key Vault and Azure Dedicated HSM services.

## 1. Scope and Applicability

### 1.1 Coverage
This runbook applies to all cryptographic keys, certificates, and secrets used across:
- Azure Key Vault instances (Standard and Premium tiers)
- Azure Dedicated HSM deployments
- Azure Managed HSM pools
- Application-level cryptographic implementations
- Certificate Authority (CA) integrations
- Third-party cryptographic service integrations

### 1.2 Key Types in Scope
- **Encryption Keys**: Data encryption keys (DEK), key encryption keys (KEK)
- **Signing Keys**: Digital signatures, code signing, document signing
- **Authentication Keys**: Service principal certificates, API keys
- **Transport Keys**: TLS/SSL certificates, VPN keys
- **Root Keys**: Certificate Authority root and intermediate keys
- **Recovery Keys**: BitLocker, backup encryption keys

### 1.3 Regulatory Alignment
- **ISO 27001:2022**: Controls A.10.1.1, A.10.1.2, A.14.1.2, A.14.1.3
- **SOC 2 Type II**: Trust Service Criteria CC6.1, CC6.7
- **NIST CSF**: PR.DS-1, PR.DS-2, PR.AC-1, DE.CM-1
- **FIPS 140-2**: Level 2/3 HSM requirements
- **Common Criteria**: EAL4+ for high-assurance environments

## 2. Key Classification and Protection Levels

### 2.1 Classification Matrix

| Classification | Description | Protection Level | Storage | Examples |
|---------------|-------------|------------------|---------|----------|
| **ULTRA** | Nation-state secrets, root CA keys | HSM FIPS 140-2 L3 | Dedicated HSM | Root signing keys |
| **SECRET** | Financial data, PHI encryption | HSM FIPS 140-2 L2 | Managed HSM | Database TDE keys |
| **CONFIDENTIAL** | Business-critical data | Premium Key Vault | Premium KV + HSM | Application secrets |
| **RESTRICTED** | Internal systems | Standard Key Vault | Standard KV | Service certificates |
| **PUBLIC** | Public verification | Standard storage | Any compliant | Public key certificates |

### 2.2 Protection Level Requirements

#### ULTRA Classification
- **Generation**: Dedicated HSM with hardware-based entropy
- **Storage**: FIPS 140-2 Level 3 HSM with tamper evidence
- **Access**: Minimum 3-person authorization (3 of 5 quorum)
- **Backup**: Secure offline storage in geographically separated facilities
- **Rotation**: Manual process with executive approval
- **Audit**: Real-time monitoring with immediate alerting

#### SECRET Classification
- **Generation**: Managed HSM or Premium Key Vault HSM
- **Storage**: FIPS 140-2 Level 2 HSM
- **Access**: 2-person authorization (2 of 3 quorum)
- **Backup**: Encrypted backup with separate key management
- **Rotation**: Automated with manual approval gates
- **Audit**: Continuous monitoring with daily review

#### CONFIDENTIAL Classification
- **Generation**: Premium Key Vault with HSM backing
- **Storage**: Azure Key Vault Premium with HSM
- **Access**: Role-based with break-glass procedures
- **Backup**: Automated with soft-delete protection
- **Rotation**: Fully automated with exception handling
- **Audit**: Weekly audit log review

## 3. Key Generation Procedures

### 3.1 Key Generation Standards

#### Entropy Requirements
```bash
# Verify HSM entropy source
az keyvault key show-deleted --vault-name "kv-ultra-prod" --name "root-ca-key" --query "attributes.hsm"

# Validate key strength
openssl rsa -in private_key.pem -text -noout | grep "Private-Key"
```

#### Cryptographic Standards
- **RSA Keys**: Minimum 2048-bit (3072-bit recommended, 4096-bit for ULTRA)
- **ECC Keys**: P-256 minimum (P-384 recommended, P-521 for ULTRA)
- **Symmetric Keys**: AES-256 (AES-128 acceptable for RESTRICTED only)
- **Hash Functions**: SHA-256 minimum (SHA-3 preferred for new implementations)

### 3.2 Azure Key Vault Key Generation

#### Standard Key Creation
```powershell
# Create RSA key in Premium Key Vault with HSM backing
$keyParams = @{
    VaultName = "kv-confidential-prod"
    Name = "app-encryption-key-$(Get-Date -Format 'yyyyMMdd')"
    Destination = "HSM"
    KeyType = "RSA"
    Size = 3072
    KeyOps = @("encrypt", "decrypt", "sign", "verify")
    Expires = (Get-Date).AddYears(2)
    NotBefore = Get-Date
    Tags = @{
        Classification = "CONFIDENTIAL"
        Owner = "application-team"
        Environment = "production"
        Purpose = "data-encryption"
        Compliance = "iso27001,soc2"
    }
}
Add-AzKeyVaultKey @keyParams
```

#### HSM Key Generation for HIGH/ULTRA Classifications
```bash
# Generate key in Dedicated HSM
az dedicated-hsm create-key \
    --resource-group "rg-hsm-prod" \
    --hsm-name "hsm-ultra-001" \
    --key-name "master-signing-key" \
    --key-type "RSA" \
    --key-size 4096 \
    --extractable false \
    --classification "ULTRA" \
    --quorum-requirement 3
```

### 3.3 Dual Control Key Generation

#### Two-Person Integrity Process
1. **Requestor** initiates key generation request via ServiceNow
2. **Approver** reviews and approves based on classification requirements
3. **Key Custodian 1** generates key using approved parameters
4. **Key Custodian 2** verifies key attributes and activates
5. **Security Team** validates compliance and documents in key register

```yaml
# Azure DevOps Pipeline for Dual Control
- task: AzureKeyVault@2
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  inputs:
    azureSubscription: 'Security-HSM-Connection'
    KeyVaultName: 'kv-approvals-prod'
    SecretsFilter: 'dual-control-token'
    RunAsPreJob: false
  displayName: 'Retrieve Dual Control Token'

- task: PowerShell@2
  inputs:
    script: |
      # Validate dual approval before key creation
      $approvals = Get-Content "approvals.json" | ConvertFrom-Json
      if ($approvals.count -lt 2) { throw "Insufficient approvals for key generation" }
```

## 4. Key Storage and Protection

### 4.1 Azure Key Vault Configuration

#### Premium Key Vault Setup
```json
{
  "sku": {
    "family": "A",
    "name": "premium"
  },
  "properties": {
    "enabledForDeployment": false,
    "enabledForDiskEncryption": false,
    "enabledForTemplateDeployment": false,
    "enableSoftDelete": true,
    "enablePurgeProtection": true,
    "softDeleteRetentionInDays": 90,
    "enableRbacAuthorization": true,
    "publicNetworkAccess": "Disabled",
    "networkAcls": {
      "defaultAction": "Deny",
      "bypass": "AzureServices",
      "virtualNetworkRules": [],
      "ipRules": []
    }
  }
}
```

#### Managed HSM Pool Configuration
```bash
# Create Managed HSM for SECRET classification keys
az keyvault create \
    --resource-group "rg-security-prod" \
    --name "hsm-secret-001" \
    --hsm-name "hsm-pool-prod" \
    --administrators "user1@company.com" "user2@company.com" \
    --location "East US 2" \
    --retention-days 90 \
    --enable-purge-protection true
```

### 4.2 Access Control Matrix

#### Role Definitions
```json
{
  "KeyVaultCryptographicOfficer": {
    "permissions": {
      "keys": ["create", "delete", "get", "list", "update", "import", "backup", "restore"],
      "secrets": [],
      "certificates": ["create", "delete", "get", "list", "update", "import"]
    },
    "principalTypes": ["User"],
    "minimumApprovers": 2
  },
  "KeyVaultKeyUser": {
    "permissions": {
      "keys": ["get", "list", "encrypt", "decrypt", "sign", "verify"],
      "secrets": [],
      "certificates": ["get", "list"]
    },
    "principalTypes": ["User", "ServicePrincipal"],
    "minimumApprovers": 1
  }
}
```

#### Segregation of Duties Matrix
| Role | Create Keys | Delete Keys | Rotate Keys | Backup Keys | Audit Access |
|------|-------------|-------------|-------------|-------------|--------------|
| **Crypto Officer** | ✓ | ✓ (with approval) | ✓ | ✓ | ✗ |
| **Key Custodian** | ✓ | ✗ | ✓ | ✓ | ✗ |
| **Application Owner** | ✗ | ✗ | Request only | ✗ | ✗ |
| **Security Auditor** | ✗ | ✗ | ✗ | ✗ | ✓ |
| **Break Glass Admin** | ✓ | ✓ | ✓ | ✓ | ✓ |

## 5. Key Distribution and Deployment

### 5.1 Secure Key Distribution

#### Application Integration Pattern
```csharp
// Secure key retrieval in applications
public class SecureKeyManager
{
    private readonly DefaultAzureCredential _credential;
    private readonly SecretClient _secretClient;
    
    public SecureKeyManager(string keyVaultUri)
    {
        _credential = new DefaultAzureCredential();
        _secretClient = new SecretClient(new Uri(keyVaultUri), _credential);
    }
    
    public async Task<byte[]> GetEncryptionKeyAsync(string keyName, string version = null)
    {
        try
        {
            var response = await _secretClient.GetSecretAsync(keyName, version);
            LogKeyAccess(keyName, "Retrieved", success: true);
            return Convert.FromBase64String(response.Value.Value);
        }
        catch (Exception ex)
        {
            LogKeyAccess(keyName, "Failed Retrieval", success: false, error: ex.Message);
            throw;
        }
    }
}
```

#### Infrastructure as Code Distribution
```terraform
# Secure key distribution via Terraform
resource "azurerm_key_vault_access_policy" "app_access" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app.principal_id

  key_permissions = [
    "Get",
    "List",
    "Encrypt",
    "Decrypt"
  ]
}

data "azurerm_key_vault_secret" "encryption_key" {
  name         = "app-encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  
  depends_on = [azurerm_key_vault_access_policy.app_access]
}
```

### 5.2 Key Provisioning Automation

#### Azure DevOps Pipeline for Key Deployment
```yaml
stages:
- stage: KeyProvisioning
  displayName: 'Secure Key Provisioning'
  jobs:
  - job: ValidateAndDeploy
    pool:
      vmImage: 'windows-latest'
    steps:
    - task: AzurePowerShell@5
      displayName: 'Deploy Application Keys'
      inputs:
        azureSubscription: 'Security-Service-Connection'
        ScriptType: 'InlineScript'
        Inline: |
          # Validate key requirements
          $keySpec = Get-Content 'key-requirements.json' | ConvertFrom-Json
          
          foreach ($key in $keySpec.keys) {
              # Verify approval exists
              if (-not (Get-KeyApproval -KeyName $key.name)) {
                  throw "No approval found for key: $($key.name)"
              }
              
              # Create or update key
              $params = @{
                  VaultName = $key.vault
                  Name = $key.name
                  KeyType = $key.type
                  Size = $key.size
                  Destination = $key.protection
              }
              
              New-AzKeyVaultKey @params
              Write-Output "Successfully provisioned key: $($key.name)"
          }
```

## 6. Key Rotation Procedures

### 6.1 Rotation Schedule Matrix

| Key Type | Classification | Rotation Interval | Method | Approval Required |
|----------|---------------|-------------------|--------|-------------------|
| Root CA Keys | ULTRA | 10-15 years | Manual | Executive + Board |
| Intermediate CA | SECRET | 3-5 years | Manual | C-Level |
| TLS Certificates | CONFIDENTIAL | 13 months | Automated | Team Lead |
| Database TDE | SECRET | 2 years | Automated | Security Team |
| Application Keys | CONFIDENTIAL | 1 year | Automated | System |
| API Keys | RESTRICTED | 6 months | Automated | System |
| Service Tokens | RESTRICTED | 90 days | Automated | System |

### 6.2 Automated Rotation Implementation

#### Key Vault Automatic Rotation
```json
{
  "rotationPolicy": {
    "lifetimeActions": [
      {
        "trigger": {
          "timeBeforeExpiry": "P30D"
        },
        "action": {
          "type": "Rotate"
        }
      },
      {
        "trigger": {
          "timeBeforeExpiry": "P7D"
        },
        "action": {
          "type": "Notify"
        }
      }
    ],
    "attributes": {
      "expiryTime": "P1Y"
    }
  }
}
```

#### Azure Function for Custom Rotation Logic
```csharp
[FunctionName("KeyRotationOrchestrator")]
public static async Task<IActionResult> Run(
    [TimerTrigger("0 0 2 * * MON")] TimerInfo timer, // Weekly on Monday 2 AM
    ILogger log)
{
    var keyClient = new KeyClient(new Uri(Environment.GetEnvironmentVariable("KeyVaultUri")), 
                                  new DefaultAzureCredential());
    
    var keysToRotate = await GetKeysNearExpiry(keyClient, TimeSpan.FromDays(30));
    
    foreach (var key in keysToRotate)
    {
        try
        {
            // Pre-rotation validation
            await ValidateKeyRotationEligibility(key);
            
            // Create new version
            var newKey = await keyClient.CreateRsaKeyAsync(key.Name, new CreateRsaKeyOptions
            {
                KeySize = 3072,
                HardwareProtected = true,
                ExpiresOn = DateTimeOffset.Now.AddYears(1)
            });
            
            // Update dependent applications
            await NotifyDependentServices(key.Name, newKey.Value.Id);
            
            // Audit rotation
            await LogKeyRotation(key.Name, "SUCCESS", newKey.Value.Id);
            
            log.LogInformation($"Successfully rotated key: {key.Name}");
        }
        catch (Exception ex)
        {
            await LogKeyRotation(key.Name, "FAILED", null, ex.Message);
            await SendAlertToSecurityTeam(key.Name, ex);
        }
    }
    
    return new OkResult();
}
```

### 6.3 Manual Rotation Procedures

#### High-Value Key Rotation Process
1. **Pre-Rotation Phase** (T-30 days)
   - Security team reviews rotation requirements
   - Stakeholder notifications sent
   - Dependency mapping validated
   - Backup procedures verified

2. **Rotation Execution Phase**
   ```powershell
   # Execute manual rotation with dual control
   $rotationRequest = @{
       KeyName = "master-encryption-key"
       RequestedBy = $env:USERNAME
       ApprovedBy = Read-Host "Enter approver username"
       Justification = Read-Host "Enter rotation justification"
   }
   
   # Validate approver authority
   if (-not (Test-UserAuthority -User $rotationRequest.ApprovedBy -Action "KeyRotation")) {
       throw "Insufficient authority for key rotation approval"
   }
   
   # Execute rotation
   $newKey = Add-AzKeyVaultKey -VaultName "kv-ultra-prod" -Name $rotationRequest.KeyName
   ```

3. **Post-Rotation Phase** (T+7 days)
   - Application connectivity validation
   - Performance impact assessment
   - Security monitoring review
   - Old key version deactivation

## 7. Certificate Lifecycle Management

### 7.1 Certificate Authority Integration

#### Internal CA Configuration
```powershell
# Configure Azure Key Vault as Certificate Authority
$caConfig = @{
    Name = "CompanyInternalCA"
    IssuerProvider = "OnPremiseCA" # or "DigiCert", "GlobalSign"
    AdminDetails = @{
        FirstName = "Security"
        LastName = "Team"
        EmailAddress = "security@company.com"
        Phone = "+1-555-0123"
        Organization = "Company Inc"
        OrganizationUnit = "Information Security"
    }
    Credentials = @{
        CertificateId = "ca-integration-cert"
        Password = "$(Get-AzKeyVaultSecret -VaultName 'kv-ca-prod' -Name 'ca-password')"
    }
}

Set-AzKeyVaultCertificateIssuer -VaultName "kv-certificates-prod" @caConfig
```

#### Certificate Template Configuration
```json
{
  "certificatePolicy": {
    "secretProperties": {
      "contentType": "application/x-pkcs12"
    },
    "keyProperties": {
      "exportable": false,
      "keyType": "RSA",
      "keySize": 3072,
      "reuseKey": false,
      "curve": null
    },
    "x509CertificateProperties": {
      "subject": "CN={{cert-name}}.company.com",
      "subjectAlternativeNames": {
        "dnsNames": ["{{cert-name}}.company.com", "{{cert-name}}.internal.company.com"],
        "emails": [],
        "upns": []
      },
      "keyUsage": ["digitalSignature", "keyEncipherment"],
      "extendedKeyUsage": ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"],
      "validityInMonths": 13
    },
    "lifetimeActions": [{
      "trigger": {
        "daysBeforeExpiry": 30
      },
      "action": {
        "actionType": "AutoRenew"
      }
    }],
    "issuerParameters": {
      "name": "CompanyInternalCA",
      "certificateType": "OV-SSL"
    }
  }
}
```

### 7.2 PKI Management Operations

#### Certificate Enrollment Automation
```bash
#!/bin/bash
# Automated certificate enrollment script

CERT_NAME=$1
ENVIRONMENT=$2
CLASSIFICATION=$3

# Validate inputs
if [[ -z "$CERT_NAME" || -z "$ENVIRONMENT" || -z "$CLASSIFICATION" ]]; then
    echo "Usage: $0 <cert-name> <environment> <classification>"
    exit 1
fi

# Determine Key Vault based on classification
case $CLASSIFICATION in
    "ULTRA")
        VAULT_NAME="kv-ultra-${ENVIRONMENT}"
        KEY_SIZE=4096
        ;;
    "SECRET")
        VAULT_NAME="kv-secret-${ENVIRONMENT}"
        KEY_SIZE=3072
        ;;
    "CONFIDENTIAL")
        VAULT_NAME="kv-confidential-${ENVIRONMENT}"
        KEY_SIZE=3072
        ;;
    *)
        VAULT_NAME="kv-standard-${ENVIRONMENT}"
        KEY_SIZE=2048
        ;;
esac

# Create certificate with appropriate policy
az keyvault certificate create \
    --vault-name "$VAULT_NAME" \
    --name "$CERT_NAME" \
    --policy @certificate-policy-${CLASSIFICATION,,}.json \
    --tags "environment=$ENVIRONMENT" "classification=$CLASSIFICATION" \
           "created-by=$USER" "created-date=$(date -I)"

# Verify certificate creation
if az keyvault certificate show --vault-name "$VAULT_NAME" --name "$CERT_NAME" &>/dev/null; then
    echo "Certificate $CERT_NAME successfully created in $VAULT_NAME"
    
    # Register in certificate inventory
    ./scripts/register-certificate.sh "$CERT_NAME" "$VAULT_NAME" "$CLASSIFICATION"
else
    echo "Failed to create certificate $CERT_NAME"
    exit 1
fi
```

## 8. Access Controls and Authorization

### 8.1 Azure RBAC Implementation

#### Custom Role Definitions
```json
{
  "Name": "Key Vault Cryptographic Officer",
  "Id": "12345678-1234-1234-1234-123456789012",
  "IsCustom": true,
  "Description": "Can manage cryptographic keys but cannot access secrets or certificates",
  "Actions": [
    "Microsoft.KeyVault/vaults/keys/read",
    "Microsoft.KeyVault/vaults/keys/write",
    "Microsoft.KeyVault/vaults/keys/delete",
    "Microsoft.KeyVault/vaults/keys/backup/action",
    "Microsoft.KeyVault/vaults/keys/restore/action",
    "Microsoft.KeyVault/vaults/keys/update/action",
    "Microsoft.KeyVault/vaults/keys/create/action",
    "Microsoft.KeyVault/vaults/keys/import/action"
  ],
  "NotActions": [
    "Microsoft.KeyVault/vaults/secrets/*",
    "Microsoft.KeyVault/vaults/certificates/*/action",
    "Microsoft.KeyVault/vaults/keys/purge/action"
  ],
  "DataActions": [
    "Microsoft.KeyVault/vaults/keys/encrypt/action",
    "Microsoft.KeyVault/vaults/keys/decrypt/action",
    "Microsoft.KeyVault/vaults/keys/sign/action",
    "Microsoft.KeyVault/vaults/keys/verify/action"
  ],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/{subscription-id}/resourceGroups/rg-security-prod"
  ]
}
```

### 8.2 Privileged Access Management

#### Just-In-Time (JIT) Access Implementation
```powershell
# JIT access request for key operations
function Request-KeyVaultJITAccess {
    param(
        [Parameter(Mandatory=$true)][string]$KeyVaultName,
        [Parameter(Mandatory=$true)][string]$AccessLevel,
        [Parameter(Mandatory=$true)][string]$Justification,
        [Parameter(Mandatory=$true)][int]$DurationHours,
        [Parameter(Mandatory=$true)][string]$ApproverEmail
    )
    
    $requestId = [Guid]::NewGuid().ToString()
    
    $accessRequest = @{
        RequestId = $requestId
        KeyVault = $KeyVaultName
        AccessLevel = $AccessLevel
        Justification = $Justification
        Duration = $DurationHours
        RequestedBy = $env:USERNAME
        RequestedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Status = "Pending"
    }
    
    # Store request in approval system
    $accessRequest | ConvertTo-Json | Out-File "access-requests/$requestId.json"
    
    # Send approval notification
    Send-MailMessage -To $ApproverEmail -Subject "Key Vault Access Request - $requestId" -Body @"
A new Key Vault access request requires your approval:

Request ID: $requestId
Key Vault: $KeyVaultName
Access Level: $AccessLevel
Requested By: $($env:USERNAME)
Duration: $DurationHours hours
Justification: $Justification

To approve or deny, please visit: https://security.company.com/approvals/$requestId
"@
    
    Write-Output "Access request submitted. Request ID: $requestId"
}
```

### 8.3 Break Glass Access Procedures

#### Emergency Access Protocol
```yaml
# Break Glass Access Runbook
EmergencyAccess:
  Triggers:
    - Production system down due to key access issues
    - Security incident requiring immediate key access
    - Compliance audit with tight deadlines
    - Disaster recovery activation
    
  Authorization:
    Level1: Security Team Lead + Application Owner
    Level2: CISO + CTO (for ULTRA classified keys)
    Level3: CEO approval (for root CA keys)
    
  Process:
    1. Emergency declared via incident management system
    2. Break glass account activated with temporary access
    3. All actions logged with video recording requirement
    4. 15-minute maximum session duration
    5. Immediate post-incident review scheduled
    
  Technical Implementation:
    Account: "emergency-crypto-admin@company.com"
    MFA: Hardware token + biometric
    Network: Secure admin jump box only
    Logging: Real-time SIEM alerts + video capture
```

## 9. Audit Logging and Monitoring

### 9.1 Comprehensive Audit Configuration

#### Azure Monitor Configuration
```json
{
  "diagnosticSettings": {
    "name": "key-vault-audit-logging",
    "properties": {
      "workspaceId": "/subscriptions/{subscription-id}/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-security",
      "logs": [
        {
          "category": "AuditEvent",
          "enabled": true,
          "retentionPolicy": {
            "enabled": true,
            "days": 2555
          }
        },
        {
          "category": "AzurePolicyEvaluationDetails",
          "enabled": true,
          "retentionPolicy": {
            "enabled": true,
            "days": 365
          }
        }
      ],
      "metrics": [
        {
          "category": "AllMetrics",
          "enabled": true,
          "retentionPolicy": {
            "enabled": true,
            "days": 365
          }
        }
      ]
    }
  }
}
```

#### Key Access Monitoring Queries
```kusto
// Detect unusual key access patterns
KeyVaultData
| where TimeGenerated >= ago(24h)
| where OperationName in ("VaultGet", "KeyGet", "SecretGet")
| summarize AccessCount = count() by CallerIpAddress, identity_claim_name_s, Resource, bin(TimeGenerated, 1h)
| where AccessCount > 100  // Threshold for suspicious activity
| order by AccessCount desc

// Monitor failed key operations
KeyVaultData
| where TimeGenerated >= ago(1h)
| where ResultType != "Success"
| summarize FailedAttempts = count() by 
    identity_claim_name_s, 
    CallerIpAddress, 
    OperationName, 
    Resource,
    bin(TimeGenerated, 5m)
| where FailedAttempts >= 5
| order by TimeGenerated desc

// Track key lifecycle events
KeyVaultData
| where TimeGenerated >= ago(7d)
| where OperationName in ("KeyCreate", "KeyDelete", "KeyUpdate", "KeyRotate")
| project TimeGenerated, OperationName, Resource, identity_claim_name_s, CallerIpAddress, ResultType
| order by TimeGenerated desc
```

### 9.2 Real-time Alerting Configuration

#### Azure Monitor Alert Rules
```json
{
  "alertRules": [
    {
      "name": "High-Value Key Access Alert",
      "description": "Alert on ULTRA classification key access",
      "severity": 0,
      "evaluationFrequency": "PT1M",
      "windowSize": "PT5M",
      "criteria": {
        "allOf": [
          {
            "query": "KeyVaultData | where OperationName == 'KeyGet' and Resource contains 'ultra' | count",
            "operator": "GreaterThan",
            "threshold": 0
          }
        ]
      },
      "actions": [
        {
          "actionGroupId": "/subscriptions/{sub}/resourceGroups/rg-monitoring/providers/microsoft.insights/actionGroups/security-alerts",
          "webHookProperties": {
            "classification": "ULTRA",
            "severity": "CRITICAL"
          }
        }
      ]
    },
    {
      "name": "Key Rotation Failure Alert",
      "description": "Alert on failed key rotation attempts",
      "severity": 1,
      "evaluationFrequency": "PT5M",
      "windowSize": "PT15M",
      "criteria": {
        "allOf": [
          {
            "query": "KeyVaultData | where OperationName == 'KeyRotate' and ResultType == 'Failed' | count",
            "operator": "GreaterThan",
            "threshold": 0
          }
        ]
      }
    }
  ]
}
```

### 9.3 Compliance Reporting Automation

#### SOC 2 Compliance Report Generation
```powershell
function Generate-SOC2KeyManagementReport {
    param(
        [Parameter(Mandatory=$true)][datetime]$StartDate,
        [Parameter(Mandatory=$true)][datetime]$EndDate,
        [Parameter(Mandatory=$false)][string]$OutputPath = "reports/"
    )
    
    $reportData = @{
        ReportPeriod = "$($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
        GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Controls = @()
    }
    
    # CC6.1 - Logical Access Controls
    $keyAccessEvents = Get-AzOperationalInsightsSearchResults -WorkspaceId $workspaceId -Query @"
        KeyVaultData
        | where TimeGenerated between (datetime($($StartDate.ToString('yyyy-MM-dd'))) .. datetime($($EndDate.ToString('yyyy-MM-dd'))))
        | where OperationName in ('KeyGet', 'SecretGet', 'CertificateGet')
        | summarize AccessCount = count() by identity_claim_name_s, Resource
        | order by AccessCount desc
"@
    
    $reportData.Controls += @{
        ControlId = "CC6.1"
        Description = "Logical access security measures restrict access to keys"
        Evidence = $keyAccessEvents.Results
        Status = "Effective"
        TestProcedure = "Review of key access logs and RBAC assignments"
    }
    
    # CC6.7 - System Operations
    $keyRotationEvents = Get-AzOperationalInsightsSearchResults -WorkspaceId $workspaceId -Query @"
        KeyVaultData
        | where TimeGenerated between (datetime($($StartDate.ToString('yyyy-MM-dd'))) .. datetime($($EndDate.ToString('yyyy-MM-dd'))))
        | where OperationName == 'KeyRotate'
        | summarize RotationCount = count() by Resource, ResultType
"@
    
    $reportData.Controls += @{
        ControlId = "CC6.7"
        Description = "System operations procedures include key rotation"
        Evidence = $keyRotationEvents.Results
        Status = "Effective"
        TestProcedure = "Review of automated key rotation logs and schedules"
    }
    
    # Generate HTML report
    $htmlReport = ConvertTo-Html -InputObject $reportData -Title "SOC 2 Key Management Report"
    $reportFile = "$OutputPath/soc2-key-management-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    $htmlReport | Out-File -FilePath $reportFile
    
    Write-Output "SOC 2 compliance report generated: $reportFile"
}
```

## 10. Key Escrow and Recovery Procedures

### 10.1 Key Escrow Requirements

#### Escrow Policy Matrix
| Classification | Escrow Required | Escrow Location | Recovery Authority | Recovery SLA |
|---------------|----------------|-----------------|-------------------|--------------|
| ULTRA | Yes | Offline vault + HSM | Board + External Auditor | 24 hours |
| SECRET | Yes | Secure enclave | C-Level + External | 8 hours |
| CONFIDENTIAL | Yes | Encrypted backup | CISO + Legal | 4 hours |
| RESTRICTED | Optional | Standard backup | Security Team | 2 hours |
| PUBLIC | No | N/A | N/A | N/A |

#### Escrow Implementation
```powershell
# Create escrowed key backup
function New-EscrowedKeyBackup {
    param(
        [Parameter(Mandatory=$true)][string]$KeyName,
        [Parameter(Mandatory=$true)][string]$KeyVaultName,
        [Parameter(Mandatory=$true)][string]$Classification,
        [Parameter(Mandatory=$true)][string[]]$EscrowOfficers
    )
    
    # Generate escrow encryption key
    $escrowKey = Add-AzKeyVaultKey -VaultName "kv-escrow-prod" -Name "escrow-$KeyName-$(Get-Date -Format 'yyyyMMdd')" -Destination HSM
    
    # Create key backup
    $keyBackup = Backup-AzKeyVaultKey -VaultName $KeyVaultName -Name $KeyName
    
    # Encrypt backup with escrow key
    $encryptedBackup = [System.Convert]::ToBase64String([System.Security.Cryptography.ProtectedData]::Protect($keyBackup, $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine))
    
    # Create escrow record
    $escrowRecord = @{
        KeyName = $KeyName
        KeyVault = $KeyVaultName
        Classification = $Classification
        EscrowDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        EscrowOfficers = $EscrowOfficers
        EscrowKeyId = $escrowKey.Id
        BackupLocation = "secure-escrow-storage"
        RecoveryInstructions = "Contact Security Team with proper authorization"
    }
    
    # Store escrow record
    $escrowRecord | ConvertTo-Json | Out-File "escrow-records/$KeyName-$(Get-Date -Format 'yyyyMMdd').json"
    
    # Notify escrow officers
    foreach ($officer in $EscrowOfficers) {
        Send-MailMessage -To $officer -Subject "Key Escrow Notification - $KeyName" -Body "Key $KeyName has been escrowed. Record ID: $($escrowRecord.RecordId)"
    }
}
```

### 10.2 Key Recovery Procedures

#### Emergency Key Recovery Process
```bash
#!/bin/bash
# Emergency key recovery script with dual authorization

KEY_NAME=$1
RECOVERY_REASON=$2
AUTHORIZER1=$3
AUTHORIZER2=$4

# Validate dual authorization
if [[ -z "$AUTHORIZER1" || -z "$AUTHORIZER2" || "$AUTHORIZER1" == "$AUTHORIZER2" ]]; then
    echo "Error: Two different authorizers required"
    exit 1
fi

# Verify authorizer permissions
for authorizer in "$AUTHORIZER1" "$AUTHORIZER2"; do
    if ! az ad user show --id "$authorizer" --query "onPremisesSecurityIdentifier" -o tsv | grep -q "S-1-5-21"; then
        echo "Error: Invalid authorizer: $authorizer"
        exit 1
    fi
done

# Create recovery session
RECOVERY_SESSION=$(uuidgen)
echo "Recovery session started: $RECOVERY_SESSION"

# Log recovery attempt
cat >> /var/log/key-recovery.log << EOF
$(date -Iseconds) - RECOVERY_START - Key: $KEY_NAME, Session: $RECOVERY_SESSION
$(date -Iseconds) - RECOVERY_REASON - $RECOVERY_REASON
$(date -Iseconds) - RECOVERY_AUTH1 - $AUTHORIZER1
$(date -Iseconds) - RECOVERY_AUTH2 - $AUTHORIZER2
EOF

# Retrieve escrowed key backup
ESCROW_LOCATION=$(jq -r ".BackupLocation" "escrow-records/$KEY_NAME-*.json" | head -1)
if [[ -z "$ESCROW_LOCATION" ]]; then
    echo "Error: No escrow record found for key: $KEY_NAME"
    exit 1
fi

# Decrypt and restore key
echo "Restoring key from escrow..."
az keyvault key restore --vault-name "kv-recovery-prod" --file "$ESCROW_LOCATION/$KEY_NAME.backup"

if [[ $? -eq 0 ]]; then
    echo "Key recovery successful: $KEY_NAME"
    echo "$(date -Iseconds) - RECOVERY_SUCCESS - Key: $KEY_NAME, Session: $RECOVERY_SESSION" >> /var/log/key-recovery.log
    
    # Notify stakeholders
    ./scripts/notify-key-recovery.sh "$KEY_NAME" "$RECOVERY_SESSION" "SUCCESS"
else
    echo "Key recovery failed: $KEY_NAME"
    echo "$(date -Iseconds) - RECOVERY_FAILED - Key: $KEY_NAME, Session: $RECOVERY_SESSION" >> /var/log/key-recovery.log
    
    # Alert security team
    ./scripts/notify-key-recovery.sh "$KEY_NAME" "$RECOVERY_SESSION" "FAILED"
    exit 1
fi
```

## 11. Incident Response for Key Compromise

### 11.1 Key Compromise Response Procedures

#### Immediate Response Actions (0-15 minutes)
1. **Incident Declaration**
   ```powershell
   # Emergency key revocation script
   param([string]$CompromisedKeyName, [string]$IncidentId)
   
   # Immediately disable key
   Set-AzKeyVaultKeyAttribute -VaultName "kv-prod" -Name $CompromisedKeyName -Enable $false
   
   # Create incident record
   $incident = @{
       IncidentId = $IncidentId
       KeyName = $CompromisedKeyName
       DetectedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
       Severity = "CRITICAL"
       Status = "ACTIVE"
       Actions = @("Key disabled", "Incident team notified")
   }
   
   # Alert incident response team
   Send-SlackMessage -Channel "#security-incidents" -Message "🚨 KEY COMPROMISE: $CompromisedKeyName disabled. Incident: $IncidentId"
   ```

2. **Impact Assessment**
   - Identify all systems using the compromised key
   - Assess potential data exposure
   - Determine service disruption scope

#### Short-term Response (15 minutes - 4 hours)
3. **Key Rotation and Service Restoration**
   ```bash
   #!/bin/bash
   # Emergency key rotation for compromise response
   
   COMPROMISED_KEY=$1
   INCIDENT_ID=$2
   
   # Generate new key version
   NEW_KEY=$(az keyvault key create \
       --vault-name "kv-prod" \
       --name "$COMPROMISED_KEY-emergency" \
       --protection software \
       --size 3072 \
       --ops encrypt decrypt sign verify \
       --query "key.kid" -o tsv)
   
   # Update application configurations
   ./scripts/update-app-configs.sh "$COMPROMISED_KEY" "$NEW_KEY" "$INCIDENT_ID"
   
   # Verify service restoration
   ./scripts/health-check.sh --incident "$INCIDENT_ID"
   ```

4. **Forensic Evidence Preservation**
   - Capture current key access logs
   - Preserve system state snapshots
   - Document timeline of events

#### Long-term Response (4 hours - 30 days)
5. **Root Cause Analysis**
6. **Security Control Enhancement**
7. **Lessons Learned Documentation**

### 11.2 Post-Incident Recovery

#### Service Restoration Validation
```yaml
# Azure DevOps pipeline for post-incident validation
trigger: none

parameters:
  - name: incidentId
    type: string
  - name: affectedServices
    type: object

stages:
- stage: ValidationTests
  displayName: 'Post-Incident Service Validation'
  jobs:
  - job: CryptographicValidation
    displayName: 'Validate Cryptographic Operations'
    steps:
    - task: AzurePowerShell@5
      displayName: 'Test Key Operations'
      inputs:
        azureSubscription: 'Security-Validation-Connection'
        ScriptType: 'InlineScript'
        Inline: |
          $services = '${{ convertToJson(parameters.affectedServices) }}' | ConvertFrom-Json
          
          foreach ($service in $services) {
              Write-Output "Testing service: $($service.name)"
              
              # Test encryption/decryption
              $testData = "PostIncidentValidation-$($parameters.incidentId)"
              $encrypted = Invoke-RestMethod -Uri "$($service.endpoint)/encrypt" -Method Post -Body @{data=$testData} -ContentType "application/json"
              $decrypted = Invoke-RestMethod -Uri "$($service.endpoint)/decrypt" -Method Post -Body @{data=$encrypted.result} -ContentType "application/json"
              
              if ($decrypted.result -eq $testData) {
                  Write-Output "✅ Service $($service.name) cryptographic operations validated"
              } else {
                  Write-Error "❌ Service $($service.name) cryptographic validation failed"
                  exit 1
              }
          }
```

## 12. Performance Monitoring and SLA Management

### 12.1 Key Performance Indicators (KPIs)

#### Service Level Objectives
| Metric | Target | Measurement | Alert Threshold |
|--------|--------|-------------|-----------------|
| Key Vault Availability | 99.9% | Monthly uptime | < 99.5% |
| Key Operation Latency | < 100ms P95 | Response time | > 200ms |
| Key Rotation Success Rate | 99.5% | Successful rotations | < 98% |
| Failed Authentication Rate | < 0.1% | Authentication failures | > 0.5% |
| Certificate Renewal Success | 99.9% | Auto-renewal success | < 99% |
| Incident Response Time | < 15 minutes | Time to key disable | > 30 minutes |

#### Performance Monitoring Dashboard
```kusto
// Key Vault Performance Dashboard Queries

// Key operation latency trends
KeyVaultData
| where TimeGenerated >= ago(24h)
| where OperationName in ("KeyGet", "KeyEncrypt", "KeyDecrypt", "KeySign", "KeyVerify")
| summarize 
    AvgLatency = avg(DurationMs),
    P95Latency = percentile(DurationMs, 95),
    P99Latency = percentile(DurationMs, 99),
    RequestCount = count()
by bin(TimeGenerated, 1h), OperationName
| order by TimeGenerated desc

// Key Vault availability calculation
KeyVaultData
| where TimeGenerated >= ago(30d)
| summarize 
    TotalRequests = count(),
    SuccessfulRequests = countif(ResultType == "Success"),
    FailedRequests = countif(ResultType != "Success")
by bin(TimeGenerated, 1d)
| extend AvailabilityPercent = (SuccessfulRequests * 100.0) / TotalRequests
| project TimeGenerated, AvailabilityPercent, TotalRequests, FailedRequests

// Top key usage patterns
KeyVaultData
| where TimeGenerated >= ago(7d)
| where OperationName in ("KeyGet", "SecretGet", "CertificateGet")
| summarize RequestCount = count() by Resource, CallerIpAddress, identity_claim_name_s
| top 20 by RequestCount desc
```

### 12.2 Capacity Planning and Scaling

#### Auto-scaling Configuration
```json
{
  "scalingRules": [
    {
      "metricTrigger": {
        "metricName": "ServiceApiHit",
        "metricResourceUri": "/subscriptions/{sub}/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/kv-prod",
        "operator": "GreaterThan",
        "threshold": 1000,
        "timeGrain": "PT1M",
        "timeWindow": "PT5M",
        "timeAggregation": "Total"
      },
      "scaleAction": {
        "direction": "Increase",
        "type": "ChangeCount",
        "value": "1",
        "cooldown": "PT5M"
      }
    }
  ],
  "enabled": true,
  "profiles": [
    {
      "name": "DefaultProfile",
      "capacity": {
        "minimum": "1",
        "maximum": "10",
        "default": "2"
      }
    }
  ]
}
```

## 13. Integration with Applications and Services

### 13.1 Secure Application Integration Patterns

#### .NET Application Integration
```csharp
using Azure.Identity;
using Azure.KeyVault.Keys;
using Azure.KeyVault.Keys.Cryptography;

public class SecureKeyService
{
    private readonly KeyClient _keyClient;
    private readonly ILogger<SecureKeyService> _logger;
    private readonly IMemoryCache _keyCache;
    
    public SecureKeyService(IConfiguration config, ILogger<SecureKeyService> logger, IMemoryCache cache)
    {
        var keyVaultUri = new Uri(config["KeyVault:Uri"]);
        var credential = new DefaultAzureCredential();
        _keyClient = new KeyClient(keyVaultUri, credential);
        _logger = logger;
        _keyCache = cache;
    }
    
    public async Task<byte[]> EncryptDataAsync(string keyName, byte[] plaintext)
    {
        try
        {
            // Get cached key or retrieve from Key Vault
            var cryptoClient = await GetCryptographyClientAsync(keyName);
            
            // Encrypt data
            var encryptResult = await cryptoClient.EncryptAsync(EncryptionAlgorithm.RsaOaep256, plaintext);
            
            // Audit log
            _logger.LogInformation("Data encrypted successfully using key: {KeyName}", keyName);
            
            return encryptResult.Ciphertext;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to encrypt data using key: {KeyName}", keyName);
            throw;
        }
    }
    
    private async Task<CryptographyClient> GetCryptographyClientAsync(string keyName)
    {
        var cacheKey = $"crypto_client_{keyName}";
        
        if (!_keyCache.TryGetValue(cacheKey, out CryptographyClient cachedClient))
        {
            var keyResponse = await _keyClient.GetKeyAsync(keyName);
            cachedClient = new CryptographyClient(keyResponse.Value.Id, new DefaultAzureCredential());
            
            // Cache for 1 hour with sliding expiration
            _keyCache.Set(cacheKey, cachedClient, TimeSpan.FromHours(1));
        }
        
        return cachedClient;
    }
}
```

#### Kubernetes Secret Management Integration
```yaml
# Kubernetes SecretProviderClass for Key Vault integration
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: app-secrets
  namespace: production
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityClientID: "12345678-1234-1234-1234-123456789012"
    keyvaultName: "kv-confidential-prod"
    objects: |
      array:
        - |
          objectName: database-encryption-key
          objectType: key
          objectVersion: ""
        - |
          objectName: api-signing-certificate
          objectType: cert
          objectVersion: ""
    tenantId: "12345678-1234-1234-1234-123456789012"
  secretObjects:
  - secretName: app-crypto-secrets
    type: Opaque
    data:
    - objectName: database-encryption-key
      key: db_key
    - objectName: api-signing-certificate
      key: api_cert

---
# Deployment using the secrets
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets"
          readOnly: true
        env:
        - name: DB_ENCRYPTION_KEY_PATH
          value: "/mnt/secrets/db_key"
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "app-secrets"
```

### 13.2 API Integration Security

#### RESTful API Key Management Service
```python
from flask import Flask, request, jsonify
from azure.keyvault.keys import KeyClient
from azure.identity import DefaultAzureCredential
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa, padding
import logging
import json

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Key Vault client
credential = DefaultAzureCredential()
key_client = KeyClient(vault_url="https://kv-api-prod.vault.azure.net/", credential=credential)

@app.route('/api/v1/encrypt', methods=['POST'])
def encrypt_data():
    """Encrypt data using specified key"""
    try:
        data = request.get_json()
        key_name = data.get('keyName')
        plaintext = data.get('data')
        
        if not key_name or not plaintext:
            return jsonify({'error': 'keyName and data are required'}), 400
        
        # Get key from Key Vault
        key = key_client.get_key(key_name)
        
        # Convert to cryptography public key
        public_key = serialization.load_der_public_key(key.key.n.to_bytes(256, 'big'))
        
        # Encrypt data
        ciphertext = public_key.encrypt(
            plaintext.encode('utf-8'),
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        
        # Log operation
        logger.info(f"Data encrypted using key: {key_name}", extra={
            'operation': 'encrypt',
            'key_name': key_name,
            'client_ip': request.remote_addr,
            'user_agent': request.user_agent.string
        })
        
        return jsonify({
            'success': True,
            'ciphertext': ciphertext.hex(),
            'key_version': key.properties.version
        })
        
    except Exception as e:
        logger.error(f"Encryption failed: {str(e)}")
        return jsonify({'error': 'Encryption operation failed'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        # Test Key Vault connectivity
        key_client.get_keys()
        return jsonify({'status': 'healthy', 'keyvault': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, ssl_context='adhoc')
```

## 14. Compliance Validation and Reporting

### 14.1 Automated Compliance Checking

#### ISO 27001 Control Validation Script
```powershell
function Test-ISO27001Compliance {
    param(
        [Parameter(Mandatory=$true)][string[]]$KeyVaultNames,
        [Parameter(Mandatory=$false)][string]$ReportPath = "compliance-reports"
    )
    
    $complianceResults = @{
        TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Standard = "ISO 27001:2022"
        OverallStatus = "PASS"
        Controls = @()
    }
    
    foreach ($vaultName in $KeyVaultNames) {
        Write-Output "Testing compliance for Key Vault: $vaultName"
        
        # Test A.10.1.1 - Cryptographic key management policy
        $keyManagementPolicy = Test-KeyManagementPolicy -VaultName $vaultName
        $complianceResults.Controls += @{
            ControlId = "A.10.1.1"
            ControlName = "Cryptographic key management policy"
            VaultName = $vaultName
            Status = $keyManagementPolicy.Status
            Evidence = $keyManagementPolicy.Evidence
            Recommendations = $keyManagementPolicy.Recommendations
        }
        
        # Test A.10.1.2 - Key management procedures
        $keyProcedures = Test-KeyManagementProcedures -VaultName $vaultName
        $complianceResults.Controls += @{
            ControlId = "A.10.1.2"
            ControlName = "Key management procedures"
            VaultName = $vaultName
            Status = $keyProcedures.Status
            Evidence = $keyProcedures.Evidence
            Recommendations = $keyProcedures.Recommendations
        }
        
        # Test A.14.1.2 - Securing application services on public networks
        $networkSecurity = Test-NetworkSecurity -VaultName $vaultName
        $complianceResults.Controls += @{
            ControlId = "A.14.1.2"
            ControlName = "Securing application services on public networks"
            VaultName = $vaultName
            Status = $networkSecurity.Status
            Evidence = $networkSecurity.Evidence
            Recommendations = $networkSecurity.Recommendations
        }
        
        # Test A.14.1.3 - Protecting application services transactions
        $transactionSecurity = Test-TransactionSecurity -VaultName $vaultName
        $complianceResults.Controls += @{
            ControlId = "A.14.1.3"
            ControlName = "Protecting application services transactions"
            VaultName = $vaultName
            Status = $transactionSecurity.Status
            Evidence = $transactionSecurity.Evidence
            Recommendations = $transactionSecurity.Recommendations
        }
    }
    
    # Determine overall compliance status
    $failedControls = $complianceResults.Controls | Where-Object {$_.Status -eq "FAIL"}
    if ($failedControls.Count -gt 0) {
        $complianceResults.OverallStatus = "FAIL"
    }
    
    # Generate compliance report
    $reportFile = "$ReportPath/iso27001-compliance-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $complianceResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportFile
    
    Write-Output "Compliance report generated: $reportFile"
    return $complianceResults
}

function Test-KeyManagementPolicy {
    param([string]$VaultName)
    
    $vault = Get-AzKeyVault -VaultName $VaultName
    $evidence = @()
    $recommendations = @()
    
    # Check if soft delete is enabled
    if ($vault.EnableSoftDelete) {
        $evidence += "Soft delete enabled for key recovery"
    } else {
        $recommendations += "Enable soft delete for compliance with key lifecycle requirements"
    }
    
    # Check purge protection
    if ($vault.EnablePurgeProtection) {
        $evidence += "Purge protection enabled preventing premature key deletion"
    } else {
        $recommendations += "Enable purge protection to prevent unauthorized key purging"
    }
    
    # Check RBAC authorization
    if ($vault.EnableRbacAuthorization) {
        $evidence += "RBAC authorization enabled for granular access control"
    } else {
        $recommendations += "Enable RBAC authorization instead of access policies"
    }
    
    $status = if ($recommendations.Count -eq 0) { "PASS" } else { "FAIL" }
    
    return @{
        Status = $status
        Evidence = $evidence
        Recommendations = $recommendations
    }
}
```

### 14.2 Continuous Compliance Monitoring

#### Azure Policy for Key Management Compliance
```json
{
  "properties": {
    "displayName": "Key Vault Compliance Monitoring",
    "policyType": "Custom",
    "mode": "All",
    "description": "Ensures Key Vaults comply with cryptographic key management standards",
    "metadata": {
      "category": "Key Vault",
      "compliance": ["ISO27001:A.10.1.1", "ISO27001:A.10.1.2", "SOC2:CC6.1"]
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "The effect determines what happens when the policy rule is evaluated to match"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Audit"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.KeyVault/vaults"
          },
          {
            "anyOf": [
              {
                "field": "Microsoft.KeyVault/vaults/enableSoftDelete",
                "notEquals": "true"
              },
              {
                "field": "Microsoft.KeyVault/vaults/enablePurgeProtection",
                "notEquals": "true"
              },
              {
                "field": "Microsoft.KeyVault/vaults/enableRbacAuthorization",
                "notEquals": "true"
              },
              {
                "field": "Microsoft.KeyVault/vaults/publicNetworkAccess",
                "notEquals": "Disabled"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Security/complianceResults",
          "name": "KeyVaultComplianceCheck",
          "evaluationDelay": "AfterProvisioning",
          "existenceCondition": {
            "field": "Microsoft.Security/complianceResults/resourceStatus",
            "in": [
              "Healthy",
              "NotApplicable"
            ]
          }
        }
      }
    }
  }
}
```

## 15. Training and Knowledge Management

### 15.1 Role-Based Training Requirements

#### Training Matrix
| Role | Initial Training | Recurring Training | Certification Required |
|------|------------------|-------------------|----------------------|
| **Key Custodians** | 40 hours | Quarterly (8 hours) | CISSP, CISM |
| **Crypto Officers** | 80 hours | Bi-annual (16 hours) | CISSP + Crypto specialty |
| **Application Teams** | 16 hours | Annual (4 hours) | Security+ |
| **Auditors** | 24 hours | Annual (8 hours) | CISA, CISSP |
| **Executives** | 4 hours | Annual (2 hours) | None |

#### Training Modules
1. **Cryptographic Fundamentals**
   - Symmetric vs asymmetric cryptography
   - Key lengths and algorithm selection
   - Digital signatures and certificates
   - PKI concepts and implementation

2. **Azure Key Vault Operations**
   - Key Vault architecture and tiers
   - Key creation and management
   - Access control and monitoring
   - Integration patterns and best practices

3. **Compliance and Regulatory Requirements**
   - ISO 27001 cryptographic controls
   - SOC 2 logical access requirements
   - FIPS 140-2 validation levels
   - Industry-specific requirements

4. **Incident Response Procedures**
   - Key compromise scenarios
   - Emergency response procedures
   - Recovery and restoration processes
   - Post-incident analysis and improvement

### 15.2 Knowledge Base and Documentation

#### Searchable Knowledge Repository
```markdown
# Key Management Knowledge Base

## Quick Reference Cards

### Key Rotation Emergency Procedures
1. Identify affected systems: `./scripts/find-key-dependencies.sh <key-name>`
2. Create new key version: `az keyvault key create --vault-name <vault> --name <key>`
3. Update applications: `./scripts/update-key-references.sh <old-key> <new-key>`
4. Validate operations: `./scripts/validate-key-operations.sh <key-name>`

### Common Troubleshooting

#### "Key not found" Errors
- **Cause**: Key may be soft-deleted or access permissions insufficient
- **Resolution**: Check soft-deleted keys with `az keyvault key list-deleted`
- **Prevention**: Implement proper key lifecycle tracking

#### High Latency Key Operations
- **Cause**: Network issues or Key Vault throttling
- **Resolution**: Implement exponential backoff and caching
- **Prevention**: Monitor Key Vault metrics and implement auto-scaling

### Best Practices Checklist

#### Before Key Creation
- [ ] Determine appropriate classification level
- [ ] Verify business justification and approval
- [ ] Select correct key type and size
- [ ] Configure appropriate access policies
- [ ] Set up monitoring and alerting

#### After Key Creation
- [ ] Document key purpose and dependencies
- [ ] Test key operations with applications
- [ ] Verify backup and recovery procedures
- [ ] Schedule rotation based on classification
- [ ] Update key inventory and CMDB
```

## 16. Continuous Improvement and Metrics

### 16.1 Key Management Metrics Dashboard

#### Executive Dashboard KPIs
```sql
-- Key Management Executive Summary Query
WITH KeyMetrics AS (
  SELECT 
    COUNT(DISTINCT vault_name) as TotalKeyVaults,
    COUNT(DISTINCT key_name) as TotalKeys,
    COUNT(CASE WHEN classification = 'ULTRA' THEN 1 END) as UltraKeys,
    COUNT(CASE WHEN classification = 'SECRET' THEN 1 END) as SecretKeys,
    COUNT(CASE WHEN rotation_status = 'OVERDUE' THEN 1 END) as OverdueRotations,
    AVG(DATEDIFF(day, last_accessed, GETDATE())) as AvgDaysSinceAccess
  FROM key_inventory
  WHERE active = 1
),
ComplianceMetrics AS (
  SELECT 
    COUNT(CASE WHEN compliance_status = 'COMPLIANT' THEN 1 END) * 100.0 / COUNT(*) as CompliancePercentage,
    COUNT(CASE WHEN audit_status = 'PASS' THEN 1 END) * 100.0 / COUNT(*) as AuditPassRate
  FROM key_compliance_status
  WHERE assessment_date >= DATEADD(month, -1, GETDATE())
),
IncidentMetrics AS (
  SELECT 
    COUNT(*) as TotalIncidents,
    AVG(DATEDIFF(minute, incident_start, incident_resolution)) as AvgResolutionTimeMinutes,
    COUNT(CASE WHEN severity = 'CRITICAL' THEN 1 END) as CriticalIncidents
  FROM key_security_incidents
  WHERE incident_date >= DATEADD(month, -1, GETDATE())
)

SELECT 
  km.*,
  cm.CompliancePercentage,
  cm.AuditPassRate,
  im.TotalIncidents,
  im.AvgResolutionTimeMinutes,
  im.CriticalIncidents,
  CASE 
    WHEN km.OverdueRotations = 0 AND cm.CompliancePercentage >= 95 AND im.CriticalIncidents = 0 
    THEN 'GREEN'
    WHEN km.OverdueRotations <= 5 AND cm.CompliancePercentage >= 90 AND im.CriticalIncidents <= 1
    THEN 'YELLOW'
    ELSE 'RED'
  END as OverallHealthStatus
FROM KeyMetrics km, ComplianceMetrics cm, IncidentMetrics im;
```

### 16.2 Continuous Improvement Process

#### Monthly Review Process
```powershell
# Monthly Key Management Review Automation
function Invoke-MonthlyKeyManagementReview {
    param(
        [Parameter(Mandatory=$false)][datetime]$ReviewDate = (Get-Date)
    )
    
    $reviewData = @{
        ReviewDate = $ReviewDate.ToString('yyyy-MM-dd')
        Metrics = @{}
        Issues = @()
        Improvements = @()
        ActionItems = @()
    }
    
    # Collect performance metrics
    $reviewData.Metrics.KeyRotationCompliance = Get-KeyRotationCompliance -Month $ReviewDate.Month -Year $ReviewDate.Year
    $reviewData.Metrics.SecurityIncidents = Get-SecurityIncidentSummary -Month $ReviewDate.Month -Year $ReviewDate.Year
    $reviewData.Metrics.ComplianceStatus = Get-ComplianceStatus -Month $ReviewDate.Month -Year $ReviewDate.Year
    $reviewData.Metrics.PerformanceMetrics = Get-PerformanceMetrics -Month $ReviewDate.Month -Year $ReviewDate.Year
    
    # Identify issues and improvement opportunities
    if ($reviewData.Metrics.KeyRotationCompliance.ComplianceRate -lt 95) {
        $reviewData.Issues += "Key rotation compliance below target (95%)"
        $reviewData.ActionItems += @{
            Issue = "Low rotation compliance"
            Action = "Review and improve automated rotation processes"
            Owner = "Security Team"
            DueDate = (Get-Date).AddDays(30).ToString('yyyy-MM-dd')
        }
    }
    
    if ($reviewData.Metrics.SecurityIncidents.Count -gt 0) {
        $reviewData.Issues += "Security incidents occurred during review period"
        $reviewData.ActionItems += @{
            Issue = "Security incidents"
            Action = "Complete root cause analysis and implement preventive measures"
            Owner = "Incident Response Team"
            DueDate = (Get-Date).AddDays(14).ToString('yyyy-MM-dd')
        }
    }
    
    # Generate improvement recommendations
    $reviewData.Improvements += "Implement machine learning for anomaly detection in key access patterns"
    $reviewData.Improvements += "Enhance automation coverage for certificate lifecycle management"
    $reviewData.Improvements += "Develop self-service key management portal for development teams"
    
    # Create review report
    $reportFile = "reviews/monthly-review-$($ReviewDate.ToString('yyyy-MM')).json"
    $reviewData | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportFile
    
    # Send to stakeholders
    Send-MonthlyReviewReport -ReviewData $reviewData -ReportFile $reportFile
    
    Write-Output "Monthly review completed. Report saved to: $reportFile"
    return $reviewData
}
```

## 17. Emergency Contacts and Escalation Procedures

### 17.1 Contact Matrix
| Role | Primary Contact | Secondary Contact | 24/7 On-Call |
|------|----------------|-------------------|---------------|
| **CISO** | ciso@company.com | deputy-ciso@company.com | +1-555-CISO |
| **Security Operations** | soc@company.com | security-backup@company.com | +1-555-SOC1 |
| **Key Custodian Team** | key-custodians@company.com | key-backup@company.com | +1-555-KEYS |
| **Cloud Infrastructure** | cloud-ops@company.com | cloud-backup@company.com | +1-555-CLOUD |
| **Legal/Compliance** | legal@company.com | compliance@company.com | Business Hours |
| **Executive Team** | exec-team@company.com | coo@company.com | +1-555-EXEC |

### 17.2 Escalation Matrix
| Incident Severity | Initial Response | Escalation Time | Escalation Target |
|------------------|------------------|-----------------|-------------------|
| **P1 - Critical** | Security Operations | 15 minutes | CISO + CTO |
| **P2 - High** | Key Custodian Team | 1 hour | Security Operations Manager |
| **P3 - Medium** | Application Team | 4 hours | Security Team Lead |
| **P4 - Low** | Service Owner | 24 hours | Team Manager |

## 18. Appendices

### Appendix A: Key Classification Decision Tree
```
Is the key protecting data classified as Top Secret or Root CA?
├─ Yes → ULTRA Classification
└─ No → Is the key protecting financial or health data?
   ├─ Yes → SECRET Classification
   └─ No → Is the key protecting business-critical systems?
      ├─ Yes → CONFIDENTIAL Classification
      └─ No → Is the key for internal systems?
         ├─ Yes → RESTRICTED Classification
         └─ No → PUBLIC Classification
```

### Appendix B: Supported Cryptographic Algorithms
| Algorithm | Key Sizes | Use Cases | Compliance |
|-----------|-----------|-----------|------------|
| **RSA** | 2048, 3072, 4096 | Signatures, Key Exchange | FIPS 140-2 |
| **ECC** | P-256, P-384, P-521 | Signatures, ECDH | FIPS 140-2 |
| **AES** | 128, 256 | Symmetric Encryption | FIPS 140-2 |
| **HMAC** | SHA-256, SHA-384 | Message Authentication | FIPS 140-2 |

### Appendix C: Compliance Mapping
| Framework | Control | Implementation | Evidence |
|-----------|---------|----------------|----------|
| **ISO 27001** | A.10.1.1 | Key management policy | This runbook |
| **ISO 27001** | A.10.1.2 | Key management procedures | Sections 3-12 |
| **SOC 2** | CC6.1 | Logical access controls | Section 8 |
| **SOC 2** | CC6.7 | System operations | Section 9 |
| **NIST CSF** | PR.DS-1 | Data-at-rest protection | Section 4 |
| **NIST CSF** | PR.DS-2 | Data-in-transit protection | Section 7 |

---

**Document Classification**: CONFIDENTIAL - Internal Use Only  
**Last Updated**: 2024-12-01  
**Version**: 2.0  
**Next Review Date**: 2025-12-01
