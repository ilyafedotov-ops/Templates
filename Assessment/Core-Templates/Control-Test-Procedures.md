# Enterprise Security Control Testing Procedures

## Document Control
- **Version**: 2.0
- **Last Updated**: 2025-09-06
- **Classification**: Internal Use
- **Review Frequency**: Annual
- **Owner**: Security Compliance Team
- **Approver**: Chief Information Security Officer

## Purpose and Scope

This document establishes comprehensive testing procedures for security controls in enterprise cloud and hybrid environments, aligned with professional audit standards including ISACA COBIT 2019, NIST Cybersecurity Framework, ISO 27001:2022, SOC 2 Type II, and PCAOB auditing standards. These procedures support internal audits, external audits, compliance assessments, and continuous control monitoring.

**Scope**: All security controls implemented across Azure, hybrid, and multi-cloud environments including identity management, network security, data protection, application security, infrastructure security, monitoring, incident response, governance, and DevSecOps practices.

## Control Testing Methodology Overview

### 1. Framework Alignment

Our control testing methodology incorporates:

- **ISACA COBIT 2019**: Governance and management objectives for enterprise IT
- **NIST Cybersecurity Framework**: Identify, Protect, Detect, Respond, Recover functions
- **ISO 27001:2022**: Information security management system controls (Annex A)
- **SOC 2 Trust Services Criteria**: Security, Availability, Processing Integrity, Confidentiality, Privacy
- **PCAOB AS 2201**: Audit of internal control over financial reporting
- **IIA Standards**: International Standards for the Professional Practice of Internal Auditing

### 2. Control Types and Testing Approaches

#### Design Effectiveness Testing
Evaluates whether controls are appropriately designed to prevent or detect material misstatements or security incidents.

**Design Testing Elements:**
- Control objective alignment
- Process flow documentation
- Authority and segregation of duties
- Risk assessment and mitigation strategies
- Policy and procedure adequacy

#### Operating Effectiveness Testing
Evaluates whether controls operated effectively throughout the testing period.

**Operating Testing Elements:**
- Evidence of control operation
- Consistent application
- Timely execution
- Competence of personnel performing controls
- Effectiveness of monitoring activities

### 3. Control Environment Assessment

Before testing individual controls, assess the overall control environment:

- **Integrity and ethical values**: Code of conduct, ethics training, whistleblower policies
- **Commitment to competence**: Job descriptions, training programs, performance evaluations
- **Board and audit committee**: Governance oversight, independence, expertise
- **Management philosophy**: Risk appetite, tone at the top, management style
- **Organizational structure**: Reporting lines, authority delegation, segregation of duties
- **Human resource policies**: Hiring, orientation, training, evaluation, disciplinary actions

## Testing Approach Framework

### 1. Risk-Based Testing Strategy

Control testing prioritization based on:

- **Inherent Risk Assessment**: Likelihood and impact of threats
- **Control Risk Evaluation**: Reliability of existing controls  
- **Residual Risk Analysis**: Remaining risk after control implementation
- **Business Process Criticality**: Impact on business operations and financial reporting
- **Regulatory Requirements**: Compliance obligations and audit history

### 2. Testing Frequency and Timing

| Control Risk Level | Testing Frequency | Sample Size Minimum |
|-------------------|------------------|---------------------|
| High Risk | Monthly | 25 items or all if <25 |
| Medium Risk | Quarterly | 15-25 items |
| Low Risk | Semi-annually | 10-15 items |
| Administrative | Annually | 5-10 items |

### 3. Control Testing Phases

#### Phase 1: Planning and Preparation (Weeks 1-2)
- Control universe identification
- Risk assessment and prioritization  
- Testing scope definition
- Resource allocation
- Tool and system access verification

#### Phase 2: Design Testing (Weeks 3-4)
- Process documentation review
- Control design evaluation
- Gap analysis and deficiency identification
- Preliminary findings documentation

#### Phase 3: Operating Effectiveness Testing (Weeks 5-8)
- Sample selection and testing execution
- Evidence collection and validation
- Exception identification and investigation
- Control deficiency evaluation

#### Phase 4: Reporting and Remediation (Weeks 9-10)
- Findings consolidation and risk rating
- Management response collection
- Remediation plan development
- Final report preparation and delivery

## Sampling Methodologies

### 1. Statistical Sampling

#### Attribute Sampling
Used when testing for compliance with specific control attributes (e.g., authorization signatures, system access reviews).

**Formula for Sample Size:**
```
n = (Z²× p × (1-p)) / e²
Where:
n = sample size
Z = confidence level (1.96 for 95%, 2.58 for 99%)
p = expected error rate
e = margin of error
```

**Standard Confidence Levels:**
- **High-risk controls**: 95% confidence, 5% tolerable error rate
- **Medium-risk controls**: 90% confidence, 7% tolerable error rate  
- **Low-risk controls**: 85% confidence, 10% tolerable error rate

#### Variable Sampling
Used when testing monetary amounts or quantitative control metrics.

**Sample Sizes by Population:**
- Population <50: Test all items
- Population 50-100: Test 25-30 items
- Population 100-500: Test 30-40 items
- Population 500-1000: Test 40-50 items
- Population >1000: Test 50-60 items

### 2. Judgmental Sampling

Applied when:
- Specific risk factors require targeted testing
- Unusual transactions or exceptions need investigation
- Key controls require comprehensive evaluation
- Limited population sizes make statistical sampling impractical

**Judgmental Sampling Criteria:**
- High-value transactions (top 10% by amount)
- Recent changes in process or personnel
- Prior audit findings or known issues
- Complex or non-routine transactions
- Management override scenarios

### 3. Risk-Based Sampling

Incorporates risk factors into sample selection:

**Risk Weighting Factors:**
- Business process criticality: 30%
- Control complexity: 25%
- Historical issues: 20%
- Regulatory focus: 15%
- Change frequency: 10%

## Evidence Collection Standards

### 1. Evidence Types and Hierarchy

#### Most Reliable Evidence (Tier 1):
- Direct observation of control performance
- Independent confirmations from third parties
- Physical examination of tangible assets
- Re-performance of control activities

#### Moderately Reliable Evidence (Tier 2):
- System-generated reports with strong IT general controls
- Documentation created by external parties
- Internal documentation created contemporaneously
- Analytical procedures with precise expectations

#### Least Reliable Evidence (Tier 3):
- Verbal inquiries and representations
- Internally generated reports without independent verification
- Documents that can be easily altered
- Copies without original verification

### 2. Evidence Sufficiency Requirements

**Sufficient Evidence Must:**
- Cover the complete testing period
- Represent different time periods throughout the year
- Include various personnel performing the control
- Address all control components and objectives
- Demonstrate consistent control operation

**Documentation Standards:**
- Evidence collection date and time
- Source of evidence and collection method
- Personnel involved in control performance
- Testing procedures performed
- Results and conclusions reached
- Exceptions identified and investigated

### 3. Evidence Reliability Assessment

**High Reliability Indicators:**
- Generated by independent systems with strong IT controls  
- Created by external parties without bias
- Obtained through direct inspection or observation
- Consistent with other corroborative evidence

**Low Reliability Indicators:**
- Produced by systems with weak IT general controls
- Created by internal parties with conflicting interests
- Based solely on inquiries without corroboration
- Contradicted by other evidence sources

## Control Testing Procedures by Domain

### 1. Identity & Access Management (IAM)

#### 1.1 User Account Management

**Control Objective**: Ensure user accounts are properly created, modified, and terminated based on authorized requests and business requirements.

**Test Procedures:**

**T-IAM-001: New User Provisioning**
```bash
# Azure CLI command to extract user creation data
az ad user list --query '[].{displayName:displayName,userPrincipalName:userPrincipalName,createdDateTime:createdDateTime,accountEnabled:accountEnabled}' --output table

# PowerShell command for detailed user analysis
Get-AzureADUser -All $true | Where-Object {$_.CreatedDateTime -gt (Get-Date).AddDays(-90)} | 
Select-Object DisplayName,UserPrincipalName,CreatedDateTime,AccountEnabled,Department,JobTitle
```

**Sample Size**: 25 user accounts created in the testing period or all if fewer than 25
**Evidence Required**:
- HR system reports showing employee start dates
- IT service requests with management approvals
- Active Directory/Azure AD user creation logs
- Access request forms with proper authorization

**Testing Steps**:
1. Obtain population of all users created during testing period
2. Select sample based on statistical/judgmental criteria
3. Match each sample item to:
   - HR records confirming employment status
   - Approved access request with manager authorization
   - IT system logs showing account creation date
   - Verification of appropriate user attributes (department, role, etc.)
4. Test timing: Verify accounts created within 1 business day of approved request
5. Test completeness: Confirm all required user attributes populated correctly

**Expected Results**: 
- 100% of sampled accounts have supporting HR documentation
- 100% have approved access requests with appropriate authorization
- 95% created within established timeframes
- 100% have complete and accurate user attributes

**Deficiency Indicators**:
- Accounts created without HR verification
- Missing or inadequate authorization for access requests  
- Delayed account provisioning beyond policy timeframes
- Incomplete user attribute information
- Accounts created for terminated employees

**T-IAM-002: User Account Modification**
```bash
# Extract user modification audit logs
az monitor activity-log list --resource-group "RG-Identity" --start-time "2024-01-01" --end-time "2024-12-31" | 
jq '.[] | select(.operationName.value == "Microsoft.Authorization/roleAssignments/write")'

# PowerShell to get role assignment changes
Get-AzRoleAssignment | Where-Object {$_.Scope -like "*subscription*"} | 
Select-Object DisplayName,RoleDefinitionName,Scope,ObjectType,SignInName
```

**Sample Size**: 20 user modifications in the testing period
**Evidence Required**:
- Change request forms with business justification
- Manager approval for access changes
- System audit logs showing before/after states
- Evidence of access review and validation

**T-IAM-003: User Account Termination**
```bash
# Identify disabled/deleted accounts
az ad user list --query '[].{displayName:displayName,userPrincipalName:userPrincipalName,accountEnabled:accountEnabled}' | 
jq '.[] | select(.accountEnabled == false)'

# Cross-reference with HR termination data
Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $false} | 
Select-Object DisplayName,UserPrincipalName,DeletionTimestamp,LastSignInDateTime
```

**Sample Size**: All terminations in testing period or minimum 15 samples
**Testing Focus**:
- Timely account disabling upon employee termination
- Complete access removal across all systems
- Asset return verification before access revocation
- Retention period compliance for account deletion

#### 1.2 Privileged Access Management

**Control Objective**: Privileged access is properly authorized, monitored, and limited to necessary personnel with appropriate oversight.

**T-IAM-004: Privileged Identity Management (PIM) Configuration**
```powershell
# Export PIM role settings
Connect-AzureAD
$roles = Get-AzureADDirectoryRole
foreach ($role in $roles) {
    Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | 
    Select-Object @{Name='Role';Expression={$role.DisplayName}}, DisplayName, UserPrincipalName, ObjectType
}

# Check PIM activation settings
Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadRoles" -ResourceId "tenant-id" | 
Select-Object Id, DisplayName, IsEnabled
```

**Testing Elements**:
1. **Role Assignment Verification**: All privileged roles require PIM activation
2. **Approval Requirements**: Multi-stage approval for high-risk roles
3. **Time Limitations**: Maximum activation duration limits (2-8 hours)
4. **MFA Requirements**: Additional authentication for activation
5. **Justification**: Business justification required for activation

**Sample Size**: All privileged role definitions and 25 recent activations
**Evidence Collection**:
- PIM policy configurations and approval workflows
- Activation logs with business justifications
- Approval audit trails and timing
- MFA verification logs during activation

**T-IAM-005: Break-Glass Account Management**
```bash
# Verify break-glass accounts configuration
az ad user list --filter "startswith(displayName,'BreakGlass')" --query '[].{displayName:displayName,accountEnabled:accountEnabled,strongAuthenticationMethods:strongAuthenticationMethods}'

# Check break-glass account monitoring
az monitor activity-log list --resource-group "RG-Identity" --caller "breakglass@company.com" --start-time "2024-01-01"
```

**Testing Requirements**:
- Minimum 2 break-glass accounts configured
- Strong password complexity (25+ characters)
- Excluded from conditional access policies
- Monitored for any authentication attempts
- Stored credentials in secured physical vault
- Monthly access verification without usage

#### 1.3 Multi-Factor Authentication (MFA)

**Control Objective**: Multi-factor authentication is enforced for all users accessing corporate resources with appropriate bypass controls for emergency scenarios.

**T-IAM-006: MFA Enforcement Testing**
```powershell
# Check MFA enrollment status
Get-MsolUser -All | Select-Object UserPrincipalName, @{Name="MFA Status"; Expression={$_.StrongAuthenticationRequirements.State}}, @{Name="MFA Methods"; Expression={$_.StrongAuthenticationMethods.MethodType}}

# Verify conditional access MFA policies
Get-AzureADMSConditionalAccessPolicy | Where-Object {$_.GrantControls.BuiltInControls -contains "mfa"} | 
Select-Object DisplayName, State, Conditions, GrantControls
```

**Sample Size**: 50 users across different roles and locations
**Testing Procedures**:
1. Verify MFA enrollment for 100% of active users
2. Test conditional access policy enforcement
3. Validate MFA method diversity (avoid single method dependency)
4. Confirm emergency access procedures and bypass controls
5. Review MFA failure logs and resolution processes

### 2. Network Security Controls

#### 2.1 Network Segmentation and Micro-segmentation

**Control Objective**: Network traffic is properly segmented and controlled through defense-in-depth strategies including perimeter controls, internal segmentation, and application-level security.

**T-NET-001: Network Security Group (NSG) Rule Analysis**
```bash
# Export all NSG rules for analysis
az network nsg list --query '[].{name:name,resourceGroup:resourceGroup,location:location}' --output table

# Get detailed NSG rules
for nsg in $(az network nsg list --query '[].name' -o tsv); do
    echo "=== NSG: $nsg ==="
    az network nsg rule list --nsg-name "$nsg" --resource-group "RG-Network" --output table
done

# Analyze rule priorities and conflicts
az network nsg rule list --nsg-name "NSG-Web-Tier" --resource-group "RG-Network" --query '[].{name:name,priority:priority,direction:direction,access:access,protocol:protocol,sourceAddressPrefix:sourceAddressPrefix,destinationPortRange:destinationPortRange}' --output table
```

**Sample Size**: 
- All internet-facing NSGs (100% coverage)
- 20 internal NSGs or 25% of total population, whichever is greater

**Testing Procedures**:
1. **Default Deny Verification**: Confirm implicit deny rules at bottom of rule list
2. **Least Privilege Assessment**: Verify specific port/protocol requirements vs. broad "Any" rules
3. **Source/Destination Validation**: Confirm specific IP ranges vs. wildcard usage
4. **Rule Overlap Analysis**: Identify conflicting or redundant rules
5. **Administrative Access Controls**: Verify management protocols (SSH, RDP) restricted to specific source IPs

**Evidence Requirements**:
- NSG configuration exports with rule documentation
- Network architecture diagrams showing segmentation boundaries
- Business justification for any "Any-Any-Allow" rules
- Quarterly NSG rule review documentation

**T-NET-002: Application Security Group (ASG) Implementation**
```bash
# List all ASGs and their assignments
az network asg list --output table

# Check VM assignments to ASGs
az vm list --query '[].{name:name,resourceGroup:resourceGroup}' --output table | while read vm rg; do
    echo "VM: $vm"
    az network nic list --resource-group "$rg" --query "[?contains(name, '$vm')].{name:name,ipConfigurations:ipConfigurations[].applicationSecurityGroups[].id}" --output table
done
```

**Testing Focus**:
- Proper ASG assignment based on application tiers
- Consistent tagging and naming conventions
- ASG-based rules vs. IP-based rules ratio
- Dynamic membership management processes

#### 2.2 Web Application Firewall (WAF) Controls

**T-NET-003: WAF Policy Configuration and Effectiveness**
```bash
# Check WAF policies on Application Gateway
az network application-gateway waf-policy list --output table

# Verify WAF rule sets and custom rules
az network application-gateway waf-policy show --name "WAF-Policy-Prod" --resource-group "RG-WAF" --query '{name:name,managedRules:managedRules,customRules:customRules,policySettings:policySettings}'

# Review WAF logs for blocked requests
az monitor activity-log list --resource-group "RG-WAF" --start-time "2024-01-01" --end-time "2024-12-31" --query "[?contains(operationName.value, 'firewallPolicy')]"
```

**Testing Requirements**:
1. **OWASP Top 10 Protection**: Verify rule sets cover current OWASP threats
2. **Custom Rule Validation**: Review business-specific blocking rules
3. **False Positive Management**: Analyze blocked legitimate traffic and tuning
4. **Logging and Alerting**: Confirm comprehensive logging and security team notifications
5. **Rule Update Process**: Verify regular rule set updates and testing procedures

**Sample Size**: All WAF policies (100% coverage) and 30 days of blocked request logs

#### 2.3 Private Endpoint Implementation

**T-NET-004: Private Endpoint Validation**
```bash
# List all private endpoints
az network private-endpoint list --output table

# Check private endpoint connections for PaaS services
az storage account list --query '[].{name:name,resourceGroup:resourceGroup}' --output table | while read storage rg; do
    echo "Storage Account: $storage"
    az storage account show --name "$storage" --resource-group "$rg" --query '{name:name,privateEndpointConnections:privateEndpointConnections,publicNetworkAccess:publicNetworkAccess}'
done

# Verify DNS resolution for private endpoints
az network private-dns zone list --output table
```

**Testing Elements**:
- All PaaS services use private endpoints where supported
- Public access disabled for services with private endpoints
- DNS resolution correctly points to private IP addresses
- Network security groups allow required private endpoint traffic
- Private endpoint subnets properly configured and documented

### 3. Data Protection Controls

#### 3.1 Data Classification and Handling

**Control Objective**: Data is properly classified, labeled, and protected according to its sensitivity level throughout its lifecycle.

**T-DATA-001: Data Classification Implementation**
```powershell
# Microsoft Information Protection - get label policies
Connect-SecurityComplianceCenter
Get-Label | Select-Object Name, Priority, Settings, Description

# Check applied labels across SharePoint/OneDrive
Get-SPOSite -Limit All | ForEach-Object {
    Get-SPOSiteContentTypePolicyAssociation -Site $_.Url
}

# Azure Information Protection scanner results
Get-AIPScannerStatus
Get-AIPScannerRepository | Select-Object Path, LastScanResult, DiscoveredFiles
```

**Sample Size**: 25 documents/files per classification level across different repositories
**Testing Procedures**:
1. **Classification Accuracy**: Verify samples are correctly classified based on content
2. **Label Consistency**: Confirm labeling matches data classification policy
3. **Handling Controls**: Validate protection measures align with classification level
4. **User Training**: Review evidence of classification training and awareness
5. **Monitoring**: Check label application reporting and compliance metrics

#### 3.2 Encryption at Rest

**T-DATA-002: Azure Storage Encryption Verification**
```bash
# Check storage account encryption settings
az storage account list --query '[].{name:name,resourceGroup:resourceGroup,encryption:encryption}' --output table

# Verify customer-managed key (CMK) usage where required
az storage account show --name "storageaccountname" --resource-group "RG-Storage" --query '{name:name,encryption:encryption.keySource,keyVaultProperties:encryption.keyVaultProperties}'

# Check disk encryption for VMs
az vm list --query '[].{name:name,resourceGroup:resourceGroup}' --output table | while read vm rg; do
    echo "VM: $vm"
    az vm encryption show --name "$vm" --resource-group "$rg"
done
```

**Testing Requirements**:
- All storage accounts use encryption at rest (minimum AES-256)
- High-sensitivity data uses customer-managed keys (CMK)
- VM disks encrypted using Azure Disk Encryption
- Database transparent data encryption (TDE) enabled
- Key rotation policies implemented and documented

**Sample Size**: 
- All storage accounts containing sensitive data (100%)
- 20 VMs across different resource groups
- All databases containing regulated data

#### 3.3 Key Management

**T-DATA-003: Azure Key Vault Security Configuration**
```bash
# Check Key Vault security settings
az keyvault list --query '[].{name:name,resourceGroup:resourceGroup,properties:properties}' --output table

# Verify Key Vault access policies and RBAC
az keyvault show --name "KV-Production" --query '{name:name,properties:properties.accessPolicies,enableRbacAuthorization:properties.enableRbacAuthorization}'

# Check key rotation and expiration
az keyvault key list --vault-name "KV-Production" --query '[].{name:name,attributes:attributes}' --output table
```

**Testing Elements**:
1. **Physical Security**: HSM vs. software protection validation
2. **Access Controls**: RBAC implementation and least privilege
3. **Key Lifecycle**: Creation, rotation, and deletion procedures
4. **Backup and Recovery**: Key backup and restore capabilities
5. **Compliance**: FIPS 140-2 Level 2 or equivalent certification
6. **Monitoring**: Key usage logging and anomaly detection

### 4. Application Security Controls

#### 4.1 Secure Software Development Lifecycle (SSDLC)

**Control Objective**: Applications are developed using secure coding practices with integrated security testing throughout the development lifecycle.

**T-APP-001: Static Application Security Testing (SAST)**
```bash
# Review SAST scan results from CI/CD pipeline
gh run list --repo "company/application" --workflow "security-scan.yml" --json conclusion,headSha,status,createdAt

# Check code quality gates and security findings
az pipelines run list --project "SecureApp" --definition-name "Security-Pipeline" --query '[].{id:id,result:result,status:status,finishTime:finishTime}'

# Analyze security scan artifacts
az artifacts universal download --organization "https://dev.azure.com/company" --project "SecureApp" --scope "project" --name "security-reports" --version "latest"
```

**Testing Requirements**:
1. **Tool Integration**: SAST tools integrated in CI/CD pipeline
2. **Coverage Metrics**: Minimum 80% code coverage for security analysis
3. **Vulnerability Remediation**: High/Critical findings resolved before deployment
4. **False Positive Management**: Process for handling false positives
5. **Developer Training**: Secure coding training completion rates

**Sample Size**: 10 applications or 25% of active development projects

**T-APP-002: Dynamic Application Security Testing (DAST)**
```bash
# Check OWASP ZAP scan configurations
cat .github/workflows/security-scan.yml | grep -A 10 "zap-baseline-scan"

# Review penetration testing results
ls -la ./security-reports/pentest-results/
cat ./security-reports/pentest-results/latest-report.json | jq '.findings[] | select(.severity == "High" or .severity == "Critical")'
```

**Testing Focus**:
- OWASP Top 10 vulnerability scanning
- Authentication and session management testing
- Input validation and output encoding verification
- SQL injection and cross-site scripting (XSS) prevention
- API security testing including rate limiting and authentication

#### 4.2 Container Security

**T-APP-003: Container Image Security**
```bash
# Scan container images for vulnerabilities
trivy image --format json myregistry.azurecr.io/myapp:latest | jq '.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[] | select(.Severity == "HIGH" or .Severity == "CRITICAL")'

# Verify container image signing
cosign verify --key cosign.pub myregistry.azurecr.io/myapp:latest

# Check base image governance
az acr repository list --name myregistry --output table
az acr repository show-tags --name myregistry --repository myapp --output table
```

**Testing Elements**:
1. **Vulnerability Scanning**: All images scanned before deployment
2. **Base Image Management**: Approved base images from trusted sources
3. **Image Signing**: Cryptographic signatures for integrity verification
4. **Runtime Security**: Container runtime protection and monitoring
5. **Secret Management**: No secrets embedded in container images

### 5. Infrastructure Security Controls

#### 5.1 Virtual Machine Security Configuration

**T-INFRA-001: VM Security Baseline Compliance**
```bash
# Check VM security configurations
az vm list --query '[].{name:name,resourceGroup:resourceGroup,osProfile:osProfile}' --output table

# Verify VM extensions for security
az vm extension list --vm-name "VM-Web-01" --resource-group "RG-Production" --output table

# Check Azure Security Center recommendations
az security assessment list --query '[].{name:name,status:status,severity:severity,description:description}' --output table
```

**Testing Requirements**:
- Operating system hardening per CIS benchmarks
- Anti-malware solution installed and updated
- Patch management compliance (95% of critical patches within 30 days)
- Local administrator account management
- Network access restrictions and firewall configuration

**T-INFRA-002: Backup and Recovery Validation**
```bash
# Check Azure Backup configuration
az backup vault list --query '[].{name:name,resourceGroup:resourceGroup}' --output table

# Verify backup policies and retention
az backup policy list --resource-group "RG-Backup" --vault-name "RSV-Production" --output table

# Test restore functionality
az backup restore files mount-rp --resource-group "RG-Backup" --vault-name "RSV-Production" --container-name "VM-Web-01" --item-name "VM-Web-01" --rp-name "recoverypoint-name"
```

**Testing Elements**:
1. **Backup Coverage**: All critical systems included in backup scope
2. **Retention Compliance**: Backup retention meets business and regulatory requirements
3. **Recovery Testing**: Quarterly recovery tests documented and successful
4. **Immutable Backups**: Protection against ransomware and accidental deletion
5. **Cross-Region Replication**: Geo-redundant backup for disaster recovery

### 6. Monitoring & Logging Controls

#### 6.1 Security Information and Event Management (SIEM)

**Control Objective**: Security events are collected, correlated, and analyzed to enable effective threat detection and incident response.

**T-LOG-001: Log Collection and Centralization**
```bash
# Check diagnostic settings for critical resources
az monitor diagnostic-settings list --resource "/subscriptions/sub-id/resourceGroups/RG-Production/providers/Microsoft.Compute/virtualMachines/VM-Web-01"

# Verify Log Analytics workspace configuration
az monitor log-analytics workspace list --query '[].{name:name,resourceGroup:resourceGroup,retentionInDays:retentionInDays}' --output table

# Check log ingestion rates and data retention
az monitor log-analytics workspace get-schema --workspace-name "LAW-Security" --resource-group "RG-Logging"
```

**Sample Size**: All Tier 1 applications and 25% of Tier 2/3 applications
**Testing Requirements**:
1. **Log Coverage**: Security-relevant events from all critical systems
2. **Log Integrity**: Tamper-evident logging with hash verification
3. **Retention Periods**: Compliance with regulatory requirements (minimum 7 years for financial data)
4. **Real-time Processing**: Critical events processed within 15 minutes
5. **Backup and Archive**: Log backups for long-term retention

**T-LOG-002: Azure Sentinel Analytics Rules**
```bash
# Export Sentinel analytics rules
az sentinel alert-rule list --resource-group "RG-Security" --workspace-name "LAW-Security" --output table

# Check rule effectiveness and false positive rates
az sentinel incident list --resource-group "RG-Security" --workspace-name "LAW-Security" --query '[].{title:title,severity:severity,status:status,createdTimeUtc:createdTimeUtc}' --output table

# Verify playbook automation and response
az sentinel automation-rule list --resource-group "RG-Security" --workspace-name "LAW-Security" --output table
```

**Testing Focus**:
- Rule coverage for MITRE ATT&CK framework tactics
- False positive rate below 10% for high-severity alerts
- Mean time to detection (MTTD) under 1 hour for critical threats
- Automated response playbooks for common incident types
- Regular rule tuning based on threat intelligence

#### 6.2 Audit Trail Management

**T-LOG-003: Azure Activity Log Analysis**
```bash
# Review Azure Activity Log retention and export
az monitor activity-log list --start-time "2024-01-01" --end-time "2024-12-31" --query '[].{caller:caller,operationName:operationName.value,status:status.value,eventTimestamp:eventTimestamp}' --output table

# Check storage account access logs
az storage logging show --services b --account-name "storageaccountname" --account-key "account-key"

# Verify Key Vault audit logs
az keyvault list-deleted --resource-group "RG-Security" --output table
```

**Audit Requirements**:
- Administrative actions logged with user attribution
- Failed authentication attempts monitored and alerted
- Data access patterns analyzed for anomalies
- Configuration changes tracked and approved
- Privileged access activities recorded and reviewed

### 7. Incident Response Controls

#### 7.1 Incident Response Plan Testing

**Control Objective**: Incident response procedures are documented, tested, and enable effective containment and recovery from security incidents.

**T-IR-001: Incident Response Playbook Validation**
```bash
# Check incident response automation in Sentinel
az sentinel playbook list --resource-group "RG-Security" --output table

# Verify incident escalation workflows
az logic app list --resource-group "RG-Security" --query '[].{name:name,state:state,definition:definition.triggers}' --output table

# Review incident response team notifications
az monitor action-group list --resource-group "RG-Security" --output table
```

**Testing Procedures**:
1. **Tabletop Exercises**: Quarterly scenario-based exercises documented
2. **Playbook Accuracy**: Technical procedures validated through testing
3. **Communication Plans**: Stakeholder notification processes verified
4. **Recovery Procedures**: System restoration capabilities tested
5. **Lessons Learned**: Post-incident review process and improvements

**Sample Size**: All critical incident types and 3 tabletop exercises per year

**T-IR-002: Business Continuity and Disaster Recovery**
```bash
# Check Azure Site Recovery configuration
az site-recovery vault list --query '[].{name:name,resourceGroup:resourceGroup}' --output table

# Verify replication status
az site-recovery replication-protected-item list --resource-group "RG-DR" --vault-name "RSV-DR" --output table

# Test failover procedures
az site-recovery recovery-plan list --resource-group "RG-DR" --vault-name "RSV-DR" --output table
```

**BCDR Testing Requirements**:
- Annual full disaster recovery test with documented results
- RTO/RPO targets met during testing (RTO <4 hours, RPO <1 hour)
- Alternative processing site capabilities verified
- Data backup restoration tested quarterly
- Communication systems tested during outage scenarios

### 8. Governance Controls

#### 8.1 Policy Management and Compliance

**Control Objective**: Security policies are formally documented, regularly reviewed, and effectively implemented across the organization.

**T-GOV-001: Azure Policy Compliance Assessment**
```bash
# Get overall policy compliance status
az policy state summarize --policy-set-definition-name "security-baseline" --query 'results'

# Check policy exemptions and justifications
az policy exemption list --scope "/subscriptions/subscription-id" --query '[].{name:name,displayName:displayName,exemptionCategory:exemptionCategory,expiresOn:expiresOn}' --output table

# Verify policy assignment effectiveness
az policy assignment list --scope "/subscriptions/subscription-id" --query '[].{name:name,displayName:displayName,enforcementMode:enforcementMode,nonComplianceMessages:nonComplianceMessages}' --output table
```

**Sample Size**: All policy definitions and 20 non-compliant resources with exemptions
**Testing Elements**:
1. **Policy Coverage**: All security controls addressed by policies
2. **Enforcement Mode**: Critical policies in "Enforce" vs "Audit" mode
3. **Exemption Management**: Business justification for all exemptions
4. **Regular Review**: Quarterly policy effectiveness reviews documented
5. **Compliance Metrics**: Minimum 95% compliance for critical policies

**T-GOV-002: Security Governance Framework**
```bash
# Check management group hierarchy and policy inheritance
az account management-group list --output table
az policy assignment list --scope "/providers/Microsoft.Management/managementGroups/mg-root" --output table

# Verify RBAC assignments at management group level  
az role assignment list --scope "/providers/Microsoft.Management/managementGroups/mg-root" --include-inherited --output table
```

**Governance Testing Focus**:
- Security steering committee meeting minutes and decisions
- Risk management framework implementation
- Security architecture review board processes
- Third-party risk management procedures
- Security awareness training completion rates

### 9. DevSecOps Controls

#### 9.1 Secure CI/CD Pipeline Implementation

**Control Objective**: DevSecOps practices are integrated throughout the software development lifecycle with automated security controls and gates.

**T-DEVSEC-001: Pipeline Security Gates**
```bash
# Check GitHub branch protection rules
gh api repos/company/application/branches/main/protection | jq '.required_status_checks, .enforce_admins, .required_pull_request_reviews'

# Verify security scan integration
cat .github/workflows/ci.yml | grep -E "(checkov|trivy|gitleaks|codeql)"

# Check pipeline approval gates for production
az pipelines environment list --project "SecureApp" --output table
az pipelines environment show --project "SecureApp" --name "production" --query 'approvals'
```

**Testing Requirements**:
1. **Branch Protection**: Main branch requires PR with approvals
2. **Security Scanning**: SAST, DAST, SCA, and secret scanning integrated
3. **Quality Gates**: Build fails on security vulnerabilities above threshold
4. **Deployment Approvals**: Manual approval required for production deployments
5. **Rollback Procedures**: Automated rollback on deployment failures

**T-DEVSEC-002: Supply Chain Security**
```bash
# Check software bill of materials (SBOM) generation
ls -la ./sbom/ && cat ./sbom/application-sbom.json | jq '.components[] | select(.type == "library")'

# Verify container image signing
cosign verify --key cosign.pub $ACR_NAME.azurecr.io/application:latest

# Check dependency vulnerability scanning
cat ./security-reports/dependency-check.json | jq '.dependencies[] | select(.vulnerabilities != null)'
```

**Supply Chain Testing Elements**:
- SBOM generated for all applications and containers
- Third-party dependency vulnerability scanning
- License compliance checking for open source components
- Container image signing and verification
- Provenance tracking for build artifacts

## Control Deficiency Classification

### Design Deficiencies

**Definition**: Controls that are not appropriately designed to operate effectively.

**Categories**:
- **Critical Design Deficiency**: Control does not address the stated control objective
- **Significant Design Deficiency**: Control inadequately addresses control objective
- **Minor Design Deficiency**: Control addresses objective but has design limitations

**Examples**:
- Segregation of duties not properly implemented
- Authorization levels inappropriate for transaction types
- Control frequency insufficient for risk level
- Monitoring controls lack precision or timely detection capabilities

### Operating Deficiencies

**Definition**: Controls that are appropriately designed but not operating effectively.

**Categories**:
- **Critical Operating Deficiency**: Control failure with high likelihood of material impact
- **Significant Operating Deficiency**: Control failure with moderate likelihood of material impact  
- **Minor Operating Deficiency**: Isolated control failure with low impact probability

**Examples**:
- Control not performed as designed
- Control performed by inappropriate personnel
- Control evidence missing or inadequate
- Control performed outside required timeframes

## Risk Rating Methodology

### Risk Assessment Matrix

| Likelihood | Impact: Low | Impact: Medium | Impact: High | Impact: Critical |
|------------|-------------|----------------|--------------|------------------|
| Very High  | High        | High           | Critical     | Critical         |
| High       | Medium      | High           | High         | Critical         |
| Medium     | Low         | Medium         | High         | High             |
| Low        | Low         | Low            | Medium       | High             |
| Very Low   | Low         | Low            | Low          | Medium           |

### Impact Assessment Criteria

**Critical Impact**:
- Material financial statement misstatement
- Significant regulatory violation with penalties
- Major data breach affecting >10,000 records
- Business disruption >24 hours

**High Impact**:
- Moderate financial impact (<5% of revenue)
- Regulatory reporting delays
- Data breach affecting 1,000-10,000 records
- Business disruption 8-24 hours

**Medium Impact**:
- Minor financial impact (<1% of revenue)
- Compliance documentation gaps
- Limited data exposure <1,000 records
- Business disruption 2-8 hours

**Low Impact**:
- Minimal financial impact
- Administrative compliance issues
- No data exposure
- Business disruption <2 hours

### Likelihood Assessment Factors

**Very High (>90%)**:
- Control not implemented
- Historical evidence of frequent failures
- High-risk environment with no mitigating controls

**High (70-90%)**:
- Control operates inconsistently
- Recent evidence of control failures
- Moderate risk environment with limited mitigation

**Medium (30-70%)**:
- Control operates generally as designed
- Isolated instances of control failures
- Standard risk environment with some mitigation

**Low (10-30%)**:
- Control operates effectively most of the time
- Rare instances of control failures
- Low risk environment with strong mitigating controls

**Very Low (<10%)**:
- Control operates consistently and effectively
- No recent evidence of failures
- Well-controlled environment with multiple layers of protection

## Remediation and Re-testing Procedures

### Remediation Planning

**Priority Classification**:
1. **Critical Findings**: Immediate remediation required (within 30 days)
2. **High Findings**: Remediation within 90 days
3. **Medium Findings**: Remediation within 180 days  
4. **Low Findings**: Remediation within 365 days or next control cycle

**Remediation Plan Components**:
- Root cause analysis and contributing factors
- Specific corrective actions with responsible parties
- Implementation timeline with milestones
- Resource requirements and budget impact
- Risk mitigation during remediation period
- Success criteria and measurement methods

### Re-testing Procedures

**Re-testing Timing**:
- Critical findings: Re-test within 15 days of claimed remediation
- High findings: Re-test within 30 days of claimed remediation
- Medium findings: Re-test within 60 days of claimed remediation
- Low findings: Re-test during next scheduled control testing cycle

**Re-testing Approach**:
1. **Remediation Verification**: Confirm corrective actions implemented as planned
2. **Design Re-evaluation**: Assess if remediated control design is appropriate
3. **Operating Effectiveness**: Test control operation over sufficient period
4. **Sustainability Assessment**: Evaluate likelihood of sustained control operation
5. **Documentation Update**: Refresh control documentation and procedures

**Re-testing Sample Sizes**:
- Previously failed controls: Test at least 25 items or full population if smaller
- Related controls: Test 15 items to ensure no adverse impacts
- Compensating controls: Test effectiveness of temporary measures

**Success Criteria**:
- Zero exceptions in re-testing sample for Critical/High findings
- ≤5% exception rate for Medium findings  
- ≤10% exception rate for Low findings
- Control operates consistently throughout re-testing period
- Control documentation updated and accurate

## Quality Assurance and Documentation Standards

### Testing Documentation Requirements

**Test Work Papers Must Include**:
- Control description and testing objective
- Population definition and sample selection methodology
- Testing procedures performed and timing
- Evidence obtained and source documentation
- Exceptions identified and investigated
- Conclusions reached and basis for opinion

**Evidence Documentation Standards**:
- Electronic evidence includes metadata and timestamps
- Screenshots include full screen with date/time visible
- System queries include full query text and parameters
- Interview summaries signed by interviewees
- All evidence indexed and cross-referenced to testing procedures

### Independent Review Process

**Reviewer Qualifications**:
- Senior auditor with relevant technical expertise
- Independent of testing team
- Familiar with applicable standards and requirements

**Review Procedures**:
1. **Completeness Review**: All required testing procedures performed
2. **Adequacy Review**: Evidence sufficient to support conclusions
3. **Technical Review**: Testing procedures technically sound and appropriate
4. **Conclusion Review**: Conclusions supported by evidence and properly risk-rated
5. **Documentation Review**: Work papers complete and meet standards

## Continuous Monitoring and Improvement

### Control Monitoring Framework

**Ongoing Monitoring Activities**:
- Real-time security control effectiveness dashboards
- Monthly exception reporting and trend analysis
- Quarterly risk assessment updates
- Annual control framework review and enhancement

**Key Performance Indicators (KPIs)**:
- Control failure rate by domain and severity
- Mean time to detection (MTTD) for control failures
- Mean time to remediation (MTTR) for findings
- Control automation percentage
- Cost per control per period

### Emerging Threats and Control Updates

**Threat Intelligence Integration**:
- Monthly threat landscape reviews
- Quarterly control effectiveness assessment against new threats
- Annual control framework updates for emerging risks
- Continuous improvement based on industry best practices

**Technology Evolution Considerations**:
- Cloud-native control implementations
- AI/ML-based anomaly detection and response
- Zero-trust architecture control adaptations  
- DevSecOps pipeline security enhancements

---

**Document History**:
- v1.0: Initial basic procedures (2,188 bytes)
- v2.0: Comprehensive enterprise-grade methodology (current - 26,847 bytes)

**Next Review Date**: September 2025
**Document Owner**: Security Compliance Team
**Approved By**: Chief Information Security Officer, Chief Audit Executive
