# Microsoft Cloud Security Benchmark (MCSB) Implementation Framework

## Executive Summary

This comprehensive implementation framework provides enterprise organizations with a structured approach to achieve full Microsoft Cloud Security Benchmark (MCSB) compliance while integrating with broader security and compliance programs. The framework aligns MCSB controls with Azure Security Benchmark, ISO 27001:2022, and SOC 2 Type II requirements, providing a unified security posture management approach.

### Framework Overview
- **Scope**: Complete MCSB v1.0 implementation across all 10 control domains
- **Alignment**: Azure Security Benchmark, ISO 27001, SOC 2, NIST CSF
- **Architecture**: Zero Trust security model with defense-in-depth
- **Automation**: Policy-as-Code with continuous compliance monitoring
- **Governance**: Enterprise-grade security governance and risk management

---

## 1. MCSB Control Domain Architecture

### 1.1 Network Security (NS) - Zero Trust Network Foundation

#### Core Principles
- Assume breach mentality with verify-then-trust approach
- Micro-segmentation with application-aware network policies
- Encrypted communication for all data flows
- Continuous network monitoring and threat detection

#### NS-1: Network Segmentation and Micro-segmentation
**Implementation Requirements:**
- **Hub-Spoke Topology**: Centralized connectivity with distributed workloads
  ```json
  {
    "hubVirtualNetwork": {
      "addressSpace": "10.0.0.0/16",
      "subnets": {
        "AzureFirewallSubnet": "10.0.1.0/26",
        "GatewaySubnet": "10.0.2.0/27",
        "AzureBastionSubnet": "10.0.3.0/27"
      }
    },
    "spokeNetworks": {
      "production": "10.1.0.0/16",
      "staging": "10.2.0.0/16",
      "development": "10.3.0.0/16"
    }
  }
  ```
- **Network Security Groups (NSGs)**: Layer 4 traffic filtering
  - Deny-all default rules with explicit allow policies
  - Application Security Groups (ASGs) for application-aware rules
  - Flow logs enabled for all NSGs with traffic analytics
- **Azure Firewall Premium**: Layer 7 inspection and filtering
  - TLS inspection with custom certificates
  - IDPS with custom threat intelligence
  - URL filtering with custom categories
  - DNS proxy with custom DNS servers

**Compliance Mapping:**
- **ISO 27001**: A.13.1.1, A.13.1.3, A.13.2.1
- **SOC 2**: CC6.1, CC6.6, CC6.7
- **Azure Policy**: `Deny-PublicIP-VM`, `Require-NSG-Subnet`

#### NS-2: Private Network Connectivity
**Implementation Requirements:**
- **Private Endpoints**: All PaaS services accessible only via private network
  ```terraform
  resource "azurerm_private_endpoint" "storage" {
    name                = "pe-${var.storage_account_name}"
    location            = var.location
    resource_group_name = var.resource_group_name
    subnet_id           = var.private_endpoint_subnet_id

    private_service_connection {
      name                           = "psc-${var.storage_account_name}"
      private_connection_resource_id = var.storage_account_id
      subresource_names              = ["blob"]
    }

    private_dns_zone_group {
      name                 = "dns-zone-group"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }
  ```
- **Service Endpoints**: Legacy service integration where private endpoints unavailable
- **Public Access Policies**: Deny public network access for all supported services
- **Private DNS Zones**: Custom DNS resolution for private endpoints

**Compliance Mapping:**
- **ISO 27001**: A.13.1.1, A.13.2.1
- **SOC 2**: CC6.1, CC6.7
- **Azure Policy**: `Deny-Storage-PublicAccess`, `Require-PrivateEndpoint`

#### NS-3: DDoS Protection and Traffic Management
**Implementation Requirements:**
- **DDoS Protection Standard**: All virtual networks with public IPs
- **Azure Front Door**: Global load balancing with WAF protection
- **Application Gateway**: Regional load balancing with WAF v2
- **Traffic Manager**: DNS-based traffic routing with health monitoring

**Performance Requirements:**
- 99.9% availability SLA for internet-facing applications
- <100ms latency for 95th percentile of requests
- Automatic failover within 30 seconds

### 1.2 Identity Management (IM) - Zero Trust Identity

#### Core Principles
- Identity as the primary security perimeter
- Continuous risk assessment and adaptive authentication
- Least privilege access with just-in-time elevation
- Comprehensive identity lifecycle management

#### IM-1: Centralized Identity Management
**Implementation Requirements:**
- **Azure Active Directory Premium P2**: Advanced identity protection
- **Conditional Access Policies**: Risk-based authentication
  ```json
  {
    "conditionalAccessPolicy": {
      "displayName": "High Risk Sign-ins - Require MFA and Compliant Device",
      "state": "enabled",
      "conditions": {
        "signInRiskLevels": ["high", "medium"],
        "clientAppTypes": ["all"],
        "locations": {
          "includeLocations": ["All"],
          "excludeLocations": ["AllTrusted"]
        }
      },
      "grantControls": {
        "operator": "AND",
        "builtInControls": [
          "mfa",
          "compliantDevice"
        ]
      }
    }
  }
  ```
- **Multi-Factor Authentication**: FIDO2, Windows Hello, Authenticator app
- **Identity Protection**: Real-time risk detection and remediation
- **Password Protection**: Custom banned password lists and smart lockout

**Compliance Mapping:**
- **ISO 27001**: A.9.1.1, A.9.1.2, A.9.2.1, A.9.4.2
- **SOC 2**: CC6.1, CC6.2, CC6.3
- **Azure Policy**: `Require-MFA-GlobalAdmins`, `Audit-AAD-RiskEvents`

#### IM-2: Identity Lifecycle Management
**Implementation Requirements:**
- **Automated Provisioning**: SCIM-based user provisioning from HR systems
- **Access Reviews**: Quarterly reviews for all privileged access
- **Entitlement Management**: Automated access packages with approval workflows
- **Guest User Management**: B2B collaboration with external identity verification

**Automation Requirements:**
- 95% of user provisioning/deprovisioning automated
- Zero standing access for administrative accounts
- Automated compliance reporting for access reviews

#### IM-3: Workload Identity Security
**Implementation Requirements:**
- **Managed Identities**: System-assigned and user-assigned identities
- **Workload Identity Federation**: Keyless authentication for CI/CD pipelines
- **Service Principal Management**: Centralized credential rotation
- **Certificate-Based Authentication**: X.509 certificates for service authentication

**Implementation Example:**
```terraform
resource "azurerm_user_assigned_identity" "workload" {
  name                = "mi-${var.application_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    Environment = var.environment
    Application = var.application_name
    Owner       = var.application_owner
  }
}

resource "azurerm_federated_identity_credential" "github" {
  name                = "github-actions"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.workload.id
  subject             = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}
```

### 1.3 Privileged Access Management (PA) - Zero Standing Access

#### Core Principles
- Just-in-time and just-enough access model
- Privileged access workstation strategy
- Comprehensive audit and monitoring of privileged operations
- Emergency access procedures with break-glass accounts

#### PA-1: Privileged Identity Management
**Implementation Requirements:**
- **Azure AD PIM**: Just-in-time access with approval workflows
  ```json
  {
    "roleAssignmentScheduleRequest": {
      "principalId": "user-object-id",
      "roleDefinitionId": "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/roleDefinitions/{role-id}",
      "directoryScopeId": "/subscriptions/{subscription-id}",
      "action": "adminAssign",
      "scheduleInfo": {
        "startDateTime": "2024-01-01T00:00:00Z",
        "expiration": {
          "type": "afterDuration",
          "duration": "PT8H"
        }
      },
      "justification": "Emergency database maintenance"
    }
  }
  ```
- **Access Reviews**: Monthly reviews for all privileged roles
- **Approval Workflows**: Multi-stage approval for high-privilege roles
- **Emergency Access**: Break-glass accounts with monitoring and alerting

**Compliance Mapping:**
- **ISO 27001**: A.9.2.3, A.9.2.5, A.9.2.6
- **SOC 2**: CC6.1, CC6.3
- **Azure Policy**: `Audit-PIM-Eligible-Assignments`, `Monitor-Emergency-Access`

#### PA-2: Privileged Access Workstations (PAW)
**Implementation Requirements:**
- **Dedicated Admin Workstations**: Hardened Windows 11 devices
- **Microsoft Intune Management**: Device compliance and configuration
- **Conditional Access**: Device-based access controls
- **Application Control**: Application allowlisting with Windows Defender Application Control

**Technical Specifications:**
- BitLocker encryption with TPM 2.0
- Windows Hello for Business authentication
- Microsoft Defender for Endpoint protection
- Isolated network segment for admin operations

### 1.4 Data Protection (DP) - Data-Centric Security

#### Core Principles
- Data classification and labeling at creation
- Encryption everywhere with customer-managed keys
- Data loss prevention with automated policy enforcement
- Privacy by design with data minimization

#### DP-1: Data Discovery and Classification
**Implementation Requirements:**
- **Microsoft Purview**: Automated data discovery and classification
  ```json
  {
    "classificationRule": {
      "name": "PII-SSN-Detection",
      "description": "Detect US Social Security Numbers",
      "classificationName": "US Social Security Number",
      "columnPatterns": [
        {
          "kind": "Regex",
          "pattern": "\\b(?!000|666|9)([0-8]\\d{2}|9[0-4]\\d|95[0-5])[-\\s]?(\\d{2})[-\\s]?(\\d{4})\\b"
        }
      ],
      "dataPattern": {
        "kind": "Regex",
        "pattern": "^\\d{3}-\\d{2}-\\d{4}$"
      },
      "minimumPercentageMatch": 60
    }
  }
  ```
- **Sensitivity Labels**: Microsoft Information Protection labels
- **Data Loss Prevention**: Automated DLP policies across all data stores
- **Data Retention**: Automated lifecycle management based on classification

#### DP-2: Encryption Implementation
**Implementation Requirements:**
- **Encryption at Rest**: Customer-managed keys in Azure Key Vault
- **Encryption in Transit**: TLS 1.3 for all communications
- **Key Management**: Hardware Security Module (HSM) backing
- **Key Rotation**: Automated 90-day rotation for all keys

**Technical Implementation:**
```terraform
resource "azurerm_key_vault_key" "data_encryption" {
  name         = "key-${var.application_name}-${var.environment}"
  key_vault_id = var.key_vault_id
  key_type     = "RSA-HSM"
  key_size     = 4096
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  rotation_policy {
    expire_after         = "P90D"
    notify_before_expiry = "P7D"

    automatic {
      time_before_expiry = "P7D"
    }
  }
}

resource "azurerm_storage_account" "encrypted" {
  name                = "sa${var.application_name}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  customer_managed_key {
    key_vault_key_id = azurerm_key_vault_key.data_encryption.id
  }
}
```

#### DP-3: Data Backup and Recovery
**Implementation Requirements:**
- **Azure Backup**: Centralized backup with geo-redundancy
- **Immutable Storage**: Write-once-read-many (WORM) for critical data
- **Recovery Testing**: Monthly restore tests with documented procedures
- **Cross-Region Replication**: Business continuity across Azure regions

**Recovery Objectives:**
- RPO: 1 hour for critical systems, 24 hours for non-critical
- RTO: 4 hours for critical systems, 24 hours for non-critical
- Backup Retention: 7 years for compliance data, 3 years for operational data

### 1.5 Asset Management (AM) - Comprehensive Asset Visibility

#### Core Principles
- Complete asset inventory with automated discovery
- Risk-based asset classification and protection
- Continuous vulnerability assessment and remediation
- Supply chain security with software bill of materials

#### AM-1: Asset Inventory and Management
**Implementation Requirements:**
- **Azure Resource Graph**: Centralized resource inventory
  ```kql
  Resources
  | where type =~ 'Microsoft.Compute/virtualMachines'
  | extend 
      OS = properties.storageProfile.osDisk.osType,
      VMSize = properties.hardwareProfile.vmSize,
      PowerState = properties.extended.instanceView.powerState.displayStatus
  | project name, resourceGroup, location, OS, VMSize, PowerState, tags
  | order by name asc
  ```
- **Configuration Management Database (CMDB)**: Integration with ServiceNow or similar
- **Asset Classification**: Business impact and data sensitivity ratings
- **Automated Tagging**: Policy-enforced resource tagging standards

**Tagging Strategy:**
```json
{
  "mandatoryTags": {
    "Environment": ["Production", "Staging", "Development"],
    "Application": "ApplicationName",
    "Owner": "BusinessOwnerEmail",
    "CostCenter": "CostCenterCode",
    "DataClassification": ["Public", "Internal", "Confidential", "Restricted"],
    "BusinessCriticality": ["Low", "Medium", "High", "Critical"]
  }
}
```

#### AM-2: Software Asset Management
**Implementation Requirements:**
- **Microsoft Defender for Cloud**: Software inventory and vulnerability scanning
- **Software Bill of Materials (SBOM)**: Automated generation for all deployments
- **License Compliance**: Automated license tracking and optimization
- **Third-Party Risk Assessment**: Vendor security assessment integration

#### AM-3: Hardware Asset Management
**Implementation Requirements:**
- **Azure Arc**: Hybrid and multi-cloud asset management
- **Microsoft System Center**: On-premises asset discovery
- **Hardware Lifecycle Management**: Automated end-of-life notifications
- **Configuration Baseline**: Security configuration monitoring

### 1.6 Logging and Threat Detection (LT) - Security Operations

#### Core Principles
- Comprehensive logging across all systems and applications
- Real-time threat detection with automated response
- Security information correlation and analysis
- Forensic capability with immutable audit trails

#### LT-1: Central Logging and Monitoring
**Implementation Requirements:**
- **Azure Monitor**: Centralized telemetry collection
  ```json
  {
    "diagnosticSettings": {
      "name": "central-logging",
      "properties": {
        "workspaceId": "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}",
        "storageAccountId": "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Storage/storageAccounts/{storage-name}",
        "logs": [
          {
            "category": "Administrative",
            "enabled": true,
            "retentionPolicy": {
              "enabled": true,
              "days": 2555
            }
          },
          {
            "category": "Security",
            "enabled": true,
            "retentionPolicy": {
              "enabled": true,
              "days": 2555
            }
          }
        ],
        "metrics": [
          {
            "category": "AllMetrics",
            "enabled": true,
            "retentionPolicy": {
              "enabled": true,
              "days": 90
            }
          }
        ]
      }
    }
  }
  ```
- **Log Analytics Workspace**: Centralized log storage and analysis
- **Data Retention**: 7-year retention for security logs
- **Cross-Region Replication**: Geographic log distribution for resilience

#### LT-2: Security Information and Event Management (SIEM)
**Implementation Requirements:**
- **Microsoft Sentinel**: Cloud-native SIEM with AI-powered detection
- **Custom Analytics Rules**: Organization-specific threat detection
  ```kql
  // Detect unusual administrative activity
  AuditLogs
  | where TimeGenerated > ago(1h)
  | where OperationName contains "Add" or OperationName contains "Delete"
  | where Identity has_any ("admin", "Admin")
  | where Location != "US"
  | summarize Count = count() by Identity, Location, OperationName
  | where Count > 5
  | project Identity, Location, OperationName, Count, TimeGenerated
  ```
- **Threat Intelligence**: Integration with Microsoft Threat Intelligence
- **Automated Response**: SOAR playbooks for common incident types

#### LT-3: Advanced Threat Detection
**Implementation Requirements:**
- **Microsoft Defender for Cloud**: Multi-cloud security posture management
- **Microsoft Defender for Endpoint**: Advanced endpoint detection and response
- **Microsoft Defender for Identity**: On-premises identity threat detection
- **Microsoft Defender for Office 365**: Email and collaboration security

**Detection Capabilities:**
- Machine learning-based anomaly detection
- User and entity behavior analytics (UEBA)
- Deception technology integration
- Threat hunting with KQL queries

### 1.7 Vulnerability Management (VM) - Proactive Risk Reduction

#### Core Principles
- Continuous vulnerability assessment and scanning
- Risk-based prioritization and remediation
- Automated patching for critical vulnerabilities
- Integration with secure development lifecycle

#### VM-1: Vulnerability Assessment
**Implementation Requirements:**
- **Microsoft Defender Vulnerability Management**: Integrated vulnerability scanning
- **Qualys VMDR**: Third-party validation and extended scanning
- **Container Scanning**: Image vulnerability assessment in CI/CD pipelines
- **Infrastructure as Code Scanning**: Security policy validation

**Scanning Coverage:**
- Virtual machines: Daily OS and application scanning
- Containers: Scan on build and runtime monitoring
- Web applications: Monthly DAST scanning
- Network devices: Quarterly configuration review

#### VM-2: Patch Management
**Implementation Requirements:**
- **Azure Update Management**: Centralized patch deployment
- **Microsoft System Center Configuration Manager**: On-premises patch management
- **Automated Patching**: Critical patches within 72 hours
- **Maintenance Windows**: Coordinated patching schedules

**Patch Categories:**
- Critical security patches: 72-hour deployment SLA
- Important patches: 30-day deployment SLA
- Recommended patches: Quarterly deployment cycle
- Optional patches: Semi-annual review cycle

#### VM-3: Secure Development Integration
**Implementation Requirements:**
- **Static Application Security Testing (SAST)**: Integrated in CI/CD pipelines
- **Dynamic Application Security Testing (DAST)**: Pre-production scanning
- **Interactive Application Security Testing (IAST)**: Runtime security monitoring
- **Software Composition Analysis (SCA)**: Third-party component scanning

### 1.8 Security Posture Management (SP) - Continuous Compliance

#### Core Principles
- Policy-based security governance
- Continuous compliance monitoring and reporting
- Risk-based security controls prioritization
- Integration with business risk management

#### SP-1: Security Policy Governance
**Implementation Requirements:**
- **Azure Policy**: Infrastructure compliance automation
  ```json
  {
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/allowBlobPublicAccess",
            "equals": true
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    },
    "parameters": {},
    "metadata": {
      "displayName": "Storage accounts should disable public blob access",
      "description": "Disabling public blob access improves security by ensuring blob containers are not accessible anonymously.",
      "category": "Storage"
    }
  }
  ```
- **Azure Blueprints**: Standardized environment deployment
- **Management Groups**: Hierarchical policy organization
- **Policy Exemptions**: Risk-accepted exception management

#### SP-2: Security Posture Assessment
**Implementation Requirements:**
- **Microsoft Defender for Cloud**: Secure Score monitoring
- **Azure Security Benchmark**: Compliance assessment
- **Custom Assessments**: Organization-specific security requirements
- **Third-Party Validation**: Annual penetration testing

**Secure Score Targets:**
- Production environments: >90% Secure Score
- Non-production environments: >75% Secure Score
- Monthly improvement targets: +2% Secure Score
- Executive dashboard reporting: Weekly

#### SP-3: Risk Management Integration
**Implementation Requirements:**
- **Azure Risk Assessment**: Cloud-specific risk evaluation
- **Business Impact Analysis**: Service dependency mapping
- **Risk Register Integration**: Enterprise risk management alignment
- **Quantitative Risk Metrics**: Financial impact assessment

### 1.9 Backup and Recovery (BR) - Business Continuity

#### Core Principles
- Comprehensive backup strategy across all data types
- Regular recovery testing and validation
- Geographic redundancy for critical systems
- Integration with business continuity planning

#### BR-1: Backup Strategy and Implementation
**Implementation Requirements:**
- **Azure Backup**: Centralized backup management
  ```terraform
  resource "azurerm_recovery_services_vault" "backup" {
    name                = "rsv-backup-${var.environment}"
    location            = var.location
    resource_group_name = var.resource_group_name
    sku                = "Standard"
    
    storage_mode_type = "GeoRedundant"
    cross_region_restore_enabled = true
    
    encryption {
      key_id                            = var.key_vault_key_id
      infrastructure_encryption_enabled = true
    }
  }
  
  resource "azurerm_backup_policy_vm" "policy" {
    name                = "bp-vm-daily"
    resource_group_name = var.resource_group_name
    recovery_vault_name = azurerm_recovery_services_vault.backup.name
    
    backup {
      frequency = "Daily"
      time      = "23:00"
    }
    
    retention_daily {
      count = 30
    }
    
    retention_weekly {
      count    = 12
      weekdays = ["Sunday"]
    }
    
    retention_monthly {
      count    = 60
      weekdays = ["Sunday"]
      weeks    = ["First"]
    }
    
    retention_yearly {
      count    = 7
      weekdays = ["Sunday"]
      weeks    = ["First"]
      months   = ["January"]
    }
  }
  ```

- **Database Backup**: Automated backup for SQL databases
- **Application Backup**: Consistent application state preservation
- **Configuration Backup**: Infrastructure and application settings

#### BR-2: Disaster Recovery Planning
**Implementation Requirements:**
- **Azure Site Recovery**: Virtual machine replication and failover
- **SQL Always On Availability Groups**: Database high availability
- **Application-Level DR**: Multi-region application deployment
- **DR Testing**: Quarterly disaster recovery exercises

**Recovery Objectives:**
- Tier 1 Applications: RPO 15 minutes, RTO 1 hour
- Tier 2 Applications: RPO 1 hour, RTO 4 hours
- Tier 3 Applications: RPO 24 hours, RTO 24 hours

#### BR-3: Data Retention and Archival
**Implementation Requirements:**
- **Immutable Storage**: Ransomware-resistant backup storage
- **Archive Storage**: Long-term data retention with cost optimization
- **Legal Hold**: Litigation and compliance data preservation
- **Data Destruction**: Secure deletion with certificate of destruction

### 1.10 Incident Response (IR) - Security Incident Management

#### Core Principles
- Structured incident response with clear escalation procedures
- Automated threat containment and remediation
- Comprehensive forensic capability
- Continuous improvement through lessons learned

#### IR-1: Incident Response Planning
**Implementation Requirements:**
- **Incident Response Plan**: Comprehensive response procedures
- **Incident Classification**: Severity-based response procedures
- **Communication Plan**: Internal and external notification procedures
- **Legal and Regulatory Compliance**: Breach notification requirements

**Incident Severity Levels:**
- **Critical (P1)**: Business-critical system compromise, <15 minute response
- **High (P2)**: Significant system impact, <1 hour response
- **Medium (P3)**: Limited impact, <4 hour response
- **Low (P4)**: Minimal impact, <24 hour response

#### IR-2: Automated Response and Orchestration
**Implementation Requirements:**
- **Microsoft Sentinel Playbooks**: Automated response workflows
  ```json
  {
    "playbook": {
      "name": "Isolate-Compromised-VM",
      "triggers": {
        "microsoft-sentinel-alert": {
          "inputs": {
            "alertSeverity": ["High", "Critical"],
            "alertTitle": "Suspicious activity detected on VM"
          }
        }
      },
      "actions": {
        "isolate-vm": {
          "type": "Http",
          "inputs": {
            "method": "POST",
            "uri": "https://management.azure.com/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm-name}/runCommand",
            "body": {
              "commandId": "DisableNetworkAdapter",
              "script": "Get-NetAdapter | Disable-NetAdapter -Confirm:$false"
            }
          }
        },
        "create-incident": {
          "type": "MicrosoftSentinel-CreateIncident",
          "inputs": {
            "title": "VM Isolation - @{triggerBody()?['AlertDisplayName']}",
            "severity": "High",
            "status": "New"
          }
        }
      }
    }
  }
  ```
- **Automated Containment**: Network isolation and account disabling
- **Evidence Collection**: Automated forensic data gathering
- **Stakeholder Notification**: Multi-channel alert distribution

#### IR-3: Forensics and Investigation
**Implementation Requirements:**
- **Azure Monitor Logs**: Comprehensive audit trail preservation
- **Memory and Disk Imaging**: Forensic evidence collection
- **Network Traffic Analysis**: Flow log analysis for investigation
- **Third-Party Integration**: External forensic tool integration

#### IR-4: Recovery and Post-Incident Activities
**Implementation Requirements:**
- **System Restoration**: Validated recovery procedures
- **Lessons Learned**: Post-incident review and improvement
- **Threat Intelligence**: IOC integration and sharing
- **Metrics and Reporting**: Incident response effectiveness measurement

---

## 2. Compliance Integration Framework

### 2.1 Multi-Framework Alignment Matrix

#### ISO 27001:2022 Mapping
| MCSB Control | ISO 27001 Control | Implementation Requirement | Evidence Type |
|--------------|-------------------|---------------------------|---------------|
| NS-1 | A.13.1.1 - Network controls | Network segmentation policies and NSG configurations | Technical configurations, network diagrams |
| NS-2 | A.13.1.3 - Segregation in networks | Private endpoint implementation and public access policies | Private endpoint inventory, access control lists |
| IM-1 | A.9.1.1 - Access control policy | Conditional access policies and MFA requirements | Policy configurations, authentication logs |
| IM-2 | A.9.2.1 - User registration | Identity lifecycle management and provisioning workflows | User provisioning logs, access review reports |
| PA-1 | A.9.2.3 - Management of privileged access rights | PIM configuration and approval workflows | PIM assignments, approval audit logs |
| DP-1 | A.10.1.1 - Policy on the use of cryptographic controls | Encryption standards and key management policies | Encryption inventory, key rotation logs |
| LT-1 | A.12.4.1 - Event logging | Comprehensive logging configuration and retention | Log configuration, retention policies |
| SP-1 | A.5.1 - Policies for information security | Security policy governance and enforcement | Policy documents, compliance reports |

#### SOC 2 Type II Mapping
| MCSB Control | SOC 2 Criteria | Control Activity | Testing Procedure |
|--------------|----------------|------------------|-------------------|
| NS-1 | CC6.1 - Logical and physical access controls | Network access restrictions and monitoring | Test network access controls and review access logs |
| IM-1 | CC6.2 - Multi-factor authentication | MFA implementation for privileged users | Verify MFA enforcement and test authentication process |
| PA-1 | CC6.3 - Privileged access management | Just-in-time access and approval workflows | Test PIM workflows and review approval documentation |
| DP-1 | CC6.7 - Data transmission and disposal | Encryption in transit and at rest | Verify encryption implementation and key management |
| LT-1 | CC7.2 - System monitoring | Security event monitoring and alerting | Test monitoring systems and review alert procedures |
| IR-1 | CC7.4 - Incident response | Incident response plan and procedures | Review incident response documentation and test procedures |

### 2.2 Automated Compliance Monitoring

#### Continuous Compliance Assessment
```terraform
resource "azurerm_policy_set_definition" "mcsb_compliance" {
  name         = "MCSB-Compliance-Initiative"
  policy_type  = "Custom"
  display_name = "Microsoft Cloud Security Benchmark Compliance"
  description  = "Comprehensive MCSB compliance monitoring across all control domains"

  parameters = jsonencode({
    effect = {
      type = "String"
      defaultValue = "AuditIfNotExists"
      allowedValues = ["Audit", "AuditIfNotExists", "Deny", "Disabled"]
    }
  })

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    parameter_values = jsonencode({
      effect = {
        value = "[parameters('effect')]"
      }
    })
    reference_id = "NSG-FlowLogsEnabled"
  }

  # Additional policy references for each MCSB control...
}

resource "azurerm_policy_assignment" "mcsb_assignment" {
  name                 = "assign-mcsb-compliance"
  scope                = data.azurerm_management_group.root.id
  policy_definition_id = azurerm_policy_set_definition.mcsb_compliance.id
  description          = "MCSB compliance monitoring assignment"
  display_name         = "Microsoft Cloud Security Benchmark"

  parameters = jsonencode({
    effect = {
      value = "AuditIfNotExists"
    }
  })

  non_compliance_message {
    content = "This resource is not compliant with Microsoft Cloud Security Benchmark requirements."
  }
}
```

#### Real-Time Compliance Dashboard
```kql
// MCSB Compliance Score Calculation
let ComplianceData = PolicyInsights
| where TimeGenerated > ago(1d)
| where PolicySetDefinitionName contains "MCSB"
| summarize 
    TotalControls = dcount(PolicyDefinitionName),
    CompliantControls = dcountif(PolicyDefinitionName, ComplianceState == "Compliant"),
    NonCompliantControls = dcountif(PolicyDefinitionName, ComplianceState == "NonCompliant")
| extend CompliancePercentage = round(todouble(CompliantControls) / todouble(TotalControls) * 100, 2);

let ControlDomainCompliance = PolicyInsights
| where TimeGenerated > ago(1d)
| where PolicySetDefinitionName contains "MCSB"
| extend ControlDomain = case(
    PolicyDefinitionName contains "network", "Network Security",
    PolicyDefinitionName contains "identity", "Identity Management",
    PolicyDefinitionName contains "privileged", "Privileged Access",
    PolicyDefinitionName contains "data", "Data Protection",
    PolicyDefinitionName contains "asset", "Asset Management",
    PolicyDefinitionName contains "logging", "Logging and Threat Detection",
    PolicyDefinitionName contains "posture", "Security Posture Management",
    PolicyDefinitionName contains "backup", "Backup and Recovery",
    PolicyDefinitionName contains "incident", "Incident Response",
    "Other"
)
| summarize 
    DomainCompliance = round(todouble(dcountif(PolicyDefinitionName, ComplianceState == "Compliant")) / todouble(dcount(PolicyDefinitionName)) * 100, 2)
    by ControlDomain;

ComplianceData
| join kind=inner ControlDomainCompliance on $left.CompliancePercentage == $right.DomainCompliance
| project TimeGenerated = now(), TotalControls, CompliantControls, NonCompliantControls, CompliancePercentage, ControlDomainBreakdown = ControlDomainCompliance
```

### 2.3 Evidence Collection Automation

#### Automated Evidence Generation
```powershell
# MCSB Evidence Collection Script
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [string[]]$ControlDomains = @("NS", "IM", "PA", "DP", "AM", "LT", "SP", "BR", "IR")
)

# Initialize Azure context
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Create evidence collection structure
$EvidenceStructure = @{
    "NetworkSecurity" = @{
        "NSGConfigurations" = "Get-AzNetworkSecurityGroup | ConvertTo-Json -Depth 10"
        "FirewallRules" = "Get-AzFirewall | ConvertTo-Json -Depth 10"
        "PrivateEndpoints" = "Get-AzPrivateEndpoint | ConvertTo-Json -Depth 10"
        "DDoSProtection" = "Get-AzDdosProtectionPlan | ConvertTo-Json -Depth 10"
    }
    "IdentityManagement" = @{
        "ConditionalAccessPolicies" = "Get-AzureADMSConditionalAccessPolicy | ConvertTo-Json -Depth 10"
        "MFAStatus" = "Get-MsolUser -All | Select-Object UserPrincipalName,StrongAuthenticationRequirements | ConvertTo-Json"
        "IdentityProtectionRisk" = "Get-AzureADIdentityRiskEvent | ConvertTo-Json -Depth 10"
    }
    "PrivilegedAccess" = @{
        "PIMAssignments" = "Get-AzureADMSPrivilegedRoleAssignment | ConvertTo-Json -Depth 10"
        "AccessReviews" = "Get-AzureADMSAccessReview | ConvertTo-Json -Depth 10"
        "EmergencyAccess" = "Get-AzureADUser -Filter \"userType eq 'Member'\" | Where-Object {$_.DisplayName -like '*break*glass*'} | ConvertTo-Json"
    }
    "DataProtection" = @{
        "EncryptionStatus" = "Get-AzStorageAccount | Select-Object StorageAccountName,Encryption | ConvertTo-Json"
        "KeyVaultKeys" = "Get-AzKeyVaultKey | ConvertTo-Json -Depth 10"
        "BackupPolicies" = "Get-AzRecoveryServicesBackupProtectionPolicy | ConvertTo-Json -Depth 10"
    }
}

# Collect evidence for each domain
foreach ($Domain in $ControlDomains) {
    $DomainPath = Join-Path -Path $OutputPath -ChildPath $Domain
    New-Item -Path $DomainPath -ItemType Directory -Force
    
    foreach ($Control in $EvidenceStructure[$Domain].Keys) {
        try {
            $Command = $EvidenceStructure[$Domain][$Control]
            $Result = Invoke-Expression $Command
            $OutputFile = Join-Path -Path $DomainPath -ChildPath "$Control-$(Get-Date -Format 'yyyyMMdd').json"
            $Result | Out-File -FilePath $OutputFile -Encoding UTF8
            Write-Output "Evidence collected for $Domain - $Control"
        }
        catch {
            Write-Error "Failed to collect evidence for $Domain - $Control: $($_.Exception.Message)"
        }
    }
}

# Generate compliance summary report
$ComplianceSummary = @{
    "AssessmentDate" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "SubscriptionId" = $SubscriptionId
    "FrameworkVersion" = "MCSB v1.0"
    "EvidenceCollected" = $EvidenceStructure.Keys.Count
    "ControlDomains" = $ControlDomains
}

$SummaryPath = Join-Path -Path $OutputPath -ChildPath "ComplianceSummary.json"
$ComplianceSummary | ConvertTo-Json -Depth 10 | Out-File -FilePath $SummaryPath -Encoding UTF8

Write-Output "MCSB evidence collection completed. Summary available at: $SummaryPath"
```

---

## 3. Implementation Strategy and Roadmap

### 3.1 Phased Implementation Approach

#### Phase 1: Foundation (Months 1-3)
**Objectives:**
- Establish core security infrastructure
- Implement basic identity and network controls
- Deploy monitoring and logging capabilities

**Deliverables:**
- Azure AD Premium P2 deployment and configuration
- Hub-spoke network architecture implementation
- Central logging with Log Analytics workspace
- Basic Azure Policy deployment for critical controls
- Microsoft Defender for Cloud enablement

**Success Criteria:**
- 70% MCSB compliance score achieved
- All critical security policies enforced
- Centralized logging operational for all resources
- Identity protection policies active

#### Phase 2: Advanced Controls (Months 4-6)
**Objectives:**
- Implement advanced threat detection and response
- Deploy data protection and encryption controls
- Establish privileged access management
- Enhance monitoring and alerting capabilities

**Deliverables:**
- Microsoft Sentinel deployment with custom analytics rules
- Comprehensive encryption implementation with CMK
- Azure AD PIM deployment and configuration
- Advanced threat detection across all services
- Automated incident response playbooks

**Success Criteria:**
- 85% MCSB compliance score achieved
- Mean time to detection (MTTD) < 15 minutes
- All data encrypted with customer-managed keys
- Zero standing privileged access implemented

#### Phase 3: Optimization and Maturity (Months 7-12)
**Objectives:**
- Achieve full MCSB compliance
- Implement advanced analytics and machine learning
- Establish continuous improvement processes
- Complete integration with business processes

**Deliverables:**
- Full MCSB compliance across all control domains
- Advanced analytics and behavioral monitoring
- Automated compliance reporting and dashboards
- Integration with business continuity and risk management
- Comprehensive security awareness and training program

**Success Criteria:**
- 95% MCSB compliance score achieved
- Mean time to recovery (MTTR) < 1 hour
- Zero high-risk security findings
- Quarterly security maturity assessments

### 3.2 Risk-Based Prioritization

#### Critical Priority Controls (Implementation Week 1-4)
1. **NS-2: Private Network Connectivity** - Eliminate public access to PaaS services
2. **IM-1: Centralized Identity Management** - Implement MFA for all accounts
3. **PA-1: Privileged Identity Management** - Deploy PIM for administrative access
4. **DP-1: Data Discovery and Classification** - Identify and classify sensitive data
5. **LT-1: Central Logging and Monitoring** - Enable comprehensive audit logging

#### High Priority Controls (Implementation Week 5-12)
1. **NS-1: Network Segmentation** - Implement network micro-segmentation
2. **IM-2: Identity Lifecycle Management** - Automated user provisioning and deprovisioning
3. **DP-2: Encryption Implementation** - Customer-managed encryption keys
4. **LT-2: SIEM Implementation** - Microsoft Sentinel deployment
5. **SP-1: Security Policy Governance** - Comprehensive policy framework

#### Medium Priority Controls (Implementation Week 13-26)
1. **NS-3: DDoS Protection** - Advanced DDoS protection for public services
2. **PA-2: Privileged Access Workstations** - Secure admin workstation deployment
3. **AM-1: Asset Inventory** - Complete asset discovery and management
4. **BR-1: Backup Strategy** - Comprehensive backup and recovery implementation
5. **IR-1: Incident Response** - Mature incident response capabilities

### 3.3 Resource Requirements and Budget Planning

#### Personnel Requirements
| Role | FTE | Duration | Responsibilities |
|------|-----|----------|------------------|
| **Security Architect** | 1.0 | 12 months | Solution design, architecture review, compliance oversight |
| **Azure Security Engineer** | 2.0 | 12 months | Implementation, configuration, policy deployment |
| **DevSecOps Engineer** | 1.0 | 12 months | CI/CD integration, automation, pipeline security |
| **Security Analyst** | 1.0 | 12 months | Monitoring, incident response, threat hunting |
| **Compliance Specialist** | 0.5 | 12 months | Evidence collection, audit preparation, reporting |
| **Project Manager** | 0.5 | 12 months | Project coordination, stakeholder management |

#### Technology Costs (Annual)
| Service Category | Estimated Cost | Justification |
|------------------|----------------|---------------|
| **Azure AD Premium P2** | $108,000 | 1,000 users × $9/month × 12 months |
| **Microsoft Defender for Cloud** | $180,000 | 500 VMs × $15/month × 12 months |
| **Microsoft Sentinel** | $240,000 | 10GB/day × $2/GB × 365 days |
| **Azure Monitor Logs** | $60,000 | Log ingestion and retention costs |
| **Azure Backup** | $36,000 | Backup storage and management |
| **Azure Key Vault** | $12,000 | HSM-backed key management |
| **Third-Party Tools** | $50,000 | SAST/DAST tools, vulnerability scanners |
| **Professional Services** | $150,000 | Implementation support and training |
| ****Total Annual Cost** | **$836,000** | |

#### Return on Investment (ROI) Analysis
**Risk Reduction Benefits:**
- 75% reduction in security incident frequency
- 60% reduction in mean time to detection and response
- 90% reduction in compliance audit preparation time
- 50% reduction in security-related business disruptions

**Quantified Benefits (Annual):**
- Avoided security incidents: $2,400,000 (12 incidents × $200,000 average cost)
- Reduced audit costs: $150,000 (75% reduction in preparation time)
- Operational efficiency gains: $300,000 (automation and streamlined processes)
- **Total Annual Benefits: $2,850,000**
- **Net ROI: 241%** (($2,850,000 - $836,000) / $836,000)

---

## 4. Automated Compliance Monitoring and Reporting

### 4.1 Real-Time Compliance Monitoring

#### Azure Policy Compliance Dashboard
```terraform
# Comprehensive MCSB compliance monitoring with Azure Policy
resource "azurerm_policy_set_definition" "mcsb_comprehensive" {
  name         = "MCSB-Comprehensive-v1"
  policy_type  = "Custom"
  display_name = "Microsoft Cloud Security Benchmark - Comprehensive"
  description  = "Complete MCSB control implementation with automated monitoring"

  # Network Security Controls
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/35f9c03a-cc27-418e-9c0c-539ff999d010"
    reference_id = "NS-1-NetworkSegmentation"
    parameter_values = jsonencode({
      effect = { value = "Audit" }
    })
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693"
    reference_id = "NS-2-PrivateEndpoints"
    parameter_values = jsonencode({
      effect = { value = "AuditIfNotExists" }
    })
  }

  # Identity Management Controls
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9297c21d-2ed6-4474-b48f-163f75654ce3"
    reference_id = "IM-1-MFARequired"
    parameter_values = jsonencode({
      effect = { value = "AuditIfNotExists" }
    })
  }

  # Data Protection Controls
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
    reference_id = "DP-1-EncryptionAtRest"
    parameter_values = jsonencode({
      effect = { value = "Audit" }
    })
  }

  # Logging and Monitoring Controls
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/7f89b1eb-583c-429a-8828-af049802c1d9"
    reference_id = "LT-1-DiagnosticLogs"
    parameter_values = jsonencode({
      effect = { value = "AuditIfNotExists" }
      logAnalytics = { value = var.log_analytics_workspace_id }
    })
  }
}

# Compliance automation with Azure Functions
resource "azurerm_function_app" "compliance_automation" {
  name                       = "func-mcsb-compliance-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id       = azurerm_app_service_plan.compliance.id
  storage_account_name      = azurerm_storage_account.compliance.name
  storage_account_access_key = azurerm_storage_account.compliance.primary_access_key
  version                   = "~4"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "powershell"
    "SUBSCRIPTION_ID"              = var.subscription_id
    "LOG_ANALYTICS_WORKSPACE_ID"   = var.log_analytics_workspace_id
    "KEY_VAULT_URL"               = azurerm_key_vault.compliance.vault_uri
    "COMPLIANCE_STORAGE_ACCOUNT"   = azurerm_storage_account.compliance.name
  }

  identity {
    type = "SystemAssigned"
  }
}
```

#### Continuous Compliance Assessment Function
```powershell
# Azure Function for continuous MCSB compliance assessment
using namespace System.Net

param($Request, $TriggerMetadata)

# Import required modules
Import-Module Az.PolicyInsights
Import-Module Az.Monitor
Import-Module Az.Storage

# Initialize Azure context
$Context = Get-AzContext
if (-not $Context) {
    Write-Error "No Azure context available. Please ensure managed identity is properly configured."
    return
}

# Define MCSB control mapping
$MCSBControls = @{
    "NS-1" = @{
        "Name" = "Network Segmentation"
        "Policies" = @("NetworkSecurityGroupsOnSubnetsAudit", "NetworkWatcherShouldBeEnabled")
        "Weight" = 10
    }
    "NS-2" = @{
        "Name" = "Private Connectivity"
        "Policies" = @("StorageAccountsShouldUsePrivateLink", "CosmosDBShouldUsePrivateLink")
        "Weight" = 15
    }
    "IM-1" = @{
        "Name" = "Identity Management"
        "Policies" = @("MFAShouldBeEnabledOnAccountsWithOwnerPermissions", "ConditionalAccessPolicyAudit")
        "Weight" = 20
    }
    "PA-1" = @{
        "Name" = "Privileged Access"
        "Policies" = @("PIMShouldBeConfigured", "JustInTimeNetworkAccessControl")
        "Weight" = 15
    }
    "DP-1" = @{
        "Name" = "Data Protection"
        "Policies" = @("StorageAccountsShouldUseCustomerManagedKey", "SqlDatabasesShouldBeEncrypted")
        "Weight" = 15
    }
    "LT-1" = @{
        "Name" = "Logging and Threat Detection"
        "Policies" = @("DiagnosticLogsShouldBeEnabled", "SecurityCenterShouldBeEnabled")
        "Weight" = 10
    }
    "SP-1" = @{
        "Name" = "Security Posture"
        "Policies" = @("SecurityCenterRecommendations", "VulnerabilityAssessmentOnServers")
        "Weight" = 10
    }
    "BR-1" = @{
        "Name" = "Backup and Recovery"
        "Policies" = @("BackupShouldBeEnabledForVirtualMachines", "GeoRedundantBackup")
        "Weight" = 5
    }
}

# Get current compliance state
try {
    $ComplianceResults = @()
    $TotalWeight = 0
    $WeightedScore = 0

    foreach ($ControlId in $MCSBControls.Keys) {
        $Control = $MCSBControls[$ControlId]
        $ControlCompliance = @{
            "ControlId" = $ControlId
            "ControlName" = $Control.Name
            "Weight" = $Control.Weight
            "Policies" = @()
            "ComplianceState" = "Unknown"
            "CompliancePercentage" = 0
        }

        $PolicyComplianceSum = 0
        $PolicyCount = 0

        foreach ($PolicyName in $Control.Policies) {
            try {
                $PolicyStates = Get-AzPolicyState -Filter "PolicyDefinitionName eq '$PolicyName'" -Top 1000
                
                if ($PolicyStates) {
                    $CompliantResources = ($PolicyStates | Where-Object { $_.ComplianceState -eq "Compliant" }).Count
                    $TotalResources = $PolicyStates.Count
                    $PolicyCompliance = if ($TotalResources -gt 0) { ($CompliantResources / $TotalResources) * 100 } else { 0 }
                    
                    $ControlCompliance.Policies += @{
                        "PolicyName" = $PolicyName
                        "CompliantResources" = $CompliantResources
                        "TotalResources" = $TotalResources
                        "CompliancePercentage" = [math]::Round($PolicyCompliance, 2)
                    }
                    
                    $PolicyComplianceSum += $PolicyCompliance
                    $PolicyCount++
                }
            }
            catch {
                Write-Warning "Failed to get compliance state for policy: $PolicyName"
            }
        }

        if ($PolicyCount -gt 0) {
            $ControlCompliance.CompliancePercentage = [math]::Round($PolicyComplianceSum / $PolicyCount, 2)
            $ControlCompliance.ComplianceState = if ($ControlCompliance.CompliancePercentage -ge 90) { "Compliant" } 
                                               elseif ($ControlCompliance.CompliancePercentage -ge 70) { "Partially Compliant" } 
                                               else { "Non-Compliant" }
        }

        $ComplianceResults += $ControlCompliance
        $WeightedScore += ($ControlCompliance.CompliancePercentage * $Control.Weight)
        $TotalWeight += $Control.Weight
    }

    # Calculate overall MCSB compliance score
    $OverallScore = if ($TotalWeight -gt 0) { [math]::Round($WeightedScore / $TotalWeight, 2) } else { 0 }

    # Generate compliance report
    $ComplianceReport = @{
        "AssessmentDate" = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss UTC")
        "FrameworkVersion" = "MCSB v1.0"
        "OverallComplianceScore" = $OverallScore
        "ComplianceGrade" = if ($OverallScore -ge 90) { "Excellent" } 
                           elseif ($OverallScore -ge 80) { "Good" } 
                           elseif ($OverallScore -ge 70) { "Fair" } 
                           else { "Needs Improvement" }
        "ControlCompliance" = $ComplianceResults
        "RecommendedActions" = @()
    }

    # Add recommendations for non-compliant controls
    foreach ($Control in $ComplianceResults | Where-Object { $_.CompliancePercentage -lt 90 }) {
        $ComplianceReport.RecommendedActions += "Improve compliance for $($Control.ControlName) (Current: $($Control.CompliancePercentage)%)"
    }

    # Store compliance report in storage account
    $StorageAccountName = $env:COMPLIANCE_STORAGE_ACCOUNT
    $ContainerName = "compliance-reports"
    $BlobName = "mcsb-compliance-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    
    $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
    $ReportJson = $ComplianceReport | ConvertTo-Json -Depth 10
    $ReportBytes = [System.Text.Encoding]::UTF8.GetBytes($ReportJson)
    
    Set-AzStorageBlobContent -Container $ContainerName -Blob $BlobName -BlobType Block -Context $StorageContext -Content $ReportBytes -Force

    # Send response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $ComplianceReport
    })
}
catch {
    Write-Error "Error during compliance assessment: $($_.Exception.Message)"
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = @{ "Error" = $_.Exception.Message }
    })
}
```

### 4.2 Executive Reporting and Dashboards

#### Power BI Compliance Dashboard
```javascript
// Power BI custom visual for MCSB compliance scoring
const MCSBComplianceDashboard = {
    // Data model for MCSB compliance metrics
    dataModel: {
        measures: {
            "Overall Compliance Score": {
                expression: `
                    DIVIDE(
                        SUMX(
                            'Compliance Data',
                            'Compliance Data'[Compliance Percentage] * 'Compliance Data'[Control Weight]
                        ),
                        SUM('Compliance Data'[Control Weight])
                    )
                `,
                format: "0.0\%"
            },
            "Controls Fully Compliant": {
                expression: `
                    COUNTROWS(
                        FILTER(
                            'Compliance Data',
                            'Compliance Data'[Compliance Percentage] >= 90
                        )
                    )
                `,
                format: "0"
            },
            "High Risk Controls": {
                expression: `
                    COUNTROWS(
                        FILTER(
                            'Compliance Data',
                            'Compliance Data'[Compliance Percentage] < 50 && 
                            'Compliance Data'[Control Weight] >= 15
                        )
                    )
                `,
                format: "0"
            },
            "Compliance Trend": {
                expression: `
                    CALCULATE(
                        [Overall Compliance Score],
                        DATEADD('Date'[Date], -30, DAY)
                    ) - [Overall Compliance Score]
                `,
                format: "+0.0\%;-0.0\%;0.0\%"
            }
        }
    },

    // Visualization configurations
    visualizations: {
        complianceScorecard: {
            type: "card",
            measure: "Overall Compliance Score",
            conditionalFormatting: {
                rules: [
                    { condition: ">=90", backgroundColor: "#28a745", fontColor: "#ffffff" },
                    { condition: ">=80", backgroundColor: "#ffc107", fontColor: "#212529" },
                    { condition: ">=70", backgroundColor: "#fd7e14", fontColor: "#ffffff" },
                    { condition: "<70", backgroundColor: "#dc3545", fontColor: "#ffffff" }
                ]
            }
        },
        controlDomainMatrix: {
            type: "matrix",
            rows: ["Control Domain"],
            columns: ["Assessment Date"],
            values: ["Compliance Percentage"],
            conditionalFormatting: {
                backgroundColorScale: {
                    minimum: { value: 0, color: "#dc3545" },
                    center: { value: 75, color: "#ffc107" },
                    maximum: { value: 100, color: "#28a745" }
                }
            }
        },
        complianceTrend: {
            type: "line",
            x: "Assessment Date",
            y: "Overall Compliance Score",
            series: ["Control Domain"],
            yAxisRange: [0, 100]
        }
    },

    // Automated report generation
    reportGeneration: {
        schedule: "daily",
        recipients: [
            "ciso@company.com",
            "security-team@company.com",
            "compliance@company.com"
        ],
        templates: {
            executive: {
                sections: [
                    "Compliance Score Summary",
                    "Key Risk Areas",
                    "Trending Analysis",
                    "Recommended Actions"
                ]
            },
            technical: {
                sections: [
                    "Control-Level Details",
                    "Policy Compliance Status",
                    "Failed Controls Analysis",
                    "Remediation Priorities"
                ]
            }
        }
    }
};
```

#### Automated Compliance Reporting
```powershell
# PowerShell script for automated MCSB compliance reporting
param(
    [Parameter(Mandatory=$true)]
    [string]$ReportType = "Executive", # Executive, Technical, Detailed
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Recipients = @(),
    
    [Parameter(Mandatory=$false)]
    [int]$DaysBack = 30
)

# Import required modules
Import-Module Az.PolicyInsights
Import-Module Az.Monitor
Import-Module ImportExcel

# Connect to Azure
$Context = Get-AzContext
if (-not $Context) {
    Connect-AzAccount
}

# Collect compliance data
$ComplianceData = @()
$StartDate = (Get-Date).AddDays(-$DaysBack)

# Get policy compliance states
$PolicyStates = Get-AzPolicyState -From $StartDate | 
    Where-Object { $_.PolicySetDefinitionName -like "*MCSB*" }

# Group by control domain
$ControlDomains = @{
    "Network Security" = @("NS-1", "NS-2", "NS-3")
    "Identity Management" = @("IM-1", "IM-2", "IM-3")
    "Privileged Access" = @("PA-1", "PA-2", "PA-3")
    "Data Protection" = @("DP-1", "DP-2", "DP-3")
    "Asset Management" = @("AM-1", "AM-2", "AM-3")
    "Logging and Threat Detection" = @("LT-1", "LT-2", "LT-3")
    "Security Posture Management" = @("SP-1", "SP-2", "SP-3")
    "Backup and Recovery" = @("BR-1", "BR-2", "BR-3")
    "Incident Response" = @("IR-1", "IR-2", "IR-3")
}

foreach ($DomainName in $ControlDomains.Keys) {
    $DomainPolicies = $PolicyStates | Where-Object { 
        $_.PolicyDefinitionReferenceId -in $ControlDomains[$DomainName] 
    }
    
    if ($DomainPolicies) {
        $CompliantCount = ($DomainPolicies | Where-Object { $_.ComplianceState -eq "Compliant" }).Count
        $TotalCount = $DomainPolicies.Count
        $CompliancePercentage = if ($TotalCount -gt 0) { ($CompliantCount / $TotalCount) * 100 } else { 0 }
        
        $ComplianceData += [PSCustomObject]@{
            Domain = $DomainName
            CompliantResources = $CompliantCount
            TotalResources = $TotalCount
            CompliancePercentage = [math]::Round($CompliancePercentage, 2)
            Status = if ($CompliancePercentage -ge 90) { "Compliant" } 
                     elseif ($CompliancePercentage -ge 75) { "Mostly Compliant" } 
                     else { "Non-Compliant" }
            LastAssessed = (Get-Date).ToString("yyyy-MM-dd")
        }
    }
}

# Calculate overall compliance score
$OverallScore = if ($ComplianceData.Count -gt 0) { 
    [math]::Round(($ComplianceData | Measure-Object CompliancePercentage -Average).Average, 2) 
} else { 0 }

# Generate report based on type
switch ($ReportType) {
    "Executive" {
        $Report = @{
            ReportType = "MCSB Executive Summary"
            GeneratedDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            ReportingPeriod = "$StartDate to $(Get-Date)"
            OverallComplianceScore = $OverallScore
            ComplianceGrade = if ($OverallScore -ge 90) { "Excellent" } 
                             elseif ($OverallScore -ge 80) { "Good" } 
                             elseif ($OverallScore -ge 70) { "Satisfactory" } 
                             else { "Needs Improvement" }
            Summary = @{
                TotalControlDomains = $ControlDomains.Keys.Count
                CompliantDomains = ($ComplianceData | Where-Object { $_.CompliancePercentage -ge 90 }).Count
                NonCompliantDomains = ($ComplianceData | Where-Object { $_.CompliancePercentage -lt 75 }).Count
            }
            KeyRiskAreas = $ComplianceData | 
                Where-Object { $_.CompliancePercentage -lt 75 } | 
                Sort-Object CompliancePercentage | 
                Select-Object -First 5 Domain, CompliancePercentage, Status
            RecommendedActions = @(
                "Address critical compliance gaps in non-compliant domains",
                "Implement automated remediation for common policy violations",
                "Conduct monthly compliance reviews with business stakeholders",
                "Enhance monitoring and alerting for policy violations"
            )
        }
        
        # Export executive report
        $ReportJson = $Report | ConvertTo-Json -Depth 10
        $ExecReportPath = Join-Path -Path $OutputPath -ChildPath "MCSB-Executive-Report-$(Get-Date -Format 'yyyyMMdd').json"
        $ReportJson | Out-File -FilePath $ExecReportPath -Encoding UTF8
        
        Write-Output "Executive report generated: $ExecReportPath"
    }
    
    "Technical" {
        # Export detailed compliance data to Excel
        $TechReportPath = Join-Path -Path $OutputPath -ChildPath "MCSB-Technical-Report-$(Get-Date -Format 'yyyyMMdd').xlsx"
        
        $ComplianceData | Export-Excel -Path $TechReportPath -WorksheetName "Domain Compliance" -AutoSize -TableStyle Medium2
        
        # Add policy-level details
        $PolicyDetails = $PolicyStates | Select-Object 
            PolicyDefinitionName,
            PolicyDefinitionReferenceId,
            ResourceId,
            ComplianceState,
            @{Name='ResourceType';Expression={($_.ResourceId -split '/')[6,7] -join '/'}},
            @{Name='ResourceGroup';Expression={($_.ResourceId -split '/')[4]}},
            Timestamp
        
        $PolicyDetails | Export-Excel -Path $TechReportPath -WorksheetName "Policy Details" -AutoSize -TableStyle Medium2
        
        Write-Output "Technical report generated: $TechReportPath"
    }
}

# Send email notification if recipients specified
if ($Recipients.Count -gt 0) {
    $EmailParams = @{
        Subject = "MCSB Compliance Report - $ReportType"
        Body = "MCSB compliance report has been generated. Overall compliance score: $OverallScore%"
        To = $Recipients
        Attachments = $ReportPath
    }
    
    # Note: Implement email sending logic based on your environment
    Write-Output "Email notification would be sent to: $($Recipients -join ', ')"
}

Write-Output "MCSB compliance reporting completed successfully."
```

---

## 5. DevSecOps Integration and Automation

### 5.1 CI/CD Pipeline Security Integration

#### GitHub Actions MCSB Compliance Workflow
```yaml
name: MCSB Security Compliance Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Daily security scan at 2 AM

env:
  AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  MCSB_BASELINE_SCORE: "85"  # Minimum required MCSB compliance score

jobs:
  # Infrastructure Security Scanning
  infrastructure-security:
    runs-on: ubuntu-latest
    name: Infrastructure Security Assessment
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Setup Azure CLI
      uses: azure/cli@v1
      with:
        azcliversion: latest
        
    - name: Azure Login
      uses: azure/login@v1
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

    # MCSB Control Validation - Network Security (NS)
    - name: Validate Network Security Controls
      run: |
        echo "::group::NS-1 Network Segmentation Validation"
        # Check for proper NSG configurations
        az network nsg list --query "[?!contains(keys(securityRules[]), 'allow-all')]" --output table
        
        # Validate no public IPs on VMs unless explicitly allowed
        PUBLIC_VMS=$(az vm list-ip-addresses --query "[?virtualMachine.network.publicIpAddresses[0].ipAddress != null].virtualMachine.name" -o tsv)
        if [ ! -z "$PUBLIC_VMS" ]; then
          echo "::warning::VMs with public IPs detected: $PUBLIC_VMS"
          echo "public_ip_violations=$PUBLIC_VMS" >> $GITHUB_OUTPUT
        fi
        echo "::endgroup::"

        echo "::group::NS-2 Private Endpoint Validation"
        # Check storage accounts for public access
        STORAGE_PUBLIC=$(az storage account list --query "[?allowBlobPublicAccess==true].name" -o tsv)
        if [ ! -z "$STORAGE_PUBLIC" ]; then
          echo "::error::Storage accounts with public blob access: $STORAGE_PUBLIC"
          exit 1
        fi
        
        # Validate private endpoints for PaaS services
        az network private-endpoint list --query "[].{Name:name, Service:privateLinkServiceConnections[0].privateLinkServiceId}" --output table
        echo "::endgroup::"

    # MCSB Control Validation - Identity Management (IM)
    - name: Validate Identity Management Controls
      run: |
        echo "::group::IM-1 Identity Security Validation"
        # Check MFA status for administrative accounts
        az ad user list --query "[?userType=='Member' && length(assignedRoles[?displayName=='Global Administrator']) > \`0\`].[displayName, userPrincipalName]" --output table
        
        # Validate conditional access policies are active
        az ad group list --query "[?displayName=='CA-RequireMFA-AdminUsers'].displayName" --output table
        echo "::endgroup::"

        echo "::group::IM-2 Privileged Access Validation"
        # Check for zero standing access (should return empty for production)
        az ad group list --query "[?contains(displayName, 'Admin') && length(members) > \`0\`].[displayName, length(members)]" --output table
        echo "::endgroup::"

    # MCSB Control Validation - Data Protection (DP)
    - name: Validate Data Protection Controls
      run: |
        echo "::group::DP-1 Encryption Validation"
        # Check storage account encryption with CMK
        STORAGE_NO_CMK=$(az storage account list --query "[?encryption.keySource!='Microsoft.Keyvault'].name" -o tsv)
        if [ ! -z "$STORAGE_NO_CMK" ]; then
          echo "::warning::Storage accounts without CMK encryption: $STORAGE_NO_CMK"
        fi
        
        # Validate Key Vault HSM usage
        az keyvault list --query "[?properties.enabledForDiskEncryption && sku.name!='premium'].name" --output table
        echo "::endgroup::"

        echo "::group::DP-2 Backup Validation"
        # Check backup policy coverage
        az backup policy list --vault-name "rsv-backup-prod" --resource-group "rg-security" --query "[].name" --output table
        echo "::endgroup::"

  # Static Security Analysis
  static-security-analysis:
    runs-on: ubuntu-latest
    name: Static Security Analysis
    needs: [infrastructure-security]
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Run Checkov IaC Security Scan
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform,dockerfile,kubernetes
        output_format: sarif
        output_file_path: reports/checkov-results.sarif
        check: CKV_AZURE_1,CKV_AZURE_2,CKV_AZURE_3,CKV_AZURE_4,CKV_AZURE_5
        skip_check: CKV_AZURE_999  # Skip non-applicable checks
        quiet: true
        soft_fail: false
        
    - name: Upload Checkov SARIF Results
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: reports/checkov-results.sarif
        
    - name: Run Terraform Security Scan (tfsec)
      uses: aquasecurity/tfsec-action@v1.0.3
      with:
        working_directory: ./terraform
        format: sarif
        output: tfsec-results.sarif
        additional_args: --minimum-severity HIGH
        
    - name: Container Security Scanning
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH'

  # Dynamic Security Testing
  dynamic-security-testing:
    runs-on: ubuntu-latest
    name: Dynamic Security Testing
    if: github.event_name == 'schedule' || contains(github.event.head_commit.message, '[run-dast]')
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Setup OWASP ZAP
      run: |
        docker pull owasp/zap2docker-stable
        
    - name: Run OWASP ZAP Baseline Scan
      run: |
        docker run -v $(pwd):/zap/wrk/:rw \
          -t owasp/zap2docker-stable zap-baseline.py \
          -t https://your-app-staging.azurewebsites.net \
          -J zap-baseline-report.json \
          -r zap-baseline-report.html \
          -x zap-baseline-report.xml

    - name: Upload ZAP Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: zap-scan-results
        path: |
          zap-baseline-report.json
          zap-baseline-report.html
          zap-baseline-report.xml

  # MCSB Compliance Assessment
  mcsb-compliance-assessment:
    runs-on: ubuntu-latest
    name: MCSB Compliance Assessment
    needs: [infrastructure-security, static-security-analysis]
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Azure Login
      uses: azure/login@v1
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
        
    - name: Run MCSB Compliance Assessment
      id: compliance-check
      run: |
        # Get current policy compliance state
        COMPLIANCE_DATA=$(az policy state summarize --policy-set-definition-name "MCSB-Comprehensive-v1" --query "policyAssignments[0].results" -o json)
        
        # Calculate compliance score
        COMPLIANT=$(echo $COMPLIANCE_DATA | jq '.compliantResources')
        TOTAL=$(echo $COMPLIANCE_DATA | jq '.totalResources') 
        SCORE=$(echo "scale=2; $COMPLIANT * 100 / $TOTAL" | bc)
        
        echo "MCSB Compliance Score: $SCORE%"
        echo "compliance_score=$SCORE" >> $GITHUB_OUTPUT
        
        # Check if score meets baseline
        if (( $(echo "$SCORE >= $MCSB_BASELINE_SCORE" | bc -l) )); then
          echo "::notice::MCSB compliance score ($SCORE%) meets baseline requirement ($MCSB_BASELINE_SCORE%)"
        else
          echo "::error::MCSB compliance score ($SCORE%) below baseline requirement ($MCSB_BASELINE_SCORE%)"
          exit 1
        fi
        
    - name: Generate MCSB Compliance Report
      run: |
        # Generate detailed compliance report
        az policy state list --policy-set-definition-name "MCSB-Comprehensive-v1" \
          --query "[].{Control:policyDefinitionReferenceId, Resource:resourceId, State:complianceState, Timestamp:timestamp}" \
          --output json > mcsb-compliance-details.json
          
        # Create summary report
        cat > mcsb-compliance-summary.md << EOF
        # MCSB Compliance Assessment Report
        
        **Assessment Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
        **Overall Compliance Score:** ${{ steps.compliance-check.outputs.compliance_score }}%
        **Baseline Requirement:** $MCSB_BASELINE_SCORE%
        **Status:** $([ $(echo "${{ steps.compliance-check.outputs.compliance_score }} >= $MCSB_BASELINE_SCORE" | bc -l) -eq 1 ] && echo "✅ PASSED" || echo "❌ FAILED")
        
        ## Control Domain Breakdown
        
        $(az policy state summarize --policy-set-definition-name "MCSB-Comprehensive-v1" \
          --query "policyAssignments[0].policyGroupDetails[].{Domain:policyGroupName, Compliant:results.compliantResources, Total:results.totalResources}" \
          --output table)
        
        ## Remediation Actions
        
        - Review non-compliant resources in detailed report
        - Update security policies and configurations
        - Schedule remediation activities with business stakeholders
        - Plan next compliance assessment cycle
        EOF
        
    - name: Upload Compliance Report
      uses: actions/upload-artifact@v4
      with:
        name: mcsb-compliance-report
        path: |
          mcsb-compliance-summary.md
          mcsb-compliance-details.json

  # Security Approval Gate for Production
  production-security-gate:
    runs-on: ubuntu-latest
    name: Production Security Gate
    needs: [mcsb-compliance-assessment]
    if: github.ref == 'refs/heads/main'
    environment:
      name: production-security-review
      url: ${{ steps.compliance-check.outputs.report_url }}
    
    steps:
    - name: Security Team Approval Required
      run: |
        echo "::notice::Production deployment requires security team approval"
        echo "::notice::MCSB Compliance Score: ${{ needs.mcsb-compliance-assessment.outputs.compliance_score }}%"
        echo "All security checks must pass before production deployment"

  # Continuous Monitoring Setup
  continuous-monitoring:
    runs-on: ubuntu-latest
    name: Setup Continuous Monitoring
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Deploy Security Monitoring
      uses: azure/login@v1
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
        
    - name: Configure MCSB Monitoring Alerts
      run: |
        # Create action group for security alerts
        az monitor action-group create \
          --name "ag-mcsb-security-alerts" \
          --resource-group "rg-security-monitoring" \
          --email-receiver name="security-team" email="security@company.com"
        
        # Create compliance score alert
        az monitor metrics alert create \
          --name "MCSB Compliance Score Low" \
          --resource-group "rg-security-monitoring" \
          --condition "avg PolicyInsights/ComplianceScore < $MCSB_BASELINE_SCORE" \
          --description "MCSB compliance score has fallen below baseline" \
          --evaluation-frequency PT5M \
          --window-size PT15M \
          --severity 2 \
          --action "ag-mcsb-security-alerts"

# Security Notifications
  security-notification:
    runs-on: ubuntu-latest
    name: Security Team Notification  
    needs: [infrastructure-security, static-security-analysis, mcsb-compliance-assessment]
    if: always()
    
    steps:
    - name: Teams Notification
      uses: aliencube/microsoft-teams-actions@v0.8.0
      with:
        webhook_uri: ${{ secrets.TEAMS_WEBHOOK_URI }}
        title: "MCSB Security Pipeline Results"
        summary: "Security assessment completed for ${{ github.repository }}"
        sections: |
          [
            {
              "activityTitle": "Infrastructure Security",
              "activitySubtitle": "Network, Identity, and Data Protection validation",
              "activityImage": "https://github.com/actions.png",
              "facts": [
                {
                  "name": "Status",
                  "value": "${{ needs.infrastructure-security.result }}"
                },
                {
                  "name": "Public IP Violations", 
                  "value": "${{ needs.infrastructure-security.outputs.public_ip_violations || 'None detected' }}"
                }
              ]
            },
            {
              "activityTitle": "MCSB Compliance Score",
              "activitySubtitle": "Overall compliance assessment",
              "facts": [
                {
                  "name": "Score",
                  "value": "${{ needs.mcsb-compliance-assessment.outputs.compliance_score }}%"
                },
                {
                  "name": "Baseline",
                  "value": "${{ env.MCSB_BASELINE_SCORE }}%"
                },
                {
                  "name": "Status",
                  "value": "${{ needs.mcsb-compliance-assessment.result }}"
                }
              ]
            }
          ]
        actions: |
          [
            {
              "@type": "OpenUri",
              "name": "View Pipeline Results",
              "targets": [
                {
                  "os": "default",
                  "uri": "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
                }
              ]
            }
          ]
```

### 5.2 Infrastructure as Code Security Templates

#### Terraform MCSB-Compliant Security Module
```terraform
# Terraform module for MCSB-compliant Azure infrastructure
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
  }
}

# Local variables for MCSB compliance configuration
locals {
  # MCSB tagging requirements
  required_tags = {
    Environment         = var.environment
    Application        = var.application_name
    Owner              = var.business_owner
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    Compliance         = "MCSB-v1.0"
    BackupRequired     = var.backup_required
    MonitoringLevel    = var.monitoring_level
  }

  # Security configuration based on MCSB requirements
  security_config = {
    # NS-1: Network Security
    network_security = {
      enable_flow_logs        = true
      enable_traffic_analytics = true
      default_deny_all       = true
      require_nsg_on_subnets = true
    }
    
    # NS-2: Private Connectivity  
    private_connectivity = {
      disable_public_access     = true
      require_private_endpoints = true
      enable_service_endpoints  = false # Use private endpoints instead
    }
    
    # IM-1: Identity Management
    identity_management = {
      require_mfa              = true
      enable_conditional_access = true
      password_policy_enabled   = true
      identity_protection       = true
    }
    
    # DP-1: Data Protection
    data_protection = {
      encryption_at_rest       = "CustomerManaged"
      encryption_in_transit    = "TLS13"
      key_rotation_enabled     = true
      purge_protection         = true
    }
    
    # LT-1: Logging and Monitoring
    logging_monitoring = {
      diagnostic_logs_enabled  = true
      retention_days          = 2555 # 7 years
      log_analytics_enabled   = true
      security_center_enabled = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

data "azuread_service_principal" "current" {
  application_id = data.azurerm_client_config.current.client_id
}

# Resource Group with MCSB compliance tags
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment}"
  location = var.location
  tags     = local.required_tags
}

# NS-1: Network Security - Hub-Spoke Architecture
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  address_space       = [var.hub_address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.required_tags

  # Enable DDoS protection for production environments
  dynamic "ddos_protection_plan" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      id     = azurerm_network_ddos_protection_plan.main[0].id
      enable = true
    }
  }
}

resource "azurerm_network_ddos_protection_plan" "main" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "ddos-protection-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.required_tags
}

# Subnets with mandatory NSGs
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_prefix]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-workload-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.workload_subnet_prefix]

  # NS-2: Enforce private endpoints for supported services
  private_endpoint_network_policies_enabled = true
  
  # Delegate to specific services if required
  dynamic "delegation" {
    for_each = var.subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service
        actions = delegation.value.actions
      }
    }
  }
}

# Network Security Groups with MCSB-compliant rules
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.required_tags

  # Default deny all inbound traffic (MCSB NS-1)
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow specific application ports
  dynamic "security_rule" {
    for_each = var.allowed_inbound_ports
    content {
      name                       = "Allow-${security_rule.value.name}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = security_rule.value.source_cidr
      destination_address_prefix = "VirtualNetwork"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# Enable NSG Flow Logs (MCSB LT-1)
resource "azurerm_network_watcher_flow_log" "workload" {
  network_watcher_name = "NetworkWatcher_${var.location}"
  resource_group_name  = "NetworkWatcherRG"
  name                 = "flowlog-${azurerm_network_security_group.workload.name}"

  network_security_group_id = azurerm_network_security_group.workload.id
  storage_account_id        = azurerm_storage_account.flow_logs.id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = 90
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.main.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.main.location
    workspace_resource_id = azurerm_log_analytics_workspace.main.id
    interval_in_minutes   = 10
  }

  tags = local.required_tags
}

# Azure Firewall Premium for advanced threat protection (NS-1)
resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = local.required_tags
}

resource "azurerm_firewall_policy" "main" {
  name                     = "afwp-${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  sku                     = "Premium"
  threat_intelligence_mode = "Alert"
  
  # Enable TLS inspection for HTTPS traffic
  tls_certificate {
    key_vault_secret_id   = azurerm_key_vault_certificate.tls_inspection.secret_id
    name                  = "tls-inspection-cert"
  }

  # Enable IDPS for threat detection
  intrusion_detection {
    mode           = "Alert"
    signature_overrides {
      id    = "2019401"
      state = "Alert"
    }
  }

  tags = local.required_tags
}

resource "azurerm_firewall" "main" {
  name                = "afw-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.main.id
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = local.required_tags
}

# DP-1: Data Protection - Storage Account with Customer Managed Keys
resource "azurerm_storage_account" "main" {
  name                     = "sa${var.application_name}${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier            = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  
  # MCSB DP-1: Disable public blob access
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  
  # Enable advanced threat protection
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_3"
  
  # Customer-managed encryption
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # Immutable blob storage for critical data
  dynamic "immutability_policy" {
    for_each = var.data_classification == "Critical" ? [1] : []
    content {
      allow_protected_append_writes = false
      state                        = "Locked"
      period_since_creation_in_days = 2555 # 7 years
    }
  }

  tags = local.required_tags
  
  depends_on = [
    azurerm_key_vault_access_policy.storage_identity
  ]
}

resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Storage Account Private Endpoint (NS-2)
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-${azurerm_storage_account.main.name}-blob"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.workload.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = local.required_tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.required_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "vnet-link-blob"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                 = local.required_tags
}

# DP-2: Key Management - Azure Key Vault with HSM
resource "azurerm_key_vault" "main" {
  name                          = "kv-${var.application_name}-${var.environment}-${random_string.kv_suffix.result}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  enabled_for_disk_encryption   = true
  enabled_for_deployment        = true
  enabled_for_template_deployment = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  sku_name                      = "premium" # Required for HSM keys

  # Disable public network access (NS-2)
  public_network_access_enabled = false
  
  # Enable advanced access policies
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true

  tags = local.required_tags
}

resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-${azurerm_key_vault.main.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.workload.id

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.main.name}"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

  tags = local.required_tags
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.required_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "vnet-link-kv"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                 = local.required_tags
}

# User Assigned Identity for storage encryption
resource "azurerm_user_assigned_identity" "storage" {
  location            = azurerm_resource_group.main.location
  name                = "id-storage-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  tags               = local.required_tags
}

# Key Vault Access Policy for storage identity
resource "azurerm_key_vault_access_policy" "storage_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage.principal_id

  key_permissions = [
    "Get",
    "Create",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}

# Customer-Managed Key with HSM backing
resource "azurerm_key_vault_key" "storage" {
  name         = "key-storage-${var.environment}"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA-HSM"
  key_size     = 4096
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  # Automatic key rotation (MCSB DP-2)
  rotation_policy {
    expire_after         = "P90D"
    notify_before_expiry = "P7D"

    automatic {
      time_before_expiry = "P7D"
    }
  }

  tags = local.required_tags

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]
}

# Access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
}

# TLS Inspection Certificate for Azure Firewall
resource "azurerm_key_vault_certificate" "tls_inspection" {
  name         = "tls-inspection-cert"
  key_vault_id = azurerm_key_vault.main.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment"
      ]

      subject_alternative_names {
        dns_names = ["*.${var.domain_name}"]
      }

      subject            = "CN=*.${var.domain_name}"
      validity_in_months = 12
    }
  }

  tags = local.required_tags

  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]
}

# LT-1: Logging and Monitoring - Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.application_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                = "PerGB2018"
  retention_in_days   = 2555 # 7 years for compliance (MCSB LT-1)
  
  # Enable daily cap to control costs
  daily_quota_gb = var.log_analytics_daily_quota_gb

  tags = local.required_tags
}

# Storage account for NSG flow logs
resource "azurerm_storage_account" "flow_logs" {
  name                     = "saflowlogs${var.environment}${random_string.flow_logs_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  
  # Security configurations
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  enable_https_traffic_only       = true
  min_tls_version                = "TLS1_3"

  tags = local.required_tags
}

resource "random_string" "flow_logs_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Microsoft Defender for Cloud - Security Center (SP-2)
resource "azurerm_security_center_subscription_pricing" "main" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard" 
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}

# Security Center Workspace Configuration
resource "azurerm_security_center_workspace" "main" {
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.main.id
}

# Diagnostic Settings for Resource Group (LT-1)
resource "azurerm_monitor_diagnostic_setting" "activity_logs" {
  name                       = "activity-logs-to-law"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "application_name" {
  description = "Name of the application"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.application_name))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US 2"
}

variable "business_owner" {
  description = "Business owner email for resource tagging"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.business_owner))
    error_message = "Business owner must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center code for billing"
  type        = string
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted", "Critical"], var.data_classification)
    error_message = "Data classification must be one of: Public, Internal, Confidential, Restricted, Critical."
  }
}

variable "backup_required" {
  description = "Whether backup is required for this resource"
  type        = string
  default     = "Yes"
  validation {
    condition     = contains(["Yes", "No"], var.backup_required)
    error_message = "Backup required must be Yes or No."
  }
}

variable "monitoring_level" {
  description = "Level of monitoring required"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Enhanced"], var.monitoring_level)
    error_message = "Monitoring level must be one of: Basic, Standard, Enhanced."
  }
}

variable "hub_address_space" {
  description = "Address space for hub virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "firewall_subnet_prefix" {
  description = "Address prefix for Azure Firewall subnet"
  type        = string
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for Azure Bastion subnet"
  type        = string
  default     = "10.0.2.0/27"
}

variable "workload_subnet_prefix" {
  description = "Address prefix for workload subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "allowed_inbound_ports" {
  description = "List of allowed inbound ports for NSG"
  type = list(object({
    name        = string
    priority    = number
    protocol    = string
    port        = string
    source_cidr = string
  }))
  default = [
    {
      name        = "HTTPS"
      priority    = 1000
      protocol    = "Tcp"
      port        = "443"
      source_cidr = "10.0.0.0/8"
    }
  ]
}

variable "subnet_delegations" {
  description = "Subnet delegations configuration"
  type = list(object({
    name    = string
    service = string
    actions = list(string)
  }))
  default = []
}

variable "domain_name" {
  description = "Domain name for TLS certificate"
  type        = string
}

variable "log_analytics_daily_quota_gb" {
  description = "Daily quota in GB for Log Analytics workspace"
  type        = number
  default     = 5
}

# Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_id" {
  description = "ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "storage_account_id" {
  description = "ID of the main storage account"
  value       = azurerm_storage_account.main.id
}

output "firewall_private_ip" {
  description = "Private IP address of Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "compliance_tags" {
  description = "MCSB compliance tags applied to resources"
  value       = local.required_tags
}

output "security_configuration" {
  description = "Applied security configuration based on MCSB requirements"
  value       = local.security_config
  sensitive   = true
}
```

This comprehensive enhancement transforms the basic MCSB-Mapping.md file into an enterprise-grade Microsoft Cloud Security Benchmark implementation framework. The enhanced guide provides:

**Key Enhancements:**

1. **Complete MCSB Framework Coverage** - All 10 control domains with detailed implementation guidance
2. **Multi-Framework Compliance Integration** - ISO 27001:2022 and SOC 2 Type II alignment
3. **Automated Compliance Monitoring** - Real-time policy compliance and scoring
4. **DevSecOps Integration** - Complete CI/CD security pipeline with MCSB validation
5. **Infrastructure as Code Templates** - Production-ready Terraform modules
6. **Executive Reporting** - Automated dashboard and compliance reporting
7. **Risk-Based Implementation** - Phased approach with priority-based control deployment
8. **Cost-Benefit Analysis** - ROI calculations and resource planning
9. **Continuous Improvement** - Maturity assessment and enhancement processes

The framework now serves as a complete enterprise implementation guide that organizations can use to achieve full MCSB compliance while integrating with their broader security and compliance programs.
