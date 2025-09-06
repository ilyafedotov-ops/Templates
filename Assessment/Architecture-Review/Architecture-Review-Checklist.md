# Enterprise Azure Architecture Review Checklist

## Overview

This comprehensive architecture review checklist is designed for enterprise Azure environments and aligns with the Microsoft Azure Well-Architected Framework, Azure Landing Zone principles, and Zero Trust security model. It provides detailed assessment criteria, validation steps, and scoring mechanisms to evaluate architecture maturity across all critical domains.

**Assessment Methodology:** Each section uses a 5-point maturity scale:
- **1 - Initial/Ad-hoc:** Basic implementation, significant gaps
- **2 - Developing:** Partial implementation, some best practices
- **3 - Defined:** Good implementation, follows most practices
- **4 - Managed:** Advanced implementation, comprehensive controls
- **5 - Optimized:** Exceptional implementation, continuous improvement

**Scoring Legend:**
- ✅ **Implemented:** Requirement fully met
- ⚠️ **Partial:** Requirement partially met
- ❌ **Missing:** Requirement not implemented
- 📋 **Evidence Required:** Requires documentation/validation
- 🔍 **Review Required:** Needs detailed assessment

---

## 1. Architecture Foundation & Documentation

### 1.1 Reference Architecture Documentation

| Assessment Criteria | Status | Maturity | Evidence | Validation Steps |
|---------------------|--------|----------|----------|------------------|
| **Architecture Decision Records (ADRs) maintained** | [ ] | _/5 | 📋 | Verify ADR repository exists and is current |
| **Solution architecture documented with C4 model** | [ ] | _/5 | 📋 | Check for Context, Container, Component, Code diagrams |
| **Deployment architecture diagrams current** | [ ] | _/5 | 📋 | Validate against actual deployed resources |
| **Data flow diagrams include security boundaries** | [ ] | _/5 | 📋 | Review for trust zones and data classification |
| **Integration patterns documented** | [ ] | _/5 | 📋 | API designs, message patterns, event flows |
| **Non-functional requirements defined** | [ ] | _/5 | 📋 | Performance, security, scalability targets |

**Validation Commands:**
```bash
# Verify resource topology matches documentation
az graph query -q "Resources | project name, type, resourceGroup, location | order by type"

# Check for standardized tagging reflecting architecture
az tag list --resource-id "/subscriptions/{subscription-id}" --query "properties.tags"
```

### 1.2 Trust Boundaries and Security Zones

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Network security zones clearly defined** | [ ] | _/5 | 📋 | High |
| **Trust boundaries documented in architecture** | [ ] | _/5 | 📋 | High |
| **Data classification zones mapped to infrastructure** | [ ] | _/5 | 📋 | High |
| **Zero Trust principles applied to design** | [ ] | _/5 | 📋 | Critical |
| **Threat modeling completed for each boundary** | [ ] | _/5 | 📋 | High |

---

## 2. Azure Well-Architected Framework Assessment

### 2.1 Security Pillar

#### 2.1.1 Defense in Depth

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Network layer security (NSGs, ASGs, Azure Firewall)** | [ ] | _/5 | 📋 | Critical |
| **Identity layer security (AAD, RBAC, PIM)** | [ ] | _/5 | 📋 | Critical |
| **Application layer security (WAF, API security)** | [ ] | _/5 | 📋 | High |
| **Data layer security (encryption, DLP, access controls)** | [ ] | _/5 | 📋 | Critical |
| **Infrastructure layer security (JIT, endpoint protection)** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Check NSG rules for least privilege
az network nsg list --query "[].{name:name, location:location}" -o table
az network nsg rule list --nsg-name "nsg-name" --resource-group "rg-name"

# Verify Azure Firewall policies
az network firewall policy list --query "[].{name:name, threatIntelMode:threatIntelMode}"

# Check Web Application Firewall configuration
az network application-gateway waf-policy list
```

#### 2.1.2 Zero Trust Implementation

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Verify explicitly - all access authenticated** | [ ] | _/5 | 📋 | Critical |
| **Use least privileged access - RBAC implemented** | [ ] | _/5 | 📋 | Critical |
| **Assume breach - monitoring and detection active** | [ ] | _/5 | 📋 | Critical |
| **Device compliance required for access** | [ ] | _/5 | 📋 | High |
| **Conditional Access policies comprehensive** | [ ] | _/5 | 📋 | Critical |
| **Continuous verification of trust** | [ ] | _/5 | 📋 | High |

#### 2.1.3 Data Protection and Encryption

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Data at rest encryption with customer-managed keys** | [ ] | _/5 | 📋 | High |
| **Data in transit encryption (TLS 1.2+)** | [ ] | _/5 | 📋 | Critical |
| **Key management lifecycle implemented** | [ ] | _/5 | 📋 | High |
| **Data classification and labeling** | [ ] | _/5 | 📋 | Medium |
| **Data loss prevention controls** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Check storage account encryption
az storage account list --query "[].{name:name, encryption:encryption}"

# Verify Key Vault configuration
az keyvault list --query "[].{name:name, properties:{enabledForDiskEncryption:properties.enabledForDiskEncryption}}"

# Check SQL TDE status
az sql db tde list --server "sql-server-name" --resource-group "rg-name"
```

### 2.2 Reliability Pillar

#### 2.2.1 High Availability Design

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Availability Zones utilized for critical workloads** | [ ] | _/5 | 📋 | High |
| **Load balancing and health probes configured** | [ ] | _/5 | 📋 | High |
| **Auto-scaling policies defined and tested** | [ ] | _/5 | 📋 | Medium |
| **Circuit breaker patterns implemented** | [ ] | _/5 | 📋 | Medium |
| **Redundancy across multiple regions** | [ ] | _/5 | 📋 | Medium |

#### 2.2.2 Disaster Recovery and Business Continuity

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **RTO/RPO targets defined and documented** | [ ] | _/5 | 📋 | Critical |
| **Azure Site Recovery configured and tested** | [ ] | _/5 | 📋 | High |
| **Database backup and geo-replication** | [ ] | _/5 | 📋 | Critical |
| **DR runbooks current and validated** | [ ] | _/5 | 📋 | High |
| **Regular DR testing and tabletop exercises** | [ ] | _/5 | 📋 | High |
| **Cross-region failover procedures** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Check Availability Zone distribution
az vm list --show-details --query "[].{name:name, zones:zones, size:hardwareProfile.vmSize}"

# Verify backup configuration
az backup vault list --query "[].{name:name, location:location}"
az backup policy list --vault-name "vault-name" --resource-group "rg-name"

# Check geo-replication status
az sql db replica list --name "database-name" --server "server-name" --resource-group "rg-name"
```

### 2.3 Performance Efficiency Pillar

#### 2.3.1 Scalability and Performance

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Performance requirements documented** | [ ] | _/5 | 📋 | Medium |
| **Load testing strategy and results** | [ ] | _/5 | 📋 | Medium |
| **CDN implementation for global performance** | [ ] | _/5 | 📋 | Low |
| **Database performance optimization** | [ ] | _/5 | 📋 | Medium |
| **Caching strategies implemented** | [ ] | _/5 | 📋 | Low |
| **Resource right-sizing based on metrics** | [ ] | _/5 | 📋 | Medium |

#### 2.3.2 Monitoring and Optimization

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Application Performance Monitoring (APM) implemented** | [ ] | _/5 | 📋 | Medium |
| **Custom metrics and KPIs defined** | [ ] | _/5 | 📋 | Low |
| **Performance baselines established** | [ ] | _/5 | 📋 | Medium |
| **Automated performance optimization** | [ ] | _/5 | 📋 | Low |
| **Capacity planning processes** | [ ] | _/5 | 📋 | Medium |

### 2.4 Cost Optimization Pillar

#### 2.4.1 Cost Management

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Cost budgets and alerts configured** | [ ] | _/5 | 📋 | Medium |
| **Reserved Instance utilization** | [ ] | _/5 | 📋 | Low |
| **Azure Hybrid Benefit applied** | [ ] | _/5 | 📋 | Low |
| **Resource tagging for cost allocation** | [ ] | _/5 | 📋 | Medium |
| **Automated cost optimization policies** | [ ] | _/5 | 📋 | Low |
| **Regular cost reviews and optimization** | [ ] | _/5 | 📋 | Medium |

### 2.5 Operational Excellence Pillar

#### 2.5.1 DevOps and Automation

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Infrastructure as Code (IaC) implemented** | [ ] | _/5 | 📋 | High |
| **CI/CD pipelines with security gates** | [ ] | _/5 | 📋 | High |
| **Automated testing (unit, integration, security)** | [ ] | _/5 | 📋 | Medium |
| **Blue-green or canary deployment strategies** | [ ] | _/5 | 📋 | Medium |
| **Configuration management and drift detection** | [ ] | _/5 | 📋 | Medium |
| **Change management processes** | [ ] | _/5 | 📋 | Medium |

---

## 3. Azure Landing Zone Architecture Review

### 3.1 Management Group Structure

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Management Group hierarchy aligns with org structure** | [ ] | _/5 | 📋 | Medium |
| **Policy inheritance strategy documented** | [ ] | _/5 | 📋 | Medium |
| **Subscription organization follows ALZ principles** | [ ] | _/5 | 📋 | Medium |
| **RBAC model scales across management groups** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Review Management Group structure
az account management-group list --query "[].{displayName:displayName, name:name, children:children}"

# Check policy assignments at MG level
az policy assignment list --scope "/providers/Microsoft.Management/managementGroups/{mg-id}"
```

### 3.2 Subscription Design

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Subscription strategy documented (single vs multiple)** | [ ] | _/5 | 📋 | Medium |
| **Billing and cost management per subscription** | [ ] | _/5 | 📋 | Low |
| **Resource limits and quotas managed** | [ ] | _/5 | 📋 | Medium |
| **Subscription lifecycle management** | [ ] | _/5 | 📋 | Low |

### 3.3 Resource Group Strategy

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Resource grouping strategy consistent** | [ ] | _/5 | 📋 | Low |
| **Naming conventions followed** | [ ] | _/5 | 📋 | Low |
| **Tagging strategy implemented** | [ ] | _/5 | 📋 | Medium |
| **Resource lifecycle aligned with business needs** | [ ] | _/5 | 📋 | Low |

---

## 4. Network Architecture Assessment

### 4.1 Network Topology

#### 4.1.1 Hub-Spoke Architecture

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Hub VNet properly configured for shared services** | [ ] | _/5 | 📋 | High |
| **Spoke VNets properly peered with hub** | [ ] | _/5 | 📋 | High |
| **User Defined Routes (UDRs) forcing traffic through NVA/Firewall** | [ ] | _/5 | 📋 | High |
| **Network segmentation between spokes** | [ ] | _/5 | 📋 | High |
| **Gateway subnet properly sized and configured** | [ ] | _/5 | 📋 | Medium |

#### 4.1.2 Virtual WAN Architecture (if applicable)

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Virtual WAN hubs strategically located** | [ ] | _/5 | 📋 | Medium |
| **Hub-to-hub connectivity configured** | [ ] | _/5 | 📋 | Medium |
| **Routing policies properly configured** | [ ] | _/5 | 📋 | High |
| **Branch connectivity established** | [ ] | _/5 | 📋 | Medium |

**Validation Commands:**
```bash
# Check VNet peering configuration
az network vnet peering list --vnet-name "hub-vnet" --resource-group "rg-networking"

# Verify route tables
az network route-table list --query "[].{name:name, routes:routes}"

# Check Virtual WAN configuration
az network vwan list --query "[].{name:name, type:type, hubs:virtualHubs}"
```

### 4.2 Network Security

#### 4.2.1 Perimeter Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Azure Firewall or NVA deployed in hub** | [ ] | _/5 | 📋 | Critical |
| **Web Application Firewall (WAF) configured** | [ ] | _/5 | 📋 | High |
| **DDoS Protection Standard enabled** | [ ] | _/5 | 📋 | High |
| **Network Watcher enabled for monitoring** | [ ] | _/5 | 📋 | Medium |
| **Flow logs configured for NSGs** | [ ] | _/5 | 📋 | Medium |

#### 4.2.2 Micro-segmentation

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Network Security Groups (NSGs) on all subnets** | [ ] | _/5 | 📋 | Critical |
| **Application Security Groups (ASGs) implemented** | [ ] | _/5 | 📋 | Medium |
| **Least privilege network access rules** | [ ] | _/5 | 📋 | High |
| **Service endpoints configured for PaaS services** | [ ] | _/5 | 📋 | Medium |
| **Private endpoints implemented for data services** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Check NSG rules for overly permissive access
az network nsg list --query "[].{name:name, resourceGroup:resourceGroup}"
az network nsg rule list --nsg-name "nsg-name" --resource-group "rg-name" --query "[?direction=='Inbound' && access=='Allow' && sourceAddressPrefix=='*']"

# Verify private endpoints
az network private-endpoint list --query "[].{name:name, privateLinkServiceConnections:privateLinkServiceConnections}"

# Check service endpoints
az network vnet subnet list --vnet-name "vnet-name" --resource-group "rg-name" --query "[].serviceEndpoints"
```

### 4.3 Hybrid Connectivity

#### 4.3.1 Site-to-Site Connectivity

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **ExpressRoute or VPN Gateway configured** | [ ] | _/5 | 📋 | High |
| **Redundant connections for HA** | [ ] | _/5 | 📋 | Medium |
| **BGP routing properly configured** | [ ] | _/5 | 📋 | Medium |
| **Connection monitoring and alerting** | [ ] | _/5 | 📋 | Medium |
| **Bandwidth requirements met** | [ ] | _/5 | 📋 | Low |

#### 4.3.2 DNS Architecture

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Private DNS zones configured** | [ ] | _/5 | 📋 | Medium |
| **DNS forwarders for hybrid scenarios** | [ ] | _/5 | 📋 | Medium |
| **DNS resolution tested end-to-end** | [ ] | _/5 | 📋 | Medium |
| **Split-brain DNS configuration** | [ ] | _/5 | 📋 | Low |

---

## 5. Identity and Access Management Architecture

### 5.1 Azure Active Directory Design

#### 5.1.1 Tenant Strategy

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Single vs multi-tenant strategy documented** | [ ] | _/5 | 📋 | Medium |
| **B2B guest access policies defined** | [ ] | _/5 | 📋 | High |
| **B2C implementation for customer identity** | [ ] | _/5 | 📋 | Medium |
| **Directory synchronization strategy** | [ ] | _/5 | 📋 | High |
| **Custom domains configured and verified** | [ ] | _/5 | 📋 | Low |

#### 5.1.2 Identity Governance

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Identity lifecycle management processes** | [ ] | _/5 | 📋 | High |
| **Automated user provisioning and deprovisioning** | [ ] | _/5 | 📋 | High |
| **Regular access reviews scheduled and executed** | [ ] | _/5 | 📋 | High |
| **Entitlement management for resource access** | [ ] | _/5 | 📋 | Medium |
| **Terms of use and consent management** | [ ] | _/5 | 📋 | Low |

**Validation Commands:**
```bash
# Check Azure AD tenant configuration
az ad signed-in-user show --query "{userPrincipalName:userPrincipalName, tenantId:tenantId}"

# Review custom domains
az ad domain list --query "[].{name:name, isVerified:isVerified}"

# Check guest user policies
az ad policy list --query "[?definition[0].guestUserRoleId]"
```

### 5.2 Authentication Architecture

#### 5.2.1 Multi-Factor Authentication

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **MFA required for all privileged accounts** | [ ] | _/5 | 📋 | Critical |
| **Risk-based authentication policies** | [ ] | _/5 | 📋 | High |
| **FIDO2 security keys supported** | [ ] | _/5 | 📋 | Medium |
| **Authentication methods policy configured** | [ ] | _/5 | 📋 | Medium |
| **Legacy authentication blocked** | [ ] | _/5 | 📋 | High |

#### 5.2.2 Conditional Access

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Comprehensive Conditional Access policies** | [ ] | _/5 | 📋 | Critical |
| **Device compliance requirements** | [ ] | _/5 | 📋 | High |
| **Location-based access controls** | [ ] | _/5 | 📋 | Medium |
| **Application-specific access policies** | [ ] | _/5 | 📋 | Medium |
| **Break-glass account procedures** | [ ] | _/5 | 📋 | Critical |

### 5.3 Authorization Architecture

#### 5.3.1 Role-Based Access Control (RBAC)

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Custom roles created for specific needs** | [ ] | _/5 | 📋 | Medium |
| **Least privilege principle applied** | [ ] | _/5 | 📋 | Critical |
| **Separation of duties implemented** | [ ] | _/5 | 📋 | High |
| **Resource-level RBAC granularity** | [ ] | _/5 | 📋 | Medium |
| **Service principal access managed** | [ ] | _/5 | 📋 | High |

#### 5.3.2 Privileged Identity Management (PIM)

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **PIM enabled for all privileged roles** | [ ] | _/5 | 📋 | Critical |
| **Just-in-time access workflows** | [ ] | _/5 | 📋 | High |
| **Access reviews for privileged roles** | [ ] | _/5 | 📋 | High |
| **Approval workflows for role activation** | [ ] | _/5 | 📋 | High |
| **Activity monitoring and alerting** | [ ] | _/5 | 📋 | Medium |

**Validation Commands:**
```bash
# Check RBAC assignments
az role assignment list --all --query "[].{principalName:principalName, roleDefinitionName:roleDefinitionName, scope:scope}"

# Review custom roles
az role definition list --custom-role-only true

# Check Conditional Access policies
az ad policy list --query "[?definition[0].conditions]"
```

### 5.4 Workload Identity

#### 5.4.1 Application Identity

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Managed Identity used for Azure resource access** | [ ] | _/5 | 📋 | High |
| **Service principals properly secured** | [ ] | _/5 | 📋 | High |
| **Certificate-based authentication over secrets** | [ ] | _/5 | 📋 | Medium |
| **Workload Identity for Kubernetes (AKS)** | [ ] | _/5 | 📋 | Medium |
| **Application registration security** | [ ] | _/5 | 📋 | Medium |

---

## 6. Data Architecture and Governance

### 6.1 Data Classification and Protection

#### 6.1.1 Data Discovery and Classification

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Data classification scheme defined** | [ ] | _/5 | 📋 | High |
| **Automated data discovery tools implemented** | [ ] | _/5 | 📋 | Medium |
| **Sensitive data identification and labeling** | [ ] | _/5 | 📋 | High |
| **Data inventory maintained** | [ ] | _/5 | 📋 | Medium |
| **Data lineage tracking** | [ ] | _/5 | 📋 | Low |

#### 6.1.2 Data Loss Prevention

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **DLP policies configured for sensitive data** | [ ] | _/5 | 📋 | High |
| **Data egress monitoring and controls** | [ ] | _/5 | 📋 | High |
| **Endpoint DLP for managed devices** | [ ] | _/5 | 📋 | Medium |
| **Cloud App Security integration** | [ ] | _/5 | 📋 | Medium |
| **Insider threat detection** | [ ] | _/5 | 📋 | Medium |

### 6.2 Data Storage Architecture

#### 6.2.1 Database Architecture

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Database platform selection justified** | [ ] | _/5 | 📋 | Medium |
| **Always Encrypted for sensitive columns** | [ ] | _/5 | 📋 | High |
| **Transparent Data Encryption (TDE) enabled** | [ ] | _/5 | 📋 | High |
| **Database firewall rules configured** | [ ] | _/5 | 📋 | High |
| **Advanced Threat Protection enabled** | [ ] | _/5 | 📋 | Medium |
| **Long-term backup retention configured** | [ ] | _/5 | 📋 | Medium |

#### 6.2.2 Storage Account Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Public blob access disabled** | [ ] | _/5 | 📋 | Critical |
| **Private endpoints configured** | [ ] | _/5 | 📋 | High |
| **Secure transfer required (HTTPS only)** | [ ] | _/5 | 📋 | High |
| **Storage account key rotation automated** | [ ] | _/5 | 📋 | Medium |
| **Blob versioning and soft delete enabled** | [ ] | _/5 | 📋 | Medium |
| **Immutable storage for compliance** | [ ] | _/5 | 📋 | Low |

**Validation Commands:**
```bash
# Check storage account security settings
az storage account list --query "[].{name:name, allowBlobPublicAccess:allowBlobPublicAccess, supportsHttpsTrafficOnly:supportsHttpsTrafficOnly}"

# Verify database encryption
az sql db list --server "server-name" --resource-group "rg-name" --query "[].{name:name, transparentDataEncryption:transparentDataEncryption}"

# Check Key Vault access policies
az keyvault show --name "keyvault-name" --query "properties.accessPolicies"
```

### 6.3 Data Governance

#### 6.3.1 Data Lifecycle Management

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Data retention policies documented** | [ ] | _/5 | 📋 | Medium |
| **Automated data purging processes** | [ ] | _/5 | 📋 | Medium |
| **Data archiving strategy implemented** | [ ] | _/5 | 📋 | Low |
| **Legal hold capabilities** | [ ] | _/5 | 📋 | Medium |
| **Data subject rights processes (GDPR)** | [ ] | _/5 | 📋 | High |

#### 6.3.2 Data Quality and Integrity

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Data validation rules implemented** | [ ] | _/5 | 📋 | Medium |
| **Data quality monitoring** | [ ] | _/5 | 📋 | Low |
| **Master data management strategy** | [ ] | _/5 | 📋 | Low |
| **Data transformation and ETL security** | [ ] | _/5 | 📋 | Medium |
| **Data integrity verification processes** | [ ] | _/5 | 📋 | Medium |

---

## 7. Application Architecture Assessment

### 7.1 Application Patterns and Design

#### 7.1.1 Microservices Architecture

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Service boundaries well-defined** | [ ] | _/5 | 📋 | Medium |
| **API versioning strategy implemented** | [ ] | _/5 | 📋 | Medium |
| **Service mesh for inter-service communication** | [ ] | _/5 | 📋 | Low |
| **Circuit breaker patterns implemented** | [ ] | _/5 | 📋 | Medium |
| **Distributed tracing configured** | [ ] | _/5 | 📋 | Low |
| **Event-driven architecture patterns** | [ ] | _/5 | 📋 | Low |

#### 7.1.2 API Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **API Gateway implemented with security policies** | [ ] | _/5 | 📋 | High |
| **OAuth 2.0/OpenID Connect authentication** | [ ] | _/5 | 📋 | High |
| **API rate limiting and throttling** | [ ] | _/5 | 📋 | Medium |
| **Input validation and sanitization** | [ ] | _/5 | 📋 | High |
| **API security testing (SAST/DAST)** | [ ] | _/5 | 📋 | Medium |
| **API documentation and OpenAPI specs** | [ ] | _/5 | 📋 | Low |

### 7.2 Container Architecture (AKS)

#### 7.2.1 Kubernetes Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Network policies implemented** | [ ] | _/5 | 📋 | High |
| **Pod Security Standards enforced** | [ ] | _/5 | 📋 | High |
| **RBAC configured for Kubernetes** | [ ] | _/5 | 📋 | High |
| **Secrets management with Azure Key Vault** | [ ] | _/5 | 📋 | High |
| **Container image scanning in CI/CD** | [ ] | _/5 | 📋 | High |
| **Admission controllers configured** | [ ] | _/5 | 📋 | Medium |
| **Runtime security monitoring** | [ ] | _/5 | 📋 | Medium |

#### 7.2.2 Container Registry Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Private container registry (ACR) used** | [ ] | _/5 | 📋 | High |
| **Image vulnerability scanning enabled** | [ ] | _/5 | 📋 | High |
| **Trusted base images from verified publishers** | [ ] | _/5 | 📋 | Medium |
| **Image signing and verification** | [ ] | _/5 | 📋 | Medium |
| **Quarantine policies for vulnerable images** | [ ] | _/5 | 📋 | Medium |

**Validation Commands:**
```bash
# Check AKS cluster configuration
az aks show --name "aks-cluster" --resource-group "rg-name" --query "{networkProfile:networkProfile, addonProfiles:addonProfiles}"

# Verify ACR security settings
az acr list --query "[].{name:name, adminUserEnabled:adminUserEnabled, policies:policies}"

# Check Kubernetes network policies
kubectl get networkpolicies --all-namespaces
```

### 7.3 Serverless Architecture

#### 7.3.1 Azure Functions Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Function apps isolated in VNet** | [ ] | _/5 | 📋 | High |
| **Authentication and authorization configured** | [ ] | _/5 | 📋 | High |
| **Managed Identity for resource access** | [ ] | _/5 | 📋 | High |
| **Input validation in function code** | [ ] | _/5 | 📋 | Medium |
| **Secure configuration management** | [ ] | _/5 | 📋 | Medium |

#### 7.3.2 Logic Apps Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Logic Apps isolated in Integration Service Environment** | [ ] | _/5 | 📋 | Medium |
| **Connector security configured** | [ ] | _/5 | 📋 | Medium |
| **Access control for Logic App triggers** | [ ] | _/5 | 📋 | Medium |
| **Secure parameter handling** | [ ] | _/5 | 📋 | Medium |

---

## 8. DevSecOps Architecture Review

### 8.1 CI/CD Pipeline Security

#### 8.1.1 Source Code Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Branch protection policies enforced** | [ ] | _/5 | 📋 | High |
| **Code review requirements (minimum reviewers)** | [ ] | _/5 | 📋 | Medium |
| **Secret scanning in repositories** | [ ] | _/5 | 📋 | High |
| **Static Application Security Testing (SAST)** | [ ] | _/5 | 📋 | High |
| **Dependency vulnerability scanning** | [ ] | _/5 | 📋 | High |
| **License compliance scanning** | [ ] | _/5 | 📋 | Low |

#### 8.1.2 Build Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Build agents secured and isolated** | [ ] | _/5 | 📋 | High |
| **Container image scanning in pipelines** | [ ] | _/5 | 📋 | High |
| **Infrastructure as Code (IaC) scanning** | [ ] | _/5 | 📋 | High |
| **Software Bill of Materials (SBOM) generation** | [ ] | _/5 | 📋 | Medium |
| **Artifact signing and attestation** | [ ] | _/5 | 📋 | Medium |
| **Security gates prevent vulnerable deployments** | [ ] | _/5 | 📋 | High |

#### 8.1.3 Deployment Security

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Environment-specific deployment approval** | [ ] | _/5 | 📋 | Medium |
| **Dynamic Application Security Testing (DAST)** | [ ] | _/5 | 📋 | Medium |
| **Infrastructure drift detection** | [ ] | _/5 | 📋 | Medium |
| **Automated security testing post-deployment** | [ ] | _/5 | 📋 | Medium |
| **Rollback procedures documented and tested** | [ ] | _/5 | 📋 | Medium |

### 8.2 Infrastructure as Code (IaC)

#### 8.2.1 IaC Security Practices

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **IaC templates follow security best practices** | [ ] | _/5 | 📋 | High |
| **Parameter validation and constraints** | [ ] | _/5 | 📋 | Medium |
| **Secrets management in IaC pipelines** | [ ] | _/5 | 📋 | High |
| **IaC testing and validation** | [ ] | _/5 | 📋 | Medium |
| **Version control for all IaC templates** | [ ] | _/5 | 📋 | Medium |
| **IaC deployment audit logging** | [ ] | _/5 | 📋 | Medium |

**Validation Commands:**
```bash
# Check for IaC scanning in pipelines
az pipelines variable list --pipeline-id "pipeline-id" --query "[?contains(name, 'CHECKOV') || contains(name, 'TRIVY')]"

# Verify deployment history
az deployment group list --resource-group "rg-name" --query "[].{name:name, provisioningState:properties.provisioningState}"
```

### 8.3 Supply Chain Security

#### 8.3.1 Third-Party Dependencies

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Dependency vulnerability management** | [ ] | _/5 | 📋 | High |
| **Private package repositories** | [ ] | _/5 | 📋 | Medium |
| **Dependency pinning and version control** | [ ] | _/5 | 📋 | Medium |
| **License compliance tracking** | [ ] | _/5 | 📋 | Low |
| **Supply chain attack prevention** | [ ] | _/5 | 📋 | High |

---

## 9. Compliance and Governance Architecture

### 9.1 Azure Policy Implementation

#### 9.1.1 Policy Framework

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Comprehensive policy initiatives deployed** | [ ] | _/5 | 📋 | High |
| **Custom policies for organization-specific needs** | [ ] | _/5 | 📋 | Medium |
| **Policy exemption process documented** | [ ] | _/5 | 📋 | Medium |
| **Policy compliance monitoring and reporting** | [ ] | _/5 | 📋 | High |
| **Automated remediation policies** | [ ] | _/5 | 📋 | Medium |

#### 9.1.2 Regulatory Compliance

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **ISO 27001 controls mapped and implemented** | [ ] | _/5 | 📋 | High |
| **SOC 2 Type II requirements addressed** | [ ] | _/5 | 📋 | High |
| **GDPR compliance measures implemented** | [ ] | _/5 | 📋 | High |
| **Industry-specific compliance (HIPAA, PCI-DSS)** | [ ] | _/5 | 📋 | Variable |
| **Compliance evidence automation** | [ ] | _/5 | 📋 | Medium |

**Validation Commands:**
```bash
# Check policy compliance state
az policy state list --filter "ComplianceState eq 'NonCompliant'" --top 10

# Review policy assignments
az policy assignment list --query "[].{name:name, policyDefinitionId:policyDefinitionId, enforcementMode:enforcementMode}"

# Check compliance dashboard
az policy state summarize --filter "PolicyAssignmentId eq '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyAssignments/{assignment-name}'"
```

### 9.2 Logging and Auditing

#### 9.2.1 Centralized Logging

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Log Analytics workspace centrally configured** | [ ] | _/5 | 📋 | High |
| **Diagnostic settings enabled for all resources** | [ ] | _/5 | 📋 | High |
| **Activity logs retained per compliance requirements** | [ ] | _/5 | 📋 | High |
| **Application logging standardized** | [ ] | _/5 | 📋 | Medium |
| **Log data classification and protection** | [ ] | _/5 | 📋 | Medium |

#### 9.2.2 Security Monitoring

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Microsoft Sentinel deployed and configured** | [ ] | _/5 | 📋 | High |
| **Threat detection rules active and tuned** | [ ] | _/5 | 📋 | High |
| **SOAR playbooks for automated response** | [ ] | _/5 | 📋 | Medium |
| **Security incident response procedures** | [ ] | _/5 | 📋 | High |
| **Threat intelligence integration** | [ ] | _/5 | 📋 | Medium |

### 9.3 Configuration Management

#### 9.3.1 Baseline Configuration

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Security baselines documented** | [ ] | _/5 | 📋 | High |
| **Configuration drift detection** | [ ] | _/5 | 📋 | Medium |
| **Automated compliance remediation** | [ ] | _/5 | 📋 | Medium |
| **Change management integration** | [ ] | _/5 | 📋 | Medium |
| **Configuration backup and recovery** | [ ] | _/5 | 📋 | Medium |

---

## 10. Disaster Recovery and Business Continuity

### 10.1 Business Impact Analysis

#### 10.1.1 Critical System Identification

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Business impact analysis completed** | [ ] | _/5 | 📋 | Critical |
| **Recovery Time Objectives (RTO) defined** | [ ] | _/5 | 📋 | Critical |
| **Recovery Point Objectives (RPO) defined** | [ ] | _/5 | 📋 | Critical |
| **System dependencies mapped** | [ ] | _/5 | 📋 | High |
| **Cost of downtime calculated** | [ ] | _/5 | 📋 | Medium |

### 10.2 Disaster Recovery Strategy

#### 10.2.1 Azure Site Recovery

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **ASR configured for critical VMs** | [ ] | _/5 | 📋 | High |
| **Cross-region replication strategy** | [ ] | _/5 | 📋 | High |
| **DR testing schedule and results** | [ ] | _/5 | 📋 | High |
| **Failover and failback procedures documented** | [ ] | _/5 | 📋 | High |
| **Network configuration for DR site** | [ ] | _/5 | 📋 | High |

#### 10.2.2 Data Backup Strategy

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Automated backup policies configured** | [ ] | _/5 | 📋 | Critical |
| **Cross-region backup replication** | [ ] | _/5 | 📋 | High |
| **Backup testing and validation** | [ ] | _/5 | 📋 | High |
| **Point-in-time recovery capabilities** | [ ] | _/5 | 📋 | Medium |
| **Backup security and encryption** | [ ] | _/5 | 📋 | High |

**Validation Commands:**
```bash
# Check ASR configuration
az backup vault list --query "[].{name:name, location:location}"

# Verify backup policies
az backup policy list --vault-name "vault-name" --resource-group "rg-name"

# Check database backup configuration
az sql db list --server "server-name" --resource-group "rg-name" --query "[].{name:name, earliestRestoreDate:earliestRestoreDate}"
```

### 10.3 Business Continuity Planning

#### 10.3.1 Incident Response

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Incident response plan documented** | [ ] | _/5 | 📋 | Critical |
| **Emergency contact procedures** | [ ] | _/5 | 📋 | High |
| **Communication plan during incidents** | [ ] | _/5 | 📋 | High |
| **Roles and responsibilities defined** | [ ] | _/5 | 📋 | High |
| **Regular tabletop exercises conducted** | [ ] | _/5 | 📋 | Medium |

#### 10.3.2 Recovery Procedures

| Assessment Criteria | Status | Maturity | Evidence | Risk Level |
|---------------------|--------|----------|----------|------------|
| **Step-by-step recovery runbooks** | [ ] | _/5 | 📋 | High |
| **Automated recovery procedures** | [ ] | _/5 | 📋 | Medium |
| **Recovery testing documentation** | [ ] | _/5 | 📋 | High |
| **Post-incident review processes** | [ ] | _/5 | 📋 | Medium |
| **Lessons learned integration** | [ ] | _/5 | 📋 | Medium |

---

## Assessment Summary and Scoring

### Overall Architecture Maturity Score

| Domain | Score (/5) | Criticality | Status |
|--------|------------|-------------|---------|
| Security Pillar | _/5 | Critical | [ ] Complete |
| Reliability Pillar | _/5 | High | [ ] Complete |
| Performance Pillar | _/5 | Medium | [ ] Complete |
| Cost Optimization | _/5 | Medium | [ ] Complete |
| Operational Excellence | _/5 | High | [ ] Complete |
| Landing Zone Architecture | _/5 | High | [ ] Complete |
| Network Architecture | _/5 | Critical | [ ] Complete |
| Identity & Access | _/5 | Critical | [ ] Complete |
| Data Architecture | _/5 | High | [ ] Complete |
| Application Architecture | _/5 | Medium | [ ] Complete |
| DevSecOps | _/5 | High | [ ] Complete |
| Compliance & Governance | _/5 | Critical | [ ] Complete |
| Disaster Recovery | _/5 | Critical | [ ] Complete |

### Risk Assessment Summary

| Risk Level | Count | Priority |
|------------|-------|----------|
| Critical | ___ | Immediate |
| High | ___ | 30 days |
| Medium | ___ | 90 days |
| Low | ___ | Next planning cycle |

### Key Findings and Recommendations

#### Critical Issues (Immediate Attention Required)
1. [ ] _Finding 1_: _Description and remediation_
2. [ ] _Finding 2_: _Description and remediation_
3. [ ] _Finding 3_: _Description and remediation_

#### High Priority Issues (30-day remediation)
1. [ ] _Finding 1_: _Description and remediation_
2. [ ] _Finding 2_: _Description and remediation_
3. [ ] _Finding 3_: _Description and remediation_

#### Medium Priority Issues (90-day remediation)
1. [ ] _Finding 1_: _Description and remediation_
2. [ ] _Finding 2_: _Description and remediation_
3. [ ] _Finding 3_: _Description and remediation_

### Next Steps and Action Plan

1. **Immediate Actions (0-7 days)**
   - [ ] Address critical security findings
   - [ ] Implement emergency security controls
   - [ ] Establish monitoring for critical systems

2. **Short-term Actions (1-4 weeks)**
   - [ ] Remediate high-priority findings
   - [ ] Enhance logging and monitoring
   - [ ] Implement missing security controls

3. **Medium-term Actions (1-3 months)**
   - [ ] Address medium-priority findings
   - [ ] Optimize performance and costs
   - [ ] Enhance operational procedures

4. **Long-term Actions (3-12 months)**
   - [ ] Strategic architecture improvements
   - [ ] Advanced security capabilities
   - [ ] Continuous improvement processes

### Assessment Metadata

| Field | Value |
|-------|-------|
| Assessment Date | ___________ |
| Assessor(s) | ___________ |
| Architecture Version | ___________ |
| Review Frequency | ___________ |
| Next Review Date | ___________ |
| Stakeholders Engaged | ___________ |
| Documentation References | ___________ |

---

**Document Control:**
- Version: 1.0
- Last Updated: _________
- Review Cycle: Quarterly
- Approved By: _________
- Distribution: Architecture Team, Security Team, Compliance Team

**Note:** This checklist should be customized based on specific organizational requirements, regulatory obligations, and risk tolerance. Regular updates are recommended to incorporate new Azure features, security best practices, and lessons learned from assessments.
