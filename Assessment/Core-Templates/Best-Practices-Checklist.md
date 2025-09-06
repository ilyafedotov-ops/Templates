# Azure Security Best Practices Assessment Template

## Assessment Instructions

**Response Options**: 
- **Yes (Y)**: Fully implemented and validated
- **No (N)**: Not implemented or significant gaps exist  
- **Partial (P)**: Partially implemented with known limitations
- **N/A**: Not applicable to current environment

**Risk Levels**: Critical (C) | High (H) | Medium (M) | Low (L)

**Maturity Levels**: 
- **Level 1**: Initial/Ad Hoc
- **Level 2**: Managed/Repeatable  
- **Level 3**: Defined/Documented
- **Level 4**: Quantitatively Managed
- **Level 5**: Optimizing/Continuous Improvement

**Compliance Framework Mappings**: ISO 27001:2022 | SOC 2 Type II | NIST CSF 2.0 | CIS Azure v2.0

---

## 1. Identity & Access Management (IAM)

### 1.1 Multi-Factor Authentication (MFA)
**Risk Level: Critical** | **ISO A.9.4.2** | **SOC CC6.1** | **NIST PR.AC-7**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **1.1.1** Enforce MFA for all user accounts including external users | ___ | 10 | Configure CA policy requiring MFA for all users. Use Azure AD B2B guest settings |
| **1.1.2** Implement phishing-resistant MFA (FIDO2, Windows Hello) for privileged accounts | ___ | 15 | Deploy FIDO2 keys, Windows Hello for Business. Minimum for Global Admins, PIM-eligible users |
| **1.1.3** Block legacy authentication protocols organization-wide | ___ | 10 | Create CA policy blocking legacy auth. Monitor sign-in logs for legacy protocol usage |
| **1.1.4** Implement adaptive MFA based on risk signals | ___ | 5 | Configure Azure AD Identity Protection risk-based CA policies |
| **1.1.5** Establish MFA bypass procedures for emergency scenarios | ___ | 5 | Document break-glass accounts, emergency access procedures with approval workflows |

**Maturity Assessment:**
- Level 1: Basic MFA enabled for some users
- Level 2: MFA required for all users with basic methods
- Level 3: Phishing-resistant MFA for privileged users, documented procedures
- Level 4: Risk-based adaptive MFA with monitoring and metrics
- Level 5: Continuous optimization based on threat intelligence and user behavior

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 1.2 Conditional Access & Zero Trust
**Risk Level: High** | **ISO A.9.4.3** | **SOC CC6.1** | **NIST PR.AC-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **1.2.1** Implement location-based access controls | ___ | 8 | Define trusted locations, block access from high-risk countries |
| **1.2.2** Require compliant/hybrid Azure AD joined devices for access | ___ | 10 | Deploy device compliance policies, require compliant devices via CA |
| **1.2.3** Block access from unmanaged devices to sensitive applications | ___ | 8 | Create CA policies for high-value apps requiring managed devices |
| **1.2.4** Implement application-specific access controls | ___ | 6 | Configure per-app CA policies based on data classification |
| **1.2.5** Establish sign-in frequency controls for high-risk scenarios | ___ | 4 | Set session controls requiring re-authentication for sensitive operations |
| **1.2.6** Deploy Azure AD Identity Protection with risk remediation | ___ | 8 | Configure user/sign-in risk policies with automatic remediation |
| **1.2.7** Implement Terms of Use for external users and contractors | ___ | 3 | Deploy Azure AD Terms of Use for B2B collaboration |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium-High** | **Business Impact: Medium**

### 1.3 Privileged Identity Management (PIM)
**Risk Level: Critical** | **ISO A.9.2.3** | **SOC CC6.2** | **NIST PR.AC-4**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **1.3.1** Enable PIM for all privileged Azure AD roles | ___ | 15 | Configure PIM for Global Admin, Security Admin, and other high-privilege roles |
| **1.3.2** Require approval workflow for privileged role activation | ___ | 10 | Set up multi-person approval for critical roles with business justification |
| **1.3.3** Implement maximum activation duration limits (≤8 hours) | ___ | 8 | Configure time-bound activation with automatic expiration |
| **1.3.4** Require MFA and justification for all PIM activations | ___ | 8 | Enforce MFA challenge and business justification for role activation |
| **1.3.5** Conduct regular PIM access reviews (quarterly) | ___ | 6 | Automate access reviews with manager approval and removal of unused access |
| **1.3.6** Monitor and alert on privileged role assignments and activations | ___ | 8 | Configure Sentinel rules for PIM activities, dashboard for privileged access |
| **1.3.7** Implement emergency break-glass accounts with monitoring | ___ | 10 | Maintain 2-3 break-glass accounts with strong controls and monitoring |

**Implementation Timeline: 2-4 months** | **Estimated Cost: Medium** | **Business Impact: Low-Medium**

### 1.4 Role-Based Access Control (RBAC)
**Risk Level: High** | **ISO A.9.2.1** | **SOC CC6.1** | **NIST PR.AC-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **1.4.1** Implement least privilege principle across all Azure resources | ___ | 12 | Use built-in roles, avoid Owner assignments, regular privilege reviews |
| **1.4.2** Create custom RBAC roles for specific business functions | ___ | 6 | Develop granular custom roles aligned with job functions |
| **1.4.3** Use Azure AD groups for RBAC assignments, not individual users | ___ | 8 | Assign permissions to groups, implement group management workflow |
| **1.4.4** Conduct quarterly access reviews for all privileged assignments | ___ | 8 | Automate access reviews with attestation and remediation |
| **1.4.5** Implement separation of duties for critical operations | ___ | 10 | Separate creation/approval roles, implement dual control for sensitive operations |
| **1.4.6** Document and maintain RBAC assignment matrix | ___ | 4 | Maintain current documentation of roles, responsibilities, and assignments |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Low-Medium** | **Business Impact: Medium**

### 1.5 Identity Governance & Administration
**Risk Level: Medium** | **ISO A.9.2.5** | **SOC CC6.3** | **NIST PR.AC-5**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **1.5.1** Implement automated user provisioning and deprovisioning | ___ | 8 | Configure Azure AD Connect, SCIM provisioning for SaaS apps |
| **1.5.2** Deploy Azure AD Entitlement Management for access packages | ___ | 6 | Create access packages for common role combinations with approval workflows |
| **1.5.3** Establish identity lifecycle management processes | ___ | 8 | Document joiner/mover/leaver processes with automation where possible |
| **1.5.4** Implement guest user management and lifecycle | ___ | 6 | Configure guest user policies, automated cleanup, and access reviews |
| **1.5.5** Deploy privileged access workstations (PAWs) for administrators | ___ | 10 | Provide dedicated admin workstations with enhanced security controls |

**Section Score: ___/250** | **Section Maturity Level: ___/5**

---

## 2. Network Security & Infrastructure Protection

### 2.1 Network Architecture & Segmentation
**Risk Level: High** | **ISO A.13.1.1** | **SOC CC6.1** | **NIST PR.AC-5**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **2.1.1** Deploy hub-and-spoke network topology with centralized security controls | ___ | 10 | Implement Azure Virtual WAN or hub-spoke with Azure Firewall |
| **2.1.2** Implement network segmentation using NSGs and ASGs | ___ | 12 | Create application security groups, implement deny-by-default NSG rules |
| **2.1.3** Deploy Azure Firewall Premium with IDPS and TLS inspection | ___ | 8 | Configure advanced threat protection, SSL/TLS inspection capabilities |
| **2.1.4** Implement micro-segmentation for critical workloads | ___ | 6 | Use ASGs and NSGs for granular network controls within subnets |
| **2.1.5** Establish DMZ/perimeter network for internet-facing resources | ___ | 8 | Separate internet-facing resources with appropriate security controls |
| **2.1.6** Deploy network access control (NAC) for device authentication | ___ | 4 | Implement 802.1X authentication for network access |

**Implementation Timeline: 6-12 months** | **Estimated Cost: High** | **Business Impact: Medium-High**

### 2.2 Web Application & API Protection
**Risk Level: Critical** | **ISO A.14.2.1** | **SOC CC6.1** | **NIST PR.DS-5**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **2.2.1** Deploy Azure Web Application Firewall (WAF) for all web applications | ___ | 15 | Configure WAF on Application Gateway or Front Door with OWASP rules |
| **2.2.2** Implement DDoS Protection Standard for internet-facing resources | ___ | 10 | Enable DDoS Protection Standard with monitoring and response plans |
| **2.2.3** Enforce TLS 1.2+ for all web communications | ___ | 8 | Configure minimum TLS version, disable legacy protocols |
| **2.2.4** Implement certificate lifecycle management and automation | ___ | 6 | Use Azure Key Vault for certificate storage and automated renewal |
| **2.2.5** Deploy API Management with security policies | ___ | 8 | Implement rate limiting, authentication, and API security policies |
| **2.2.6** Configure geo-filtering and IP restrictions where appropriate | ___ | 4 | Block traffic from high-risk countries and IP ranges |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium-High** | **Business Impact: Medium**

### 2.3 Private Connectivity & Endpoints
**Risk Level: High** | **ISO A.13.1.3** | **SOC CC6.1** | **NIST PR.AC-5**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **2.3.1** Deploy private endpoints for all supported PaaS services | ___ | 12 | Implement private endpoints for storage, databases, and other PaaS services |
| **2.3.2** Disable public network access for PaaS services where possible | ___ | 10 | Configure firewall rules to block public access, use private connectivity |
| **2.3.3** Implement ExpressRoute or VPN for hybrid connectivity | ___ | 8 | Establish dedicated private connection to on-premises infrastructure |
| **2.3.4** Configure service endpoints for remaining PaaS services | ___ | 6 | Use VNet service endpoints where private endpoints aren't available |
| **2.3.5** Deploy Azure Private DNS zones for private endpoint resolution | ___ | 4 | Configure private DNS zones for proper name resolution |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium-High** | **Business Impact: Low-Medium**

### 2.4 Network Monitoring & Threat Detection
**Risk Level: High** | **ISO A.12.4.1** | **SOC CC7.1** | **NIST DE.CM-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **2.4.1** Enable Azure Network Watcher in all regions | ___ | 6 | Deploy Network Watcher for network monitoring and diagnostics |
| **2.4.2** Configure NSG flow logs with Traffic Analytics | ___ | 8 | Enable flow logs, configure Traffic Analytics for network insights |
| **2.4.3** Deploy network intrusion detection and prevention system | ___ | 10 | Use Azure Firewall Premium IDPS or third-party solutions |
| **2.4.4** Implement network anomaly detection and alerting | ___ | 8 | Configure alerts for unusual network patterns and traffic flows |
| **2.4.5** Monitor DNS queries for malicious domains | ___ | 6 | Implement DNS filtering and monitoring for malicious domain detection |
| **2.4.6** Deploy honeypots and deception technology | ___ | 4 | Implement decoy resources to detect lateral movement attempts |

**Section Score: ___/200** | **Section Maturity Level: ___/5**

---

## 3. Data Protection & Privacy

### 3.1 Data Classification & Inventory
**Risk Level: High** | **ISO A.8.2.1** | **SOC CC6.1** | **NIST PR.DS-5**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **3.1.1** Implement organization-wide data classification scheme | ___ | 10 | Define classification levels (Public, Internal, Confidential, Restricted) |
| **3.1.2** Deploy Microsoft Purview for data discovery and classification | ___ | 8 | Scan and classify data across Azure, on-premises, and multi-cloud |
| **3.1.3** Maintain comprehensive data inventory and data maps | ___ | 8 | Document data flows, storage locations, and processing activities |
| **3.1.4** Implement automated sensitivity labeling | ___ | 6 | Configure auto-labeling policies based on content and context |
| **3.1.5** Establish data retention and disposition schedules | ___ | 6 | Define retention periods aligned with legal and business requirements |
| **3.1.6** Deploy data loss prevention (DLP) policies | ___ | 10 | Implement DLP across endpoints, email, and cloud services |

**Implementation Timeline: 6-12 months** | **Estimated Cost: Medium-High** | **Business Impact: Medium**

### 3.2 Encryption & Key Management
**Risk Level: Critical** | **ISO A.10.1.1** | **SOC CC6.1** | **NIST PR.DS-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **3.2.1** Encrypt all data at rest using AES-256 or stronger | ___ | 15 | Enable encryption for all storage services, databases, and VM disks |
| **3.2.2** Implement customer-managed keys (CMK) for sensitive data | ___ | 10 | Use Azure Key Vault with customer-controlled encryption keys |
| **3.2.3** Deploy Azure Key Vault with proper access controls | ___ | 12 | Implement RBAC, access policies, and private endpoints for Key Vault |
| **3.2.4** Enable Key Vault soft delete and purge protection | ___ | 8 | Configure deletion protection to prevent accidental key loss |
| **3.2.5** Implement key rotation policies and automation | ___ | 6 | Automate key rotation based on policy requirements |
| **3.2.6** Use Azure Dedicated HSM for high-value cryptographic operations | ___ | 4 | Deploy HSM for applications requiring FIPS 140-2 Level 3 compliance |
| **3.2.7** Encrypt data in transit with TLS 1.2+ for all communications | ___ | 10 | Enforce encryption for all data transmission scenarios |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Low-Medium**

### 3.3 Database Security & Protection
**Risk Level: High** | **ISO A.13.2.1** | **SOC CC6.1** | **NIST PR.DS-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **3.3.1** Enable Transparent Data Encryption (TDE) for all databases | ___ | 10 | Configure TDE for SQL databases with customer-managed keys |
| **3.3.2** Implement Always Encrypted for highly sensitive data columns | ___ | 8 | Use Always Encrypted for PII, PHI, and other sensitive data elements |
| **3.3.3** Deploy SQL Database Auditing and threat detection | ___ | 10 | Enable auditing, Advanced Data Security, and vulnerability assessments |
| **3.3.4** Configure database firewall rules with principle of least access | ___ | 8 | Implement IP restrictions and VNet service endpoints |
| **3.3.5** Establish database backup encryption and testing procedures | ___ | 8 | Encrypt backups, test restoration procedures regularly |
| **3.3.6** Implement database activity monitoring and anomaly detection | ___ | 6 | Monitor database access patterns and detect suspicious activities |

**Implementation Timeline: 2-4 months** | **Estimated Cost: Medium** | **Business Impact: Low**

### 3.4 Storage Security & Access Control
**Risk Level: High** | **ISO A.13.2.2** | **SOC CC6.1** | **NIST PR.DS-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **3.4.1** Disable public blob access for storage accounts | ___ | 12 | Configure storage accounts to deny anonymous public read access |
| **3.4.2** Enable storage account encryption with customer-managed keys | ___ | 8 | Use Azure Key Vault for storage encryption key management |
| **3.4.3** Implement storage account network access restrictions | ___ | 10 | Configure firewall rules and private endpoints for storage access |
| **3.4.4** Enable Azure Storage soft delete and versioning | ___ | 6 | Configure data recovery options and version history |
| **3.4.5** Deploy Azure Storage immutable blob storage for compliance | ___ | 4 | Use immutable storage for regulatory compliance and data integrity |
| **3.4.6** Implement storage account logging and monitoring | ___ | 6 | Enable storage analytics and integrate with Azure Monitor |

**Implementation Timeline: 2-3 months** | **Estimated Cost: Low-Medium** | **Business Impact: Low**

### 3.5 Privacy & Compliance
**Risk Level: Medium** | **ISO A.18.1.4** | **SOC CC6.8** | **NIST PR.IP-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **3.5.1** Implement privacy impact assessment (PIA) process | ___ | 6 | Conduct PIAs for systems processing personal data |
| **3.5.2** Deploy Microsoft Priva for privacy risk management | ___ | 4 | Use Priva for data subject rights management and privacy compliance |
| **3.5.3** Establish data subject rights fulfillment procedures | ___ | 6 | Implement processes for access, rectification, erasure requests |
| **3.5.4** Configure geographic data residency controls | ___ | 4 | Ensure data residency compliance with regional regulations |
| **3.5.5** Implement consent management and withdrawal mechanisms | ___ | 4 | Deploy consent management solutions for customer data processing |

**Section Score: ___/220** | **Section Maturity Level: ___/5**

---

## 4. Application Security & Development

### 4.1 Secure Application Development
**Risk Level: High** | **ISO A.14.2.1** | **SOC CC8.1** | **NIST PR.IP-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **4.1.1** Implement secure coding standards and guidelines | ___ | 8 | Establish coding standards addressing OWASP Top 10 vulnerabilities |
| **4.1.2** Deploy static application security testing (SAST) in CI/CD | ___ | 10 | Integrate SAST tools like SonarQube, Checkmarx in build pipelines |
| **4.1.3** Implement dynamic application security testing (DAST) | ___ | 8 | Use OWASP ZAP, Burp Suite for runtime vulnerability scanning |
| **4.1.4** Conduct regular security code reviews | ___ | 6 | Implement peer review process with security focus |
| **4.1.5** Deploy interactive application security testing (IAST) | ___ | 4 | Use IAST tools for real-time vulnerability detection during testing |
| **4.1.6** Implement software composition analysis (SCA) | ___ | 8 | Scan third-party dependencies for known vulnerabilities |
| **4.1.7** Establish threat modeling process for applications | ___ | 6 | Conduct threat modeling during design phase using STRIDE methodology |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 4.2 API Security & Management
**Risk Level: High** | **ISO A.14.2.2** | **SOC CC8.1** | **NIST PR.AC-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **4.2.1** Deploy Azure API Management with security policies | ___ | 10 | Implement authentication, authorization, and rate limiting |
| **4.2.2** Implement OAuth 2.0/OpenID Connect for API authentication | ___ | 8 | Use industry-standard protocols for API security |
| **4.2.3** Configure API rate limiting and throttling | ___ | 6 | Prevent API abuse and DDoS attacks through rate limiting |
| **4.2.4** Deploy API gateway with request/response validation | ___ | 8 | Validate API requests and responses against schemas |
| **4.2.5** Implement API versioning and lifecycle management | ___ | 4 | Manage API versions with proper deprecation procedures |
| **4.2.6** Enable API logging and monitoring | ___ | 6 | Monitor API usage, performance, and security events |
| **4.2.7** Conduct regular API security assessments | ___ | 4 | Perform penetration testing and vulnerability assessments |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 4.3 Container & Kubernetes Security
**Risk Level: High** | **ISO A.14.2.8** | **SOC CC8.1** | **NIST PR.DS-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **4.3.1** Implement container image scanning and vulnerability management | ___ | 10 | Use Azure Container Registry with vulnerability scanning |
| **4.3.2** Deploy Azure Kubernetes Service (AKS) with security best practices | ___ | 12 | Enable pod security policies, network policies, and RBAC |
| **4.3.3** Use minimal base images and distroless containers | ___ | 6 | Minimize attack surface by using minimal container images |
| **4.3.4** Implement container runtime security monitoring | ___ | 8 | Deploy runtime protection tools like Azure Defender for Containers |
| **4.3.5** Configure pod security standards and admission controllers | ___ | 8 | Implement pod security policies and Open Policy Agent (OPA) |
| **4.3.6** Use Azure Container Registry with private endpoints | ___ | 6 | Secure container image storage with private connectivity |
| **4.3.7** Implement secrets management for containerized applications | ___ | 6 | Use Azure Key Vault CSI driver for secrets in Kubernetes |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium-High** | **Business Impact: Medium**

### 4.4 Serverless & Function Security
**Risk Level: Medium** | **ISO A.14.2.3** | **SOC CC8.1** | **NIST PR.IP-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **4.4.1** Implement Azure Functions with managed identity | ___ | 6 | Use managed identity for serverless application authentication |
| **4.4.2** Configure function-level authorization and access controls | ___ | 8 | Implement function-level security with appropriate access keys |
| **4.4.3** Enable Application Insights for serverless monitoring | ___ | 4 | Monitor function execution, performance, and security events |
| **4.4.4** Implement input validation and sanitization | ___ | 6 | Validate all inputs to prevent injection attacks |
| **4.4.5** Use VNet integration for serverless functions | ___ | 4 | Deploy functions with VNet integration for network isolation |
| **4.4.6** Configure appropriate timeout and resource limits | ___ | 2 | Prevent resource exhaustion and DoS attacks |

**Section Score: ___/180** | **Section Maturity Level: ___/5**

---

## 5. Infrastructure Security & Hardening

### 5.1 Virtual Machine Security
**Risk Level: High** | **ISO A.12.6.1** | **SOC CC6.1** | **NIST PR.IP-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **5.1.1** Deploy Azure Security Center/Defender for Servers | ___ | 10 | Enable advanced threat protection for virtual machines |
| **5.1.2** Implement Azure Disk Encryption for all VM disks | ___ | 12 | Encrypt OS and data disks using BitLocker (Windows) or dm-crypt (Linux) |
| **5.1.3** Configure automatic VM patching and update management | ___ | 10 | Use Azure Update Manager for automated patch deployment |
| **5.1.4** Deploy endpoint detection and response (EDR) solutions | ___ | 8 | Install Microsoft Defender for Endpoint or third-party EDR |
| **5.1.5** Implement VM baseline compliance monitoring | ___ | 6 | Use Azure Policy Guest Configuration for compliance monitoring |
| **5.1.6** Configure VM network security groups with least privilege | ___ | 8 | Apply restrictive NSG rules to VM network interfaces |
| **5.1.7** Enable VM boot diagnostics and monitoring | ___ | 4 | Configure boot diagnostics for troubleshooting and monitoring |
| **5.1.8** Implement VM backup and disaster recovery procedures | ___ | 6 | Configure Azure Backup with tested restore procedures |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 5.2 Cloud Infrastructure Hardening
**Risk Level: High** | **ISO A.12.6.2** | **SOC CC6.1** | **NIST PR.IP-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **5.2.1** Implement Azure landing zone with security controls | ___ | 10 | Deploy Cloud Adoption Framework landing zone with security baseline |
| **5.2.2** Configure resource locks for critical infrastructure | ___ | 8 | Apply read-only or delete locks to prevent accidental changes |
| **5.2.3** Deploy Azure Resource Manager (ARM) templates with security best practices | ___ | 6 | Use secure ARM/Bicep templates with parameterized security configurations |
| **5.2.4** Implement infrastructure as code (IaC) security scanning | ___ | 8 | Use Checkov, TFSec, or similar tools for IaC security validation |
| **5.2.5** Configure Azure Resource Graph for inventory and compliance | ___ | 4 | Implement resource queries for security and compliance monitoring |
| **5.2.6** Deploy Azure Arc for hybrid and multi-cloud governance | ___ | 4 | Extend Azure management to on-premises and multi-cloud resources |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium-High** | **Business Impact: Medium**

### 5.3 Platform as a Service (PaaS) Security
**Risk Level: Medium** | **ISO A.13.1.2** | **SOC CC6.1** | **NIST PR.AC-4**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **5.3.1** Configure App Service with VNet integration | ___ | 6 | Deploy App Services with virtual network integration |
| **5.3.2** Implement App Service authentication and authorization | ___ | 8 | Use Azure AD authentication for web applications |
| **5.3.3** Enable App Service logging and monitoring | ___ | 4 | Configure application logs, web server logs, and failed request traces |
| **5.3.4** Deploy App Service with managed identity | ___ | 6 | Use managed identity for application authentication to Azure services |
| **5.3.5** Configure App Service custom domains with TLS certificates | ___ | 4 | Use custom domains with automated certificate management |
| **5.3.6** Implement App Service backup and disaster recovery | ___ | 4 | Configure automated backups and geo-redundant deployments |

**Section Score: ___/140** | **Section Maturity Level: ___/5**

---

## 6. Governance, Compliance & Risk Management

### 6.1 Policy Management & Enforcement
**Risk Level: High** | **ISO A.5.1.1** | **SOC CC2.1** | **NIST GV.PO-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **6.1.1** Deploy Azure Policy with comprehensive security baseline | ___ | 15 | Implement security policies covering all resource types and configurations |
| **6.1.2** Implement policy initiatives for compliance frameworks | ___ | 10 | Create policy initiatives for ISO 27001, SOC 2, and industry standards |
| **6.1.3** Configure policy exemptions with proper approval workflow | ___ | 8 | Establish process for policy exemptions with time-bound approvals |
| **6.1.4** Deploy Azure Blueprints for repeatable compliant deployments | ___ | 6 | Create blueprints combining ARM templates, policies, and RBAC |
| **6.1.5** Implement policy compliance monitoring and reporting | ___ | 8 | Configure compliance dashboards and automated reporting |
| **6.1.6** Establish policy lifecycle management procedures | ___ | 4 | Document policy development, testing, and deployment processes |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 6.2 Compliance & Audit Management
**Risk Level: High** | **ISO A.18.2.1** | **SOC CC3.1** | **NIST GV.PO-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **6.2.1** Maintain compliance evidence repository with automated collection | ___ | 8 | Implement evidence collection automation for audit requirements |
| **6.2.2** Conduct regular internal security assessments | ___ | 8 | Perform quarterly internal assessments with remediation tracking |
| **6.2.3** Implement compliance monitoring dashboards | ___ | 6 | Deploy real-time compliance monitoring with KPI tracking |
| **6.2.4** Establish audit trail preservation and retention policies | ___ | 6 | Configure long-term log retention for audit and compliance requirements |
| **6.2.5** Deploy Microsoft Purview Compliance Manager | ___ | 4 | Use Compliance Manager for compliance score tracking and improvements |
| **6.2.6** Maintain regulatory compliance mapping documentation | ___ | 4 | Document control mappings to applicable regulations and standards |

**Implementation Timeline: 2-4 months** | **Estimated Cost: Medium** | **Business Impact: Low-Medium**

### 6.3 Risk Management & Assessment
**Risk Level: Medium** | **ISO A.6.1.2** | **SOC CC3.2** | **NIST GV.RM-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **6.3.1** Establish enterprise risk management framework | ___ | 6 | Implement risk identification, assessment, and treatment processes |
| **6.3.2** Conduct annual information security risk assessments | ___ | 8 | Perform comprehensive risk assessments with business impact analysis |
| **6.3.3** Maintain risk register with regular updates | ___ | 6 | Document and track risks with assigned owners and treatment plans |
| **6.3.4** Implement risk-based decision making processes | ___ | 4 | Integrate risk considerations into technology and business decisions |
| **6.3.5** Deploy continuous risk monitoring capabilities | ___ | 4 | Implement automated risk monitoring with alerting and reporting |
| **6.3.6** Establish risk appetite and tolerance statements | ___ | 2 | Document organizational risk tolerance for different risk categories |

**Section Score: ___/120** | **Section Maturity Level: ___/5**

---

## 7. Threat Detection, Monitoring & Incident Response

### 7.1 Security Information & Event Management (SIEM)
**Risk Level: Critical** | **ISO A.12.4.1** | **SOC CC7.1** | **NIST DE.CM-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **7.1.1** Deploy Microsoft Sentinel with comprehensive data ingestion | ___ | 15 | Implement Sentinel with connectors for all relevant data sources |
| **7.1.2** Configure advanced analytics rules and threat hunting queries | ___ | 12 | Deploy custom detection rules based on MITRE ATT&CK framework |
| **7.1.3** Implement threat intelligence integration | ___ | 8 | Integrate threat feeds and indicators of compromise (IoCs) |
| **7.1.4** Deploy user and entity behavior analytics (UEBA) | ___ | 8 | Enable machine learning-based anomaly detection for users and entities |
| **7.1.5** Configure automated threat response and remediation | ___ | 10 | Implement Security Orchestration, Automation and Response (SOAR) playbooks |
| **7.1.6** Establish security operations center (SOC) procedures | ___ | 6 | Document SOC processes, roles, and escalation procedures |
| **7.1.7** Implement threat hunting capabilities | ___ | 4 | Establish proactive threat hunting program with regular hunting exercises |

**Implementation Timeline: 6-12 months** | **Estimated Cost: High** | **Business Impact: Medium**

### 7.2 Logging & Monitoring
**Risk Level: High** | **ISO A.12.4.3** | **SOC CC7.1** | **NIST DE.CM-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **7.2.1** Enable comprehensive diagnostic logging across all Azure services | ___ | 12 | Configure diagnostic settings for all resources to Log Analytics workspace |
| **7.2.2** Implement centralized log management with appropriate retention | ___ | 10 | Store logs in centralized location with compliance-aligned retention policies |
| **7.2.3** Configure security event correlation and alerting | ___ | 8 | Implement correlation rules for security event detection and alerting |
| **7.2.4** Deploy application performance monitoring (APM) | ___ | 4 | Use Application Insights for application-level security monitoring |
| **7.2.5** Implement file integrity monitoring for critical systems | ___ | 6 | Monitor critical files and configurations for unauthorized changes |
| **7.2.6** Configure network traffic monitoring and analysis | ___ | 6 | Implement network monitoring with traffic analysis capabilities |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Low-Medium**

### 7.3 Incident Response & Recovery
**Risk Level: High** | **ISO A.16.1.2** | **SOC CC7.3** | **NIST RS.CO-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **7.3.1** Establish incident response team and procedures | ___ | 10 | Define incident response team roles, responsibilities, and procedures |
| **7.3.2** Implement incident classification and prioritization system | ___ | 6 | Create incident severity levels with response time requirements |
| **7.3.3** Deploy incident response automation and orchestration | ___ | 8 | Automate initial incident response actions using Logic Apps or Functions |
| **7.3.4** Conduct regular incident response exercises and tabletop scenarios | ___ | 6 | Test incident response procedures with simulated security incidents |
| **7.3.5** Establish communication plans for security incidents | ___ | 4 | Define internal and external communication procedures for incidents |
| **7.3.6** Implement digital forensics and evidence collection capabilities | ___ | 6 | Prepare tools and procedures for forensic investigation |
| **7.3.7** Maintain incident response metrics and continuous improvement | ___ | 4 | Track response times, resolution rates, and lessons learned |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium** | **Business Impact: High**

### 7.4 Vulnerability Management
**Risk Level: High** | **ISO A.12.6.1** | **SOC CC7.1** | **NIST DE.CM-4**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **7.4.1** Deploy automated vulnerability scanning for all assets | ___ | 10 | Use Microsoft Defender for Cloud and third-party scanners |
| **7.4.2** Establish vulnerability prioritization and remediation procedures | ___ | 8 | Implement risk-based vulnerability prioritization with SLAs |
| **7.4.3** Implement continuous security assessment and monitoring | ___ | 6 | Deploy continuous monitoring for new vulnerabilities and exposures |
| **7.4.4** Configure automated patch management for operating systems | ___ | 8 | Use Azure Update Manager for automated patching with maintenance windows |
| **7.4.5** Establish third-party software inventory and update procedures | ___ | 6 | Maintain inventory of third-party software with update procedures |
| **7.4.6** Deploy web application vulnerability scanning | ___ | 4 | Implement regular DAST scanning for web applications |

**Section Score: ___/200** | **Section Maturity Level: ___/5**

---

## 8. DevSecOps & Secure Development Lifecycle

### 8.1 Secure CI/CD Pipeline
**Risk Level: High** | **ISO A.14.2.6** | **SOC CC8.1** | **NIST PR.IP-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **8.1.1** Implement security gates in CI/CD pipelines | ___ | 12 | Deploy SAST, DAST, and dependency scanning with build gates |
| **8.1.2** Configure code signing and artifact validation | ___ | 8 | Sign all code artifacts and validate signatures during deployment |
| **8.1.3** Deploy secrets management in pipelines | ___ | 10 | Use Azure Key Vault for pipeline secrets and eliminate hardcoded credentials |
| **8.1.4** Implement infrastructure as code (IaC) security scanning | ___ | 8 | Scan Terraform, ARM templates, and other IaC for security issues |
| **8.1.5** Configure secure artifact storage and management | ___ | 6 | Use Azure Artifacts or Azure Container Registry with security controls |
| **8.1.6** Implement policy as code validation | ___ | 6 | Validate Azure Policy compliance before deployment |
| **8.1.7** Deploy container image scanning and vulnerability management | ___ | 8 | Scan container images for vulnerabilities before deployment |

**Implementation Timeline: 4-8 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 8.2 Source Code Security
**Risk Level: Medium** | **ISO A.14.2.5** | **SOC CC8.1** | **NIST PR.IP-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **8.2.1** Implement branch protection and code review requirements | ___ | 6 | Configure branch protection with required reviews and status checks |
| **8.2.2** Deploy automated secret detection in repositories | ___ | 8 | Use Gitleaks, TruffleHog, or similar tools for secret detection |
| **8.2.3** Configure signed commits and commit verification | ___ | 4 | Require GPG-signed commits for critical repositories |
| **8.2.4** Implement CODEOWNERS for security-sensitive areas | ___ | 4 | Require security team review for security-critical code changes |
| **8.2.5** Deploy dependency vulnerability scanning | ___ | 6 | Scan third-party dependencies for known security vulnerabilities |
| **8.2.6** Establish secure coding training and awareness programs | ___ | 4 | Provide regular security training for development teams |

**Implementation Timeline: 2-4 months** | **Estimated Cost: Low-Medium** | **Business Impact: Medium**

### 8.3 Software Supply Chain Security
**Risk Level: High** | **ISO A.15.1.2** | **SOC CC8.1** | **NIST PR.DS-6**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **8.3.1** Generate and maintain software bill of materials (SBOM) | ___ | 8 | Create SBOM for all applications with component vulnerability tracking |
| **8.3.2** Implement artifact signing and attestation | ___ | 8 | Sign all software artifacts with cryptographic signatures |
| **8.3.3** Deploy private package repositories with security scanning | ___ | 6 | Use Azure Artifacts with vulnerability scanning for private packages |
| **8.3.4** Establish vendor security assessment procedures | ___ | 6 | Assess third-party vendors and their security practices |
| **8.3.5** Implement license compliance scanning | ___ | 4 | Scan dependencies for license compliance and security issues |
| **8.3.6** Configure reproducible builds and build provenance | ___ | 4 | Implement reproducible builds with provenance attestation |

**Section Score: ___/140** | **Section Maturity Level: ___/5**

---

## 9. Third-Party Risk Management & Supply Chain Security

### 9.1 Vendor Security Assessment
**Risk Level: High** | **ISO A.15.1.1** | **SOC CC9.1** | **NIST ID.SC-2**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **9.1.1** Establish vendor security assessment framework | ___ | 8 | Develop standardized security questionnaires and assessment criteria |
| **9.1.2** Conduct security due diligence for critical vendors | ___ | 10 | Perform detailed security assessments for high-risk vendor relationships |
| **9.1.3** Implement vendor risk classification and tiering | ___ | 6 | Classify vendors based on data access, criticality, and risk exposure |
| **9.1.4** Maintain vendor security compliance monitoring | ___ | 6 | Monitor vendor compliance with security requirements and standards |
| **9.1.5** Establish vendor incident response coordination procedures | ___ | 4 | Define procedures for coordinating incident response with vendors |
| **9.1.6** Implement vendor contract security requirements | ___ | 6 | Include security clauses and requirements in vendor contracts |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: Medium**

### 9.2 Cloud Service Provider (CSP) Security
**Risk Level: Medium** | **ISO A.15.1.3** | **SOC CC9.1** | **NIST ID.SC-3**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **9.2.1** Review and understand shared responsibility models | ___ | 6 | Document customer responsibilities for all cloud services used |
| **9.2.2** Implement multi-cloud security controls and monitoring | ___ | 4 | Apply consistent security controls across multiple cloud providers |
| **9.2.3** Configure cloud security posture management (CSPM) | ___ | 6 | Deploy CSPM tools for continuous security monitoring and compliance |
| **9.2.4** Establish cloud service security baselines | ___ | 4 | Define security configuration baselines for cloud services |
| **9.2.5** Implement cloud workload protection platform (CWPP) | ___ | 4 | Deploy runtime protection for cloud workloads and containers |

**Section Score: ___/60** | **Section Maturity Level: ___/5**

---

## 10. Business Continuity, Disaster Recovery & Resilience

### 10.1 Business Continuity Planning
**Risk Level: High** | **ISO A.17.1.1** | **SOC CC9.1** | **NIST RC.CO-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **10.1.1** Develop and maintain business continuity plans | ___ | 10 | Create comprehensive BCP covering all critical business functions |
| **10.1.2** Conduct business impact analysis (BIA) for critical systems | ___ | 8 | Identify critical systems, dependencies, and recovery requirements |
| **10.1.3** Define recovery time objectives (RTO) and recovery point objectives (RPO) | ___ | 8 | Establish measurable recovery targets for critical systems and data |
| **10.1.4** Implement redundant systems and failover capabilities | ___ | 8 | Deploy high-availability and disaster recovery solutions |
| **10.1.5** Establish alternate processing sites and capabilities | ___ | 6 | Configure alternate data centers or cloud regions for disaster recovery |
| **10.1.6** Conduct regular BCP testing and exercises | ___ | 6 | Test business continuity plans with tabletop and full-scale exercises |

**Implementation Timeline: 6-12 months** | **Estimated Cost: High** | **Business Impact: High**

### 10.2 Data Backup & Recovery
**Risk Level: Critical** | **ISO A.12.3.1** | **SOC CC9.1** | **NIST RC.RP-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **10.2.1** Implement comprehensive backup strategy (3-2-1 rule) | ___ | 12 | Maintain 3 copies of data, 2 different media types, 1 offsite location |
| **10.2.2** Configure automated backup with encryption | ___ | 10 | Deploy Azure Backup with encryption for all critical systems |
| **10.2.3** Establish backup testing and restoration procedures | ___ | 8 | Regularly test backup restoration to verify data integrity and procedures |
| **10.2.4** Implement immutable backups for ransomware protection | ___ | 8 | Use immutable backup storage to prevent tampering and deletion |
| **10.2.5** Configure geo-redundant backup storage | ___ | 6 | Replicate backups across multiple geographic regions |
| **10.2.6** Establish backup retention policies aligned with compliance requirements | ___ | 4 | Define retention periods based on regulatory and business requirements |

**Implementation Timeline: 3-6 months** | **Estimated Cost: Medium** | **Business Impact: High**

### 10.3 Operational Resilience
**Risk Level: Medium** | **ISO A.17.1.3** | **SOC CC9.1** | **NIST RC.IM-1**

| Control | Y/N/P/NA | Score | Implementation Guidance |
|---------|----------|-------|-------------------------|
| **10.3.1** Implement chaos engineering and resilience testing | ___ | 4 | Conduct controlled failure testing to improve system resilience |
| **10.3.2** Deploy application health monitoring and auto-scaling | ___ | 6 | Implement automatic scaling and healing for application resilience |
| **10.3.3** Establish service level agreements (SLAs) and monitoring | ___ | 4 | Define and monitor SLAs for critical services and applications |
| **10.3.4** Implement circuit breaker patterns for service dependencies | ___ | 4 | Deploy circuit breakers to prevent cascading failures |
| **10.3.5** Configure infrastructure redundancy and load balancing | ___ | 6 | Implement redundant infrastructure with automatic load balancing |

**Section Score: ___/120** | **Section Maturity Level: ___/5**

---

## Security Assessment Scoring & Maturity Model

### Overall Security Score Calculation

| Domain | Maximum Score | Achieved Score | Weight | Weighted Score |
|--------|---------------|----------------|---------|----------------|
| Identity & Access Management | 250 | ___ | 20% | ___ |
| Network Security & Infrastructure | 200 | ___ | 15% | ___ |
| Data Protection & Privacy | 220 | ___ | 15% | ___ |
| Application Security & Development | 180 | ___ | 10% | ___ |
| Infrastructure Security & Hardening | 140 | ___ | 10% | ___ |
| Governance, Compliance & Risk | 120 | ___ | 10% | ___ |
| Threat Detection & Incident Response | 200 | ___ | 10% | ___ |
| DevSecOps & Secure Development | 140 | ___ | 5% | ___ |
| Third-Party Risk Management | 60 | ___ | 2.5% | ___ |
| Business Continuity & Resilience | 120 | ___ | 2.5% | ___ |
| **TOTAL** | **1630** | **___** | **100%** | **___** |

### Security Maturity Level Assessment

**Overall Maturity Score: ___/50** (Sum of all domain maturity levels)

| Maturity Level | Score Range | Description | Characteristics |
|----------------|-------------|-------------|-----------------|
| **Level 1: Initial** | 10-18 | Ad hoc, reactive security | Basic controls, minimal documentation, reactive approach |
| **Level 2: Managed** | 19-26 | Managed processes | Documented procedures, some automation, consistent application |
| **Level 3: Defined** | 27-34 | Standardized processes | Organization-wide standards, proactive security, risk-based approach |
| **Level 4: Quantitatively Managed** | 35-42 | Measured and controlled | Metrics-driven, continuous monitoring, predictable processes |
| **Level 5: Optimizing** | 43-50 | Continuous improvement | Innovation-driven, adaptive, industry-leading practices |

### Risk Assessment Summary

**Total Risk Exposure: ___** (Sum of unmitigated high/critical risks)

| Risk Level | Count | Description |
|------------|--------|-------------|
| Critical | ___ | Immediate attention required, potential for severe business impact |
| High | ___ | Significant risk, remediation needed within 30 days |
| Medium | ___ | Moderate risk, remediation needed within 90 days |
| Low | ___ | Minor risk, remediation as resources permit |

### Implementation Roadmap Recommendations

#### Phase 1 (0-6 months): Foundation & Critical Controls
- Critical risk remediation
- Identity and access management baseline
- Basic monitoring and logging
- Policy framework establishment

#### Phase 2 (6-12 months): Advanced Security Controls
- Advanced threat detection
- Network security enhancement
- Application security integration
- DevSecOps pipeline security

#### Phase 3 (12-18 months): Optimization & Continuous Improvement
- Maturity enhancement
- Advanced analytics and automation
- Third-party risk management
- Business continuity testing

### Cost-Benefit Analysis Framework

| Investment Category | Low | Medium | High | Very High |
|-------------------|-----|---------|------|-----------|
| **Implementation Cost** | <$50K | $50K-$250K | $250K-$1M | >$1M |
| **Operational Cost (Annual)** | <$25K | $25K-$100K | $100K-$500K | >$500K |
| **Risk Reduction Value** | $100K-$500K | $500K-$2M | $2M-$10M | >$10M |
| **Compliance Value** | Minimal | Moderate | Significant | Critical |
| **Business Enablement** | Low | Medium | High | Very High |

### Compliance Framework Alignment

**ISO 27001:2022 Compliance Score: ___/114** (Annex A controls)
**SOC 2 Type II Readiness Score: ___/64** (Trust Services Criteria)
**NIST Cybersecurity Framework Score: ___/108** (Framework categories)
**CIS Azure Foundations Score: ___/48** (Benchmark controls)

---

## Assessment Completion

**Assessment Date**: _______________
**Assessor(s)**: _______________
**Review Date**: _______________
**Next Assessment Due**: _______________

**Executive Summary**:
- Overall Security Score: ___/100
- Security Maturity Level: ___/5
- Critical Findings: ___
- High-Priority Recommendations: ___
- Estimated Remediation Timeline: ___ months
- Estimated Investment Required: $___

**Approval**:
- CISO/Security Leader: _______________ Date: ___
- IT Leadership: _______________ Date: ___
- Business Leadership: _______________ Date: ___

