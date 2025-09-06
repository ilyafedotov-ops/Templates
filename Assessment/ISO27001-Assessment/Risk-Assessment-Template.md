# ISO 27001:2022 Risk Assessment Template

## Executive Summary

**Assessment Date:** [Date]  
**Organization:** [Organization Name]  
**Assessment Scope:** [Scope Definition]  
**Risk Assessment Team:** [Lead Assessor and Team Members]  
**Assessment Period:** [Start Date] - [End Date]

### Risk Assessment Results Summary
- **Total Assets Assessed:** [Number]
- **Total Risks Identified:** [Number]
- **Critical Risks:** [Number] ([Percentage]%)
- **High Risks:** [Number] ([Percentage]%)
- **Medium Risks:** [Number] ([Percentage]%)
- **Low Risks:** [Number] ([Percentage]%)
- **Overall Risk Level:** [Critical/High/Medium/Low]

### Risk Treatment Summary
- **Risks Requiring Immediate Treatment:** [Number]
- **Risks with Existing Controls:** [Number]
- **Residual Risks Accepted:** [Number]
- **Risk Treatment Budget Required:** [Amount]

## Risk Assessment Methodology

### Risk Management Framework Alignment
This assessment follows:
- **ISO 27001:2022** Clauses 6.1.2 and 8.2 requirements
- **ISO 31000:2018** Risk management guidelines
- **ISO 27005:2022** Information security risk management
- **[Organization Risk Framework]** if applicable

### Risk Assessment Approach
- **Asset-Based Assessment**: Focus on information assets and their vulnerabilities
- **Threat-Based Assessment**: Consider current threat landscape and attack vectors
- **Scenario-Based Assessment**: Evaluate realistic attack scenarios and business impact
- **Control-Based Assessment**: Assess existing control effectiveness

### Risk Calculation Methodology

#### Risk Formula
**Risk Level = Likelihood × Impact × Asset Value**

#### Likelihood Scale (1-5)
| Rating | Description | Frequency | Examples |
|--------|-------------|-----------|----------|
| 5 - Very High | Almost certain to occur | More than once per year | Daily attacks, known vulnerabilities |
| 4 - High | Likely to occur | Once per 1-2 years | Regular attack attempts, industry trends |
| 3 - Medium | Possible to occur | Once per 3-5 years | Occasional incidents, emerging threats |
| 2 - Low | Unlikely to occur | Once per 5-10 years | Rare events, targeted attacks |
| 1 - Very Low | Rare occurrence | Less than once per 10 years | Nation-state attacks, perfect storms |

#### Impact Scale (1-5)
| Rating | Financial Impact | Operational Impact | Reputational Impact | Legal/Regulatory Impact |
|--------|------------------|--------------------|--------------------|------------------------|
| 5 - Catastrophic | >$10M | >30 days downtime | International media | Criminal prosecution |
| 4 - Major | $1M-$10M | 7-30 days downtime | National media | Regulatory fines |
| 3 - Moderate | $100K-$1M | 1-7 days downtime | Industry coverage | Compliance violations |
| 2 - Minor | $10K-$100K | 4-24 hours downtime | Local coverage | Minor penalties |
| 1 - Negligible | <$10K | <4 hours downtime | Internal only | No legal impact |

#### Asset Value Scale (1-5)
| Rating | Description | Criticality | Examples |
|--------|-------------|-------------|----------|
| 5 - Critical | Mission critical | Cannot operate without | Core business systems, customer data |
| 4 - High | Business critical | Severe impact if lost | Financial systems, employee data |
| 3 - Medium | Important | Moderate impact | Support systems, operational data |
| 2 - Low | Useful | Minor impact | Archive data, development systems |
| 1 - Minimal | Nice to have | No significant impact | Test data, obsolete systems |

#### Risk Rating Matrix
| Likelihood | Impact 1 | Impact 2 | Impact 3 | Impact 4 | Impact 5 |
|------------|----------|----------|----------|----------|----------|
| 5 | Medium | High | High | Critical | Critical |
| 4 | Low | Medium | High | High | Critical |
| 3 | Low | Low | Medium | High | High |
| 2 | Low | Low | Low | Medium | High |
| 1 | Low | Low | Low | Low | Medium |

## Asset Inventory and Classification

### Information Assets

#### Critical Assets (Value: 5)
| Asset ID | Asset Name | Asset Type | Owner | Location | Classification |
|----------|------------|------------|-------|----------|----------------|
| A001 | Customer Database | Database | [Owner] | Azure SQL Database | Confidential |
| A002 | Financial Systems | Application | [Owner] | Azure VMs | Confidential |
| A003 | Core Business Application | Application | [Owner] | Azure App Service | Confidential |
| A004 | Encryption Keys | Cryptographic | [Owner] | Azure Key Vault | Secret |

#### High Value Assets (Value: 4)
| Asset ID | Asset Name | Asset Type | Owner | Location | Classification |
|----------|------------|------------|-------|----------|----------------|
| A005 | Employee Directory | Database | [Owner] | Azure AD | Internal |
| A006 | Email Systems | Application | [Owner] | Microsoft 365 | Internal |
| A007 | Document Management | Application | [Owner] | SharePoint Online | Internal |
| A008 | Network Infrastructure | Infrastructure | [Owner] | Azure Virtual Network | Internal |

#### Medium Value Assets (Value: 3)
| Asset ID | Asset Name | Asset Type | Owner | Location | Classification |
|----------|------------|------------|-------|----------|----------------|
| A009 | Development Environment | Environment | [Owner] | Azure DevOps | Internal |
| A010 | Monitoring Systems | Application | [Owner] | Azure Monitor | Internal |
| A011 | Backup Systems | Infrastructure | [Owner] | Azure Backup | Internal |

#### Low Value Assets (Value: 2)
| Asset ID | Asset Name | Asset Type | Owner | Location | Classification |
|----------|------------|------------|-------|----------|----------------|
| A012 | Test Environment | Environment | [Owner] | Azure Test VMs | Public |
| A013 | Training Materials | Documentation | [Owner] | SharePoint | Public |

### Asset Dependencies
| Primary Asset | Dependent Assets | Dependency Type | Impact of Loss |
|---------------|------------------|-----------------|----------------|
| A001 - Customer Database | A003 - Business Application | Data dependency | Critical |
| A004 - Encryption Keys | A001, A002, A003 | Security dependency | Catastrophic |
| A008 - Network Infrastructure | All cloud assets | Infrastructure dependency | Major |

## Threat Landscape Analysis

### External Threats

#### Cybercriminals
- **Motivation**: Financial gain
- **Capabilities**: Advanced persistent threats, ransomware, data theft
- **Targeting**: Customer data, financial systems, business disruption
- **Likelihood**: High (4)
- **Trend**: Increasing sophistication and automation

#### Nation-State Actors
- **Motivation**: Espionage, disruption, political
- **Capabilities**: Advanced techniques, zero-day exploits
- **Targeting**: Intellectual property, strategic information
- **Likelihood**: Medium (3)
- **Trend**: Increasing geopolitical tensions

#### Hacktivists
- **Motivation**: Ideological, social causes
- **Capabilities**: Website defacement, DDoS attacks
- **Targeting**: Public-facing systems, reputation
- **Likelihood**: Low (2)
- **Trend**: Event-driven activity

### Internal Threats

#### Malicious Insiders
- **Motivation**: Financial, revenge, ideology
- **Capabilities**: Privileged access, system knowledge
- **Targeting**: Sensitive data, system disruption
- **Likelihood**: Medium (3)
- **Trend**: Stable but high impact

#### Negligent Insiders
- **Motivation**: Unintentional errors
- **Capabilities**: Accidental exposure, misconfigurations
- **Targeting**: Any accessible systems
- **Likelihood**: High (4)
- **Trend**: Increasing with cloud complexity

### Natural Disasters and Environmental Threats
- **Natural Disasters**: Earthquakes, floods, storms
- **Infrastructure Failures**: Power outages, network failures
- **Pandemic**: Business disruption, remote work challenges
- **Likelihood**: Varies by geography and season

## Vulnerability Assessment

### Technical Vulnerabilities

#### Network Security Vulnerabilities
| Vulnerability ID | Description | Affected Assets | CVSS Score | Exploitability |
|------------------|-------------|-----------------|------------|----------------|
| V001 | Unpatched network devices | A008 | 8.1 | High |
| V002 | Weak firewall rules | A008 | 6.5 | Medium |
| V003 | Unencrypted network traffic | A001, A002 | 7.2 | Medium |

#### Application Vulnerabilities
| Vulnerability ID | Description | Affected Assets | CVSS Score | Exploitability |
|------------------|-------------|-----------------|------------|----------------|
| V004 | SQL injection vulnerability | A001 | 9.2 | High |
| V005 | Cross-site scripting (XSS) | A003 | 6.8 | Medium |
| V006 | Insecure authentication | A002 | 8.5 | High |

#### Infrastructure Vulnerabilities
| Vulnerability ID | Description | Affected Assets | CVSS Score | Exploitability |
|------------------|-------------|-----------------|------------|----------------|
| V007 | Unpatched operating systems | Multiple | 7.8 | High |
| V008 | Weak access controls | Multiple | 6.2 | Medium |
| V009 | Insufficient logging | Multiple | 5.1 | Low |

### Organizational Vulnerabilities

#### Process Vulnerabilities
- **Lack of security awareness training** - High impact on human error risks
- **Inadequate incident response procedures** - Delays in threat mitigation
- **Insufficient change management** - Increases configuration errors
- **Weak vendor management** - Third-party security risks

#### Physical Security Vulnerabilities
- **Inadequate access controls** - Unauthorized physical access
- **Poor environmental controls** - Equipment failure risks
- **Insufficient surveillance** - Undetected security incidents

## Risk Analysis and Evaluation

### Critical Risks (Risk Score 16-25)

#### Risk R001: Data Breach via SQL Injection
- **Asset**: A001 - Customer Database
- **Threat**: External cybercriminals exploiting SQL injection
- **Vulnerability**: V004 - SQL injection vulnerability
- **Likelihood**: 4 (High)
- **Impact**: 5 (Catastrophic)
- **Asset Value**: 5 (Critical)
- **Risk Score**: 20 (Critical)

**Business Impact Analysis:**
- Financial: $5M+ in fines, legal costs, and business loss
- Operational: 7+ days system downtime for forensics and remediation
- Reputational: National media coverage, customer trust loss
- Legal: Regulatory fines, class action lawsuits

**Current Controls:**
- Web Application Firewall (Partial effectiveness)
- Database access controls (Limited effectiveness)
- Network segmentation (Moderate effectiveness)

**Control Effectiveness**: 30% (Inadequate)

**Residual Risk Score**: 14 (High - requires immediate treatment)

#### Risk R002: Ransomware Attack on Business Systems
- **Asset**: A002 - Financial Systems, A003 - Business Application
- **Threat**: External cybercriminals deploying ransomware
- **Vulnerability**: V007 - Unpatched systems, V008 - Weak access controls
- **Likelihood**: 4 (High)
- **Impact**: 5 (Catastrophic)
- **Asset Value**: 5 (Critical)
- **Risk Score**: 20 (Critical)

**Business Impact Analysis:**
- Financial: $3M+ ransom payment consideration, business interruption
- Operational: 14+ days system restoration and business disruption
- Reputational: Industry coverage, customer service impact
- Legal: Regulatory notification requirements

**Current Controls:**
- Endpoint protection (Moderate effectiveness)
- Backup systems (High effectiveness)
- User access controls (Limited effectiveness)

**Control Effectiveness**: 50% (Partial)

**Residual Risk Score**: 10 (High - requires immediate treatment)

#### Risk R003: Insider Data Theft
- **Asset**: A001 - Customer Database, A002 - Financial Systems
- **Threat**: Malicious insider with privileged access
- **Vulnerability**: V008 - Weak access controls, Insufficient monitoring
- **Likelihood**: 3 (Medium)
- **Impact**: 5 (Catastrophic)
- **Asset Value**: 5 (Critical)
- **Risk Score**: 15 (High)

**Business Impact Analysis:**
- Financial: $2M+ in investigation, legal costs, and fines
- Operational: 5+ days investigation and system lockdown
- Reputational: Significant industry and media attention
- Legal: Criminal investigation, regulatory scrutiny

**Current Controls:**
- Background checks (High effectiveness)
- Role-based access control (Moderate effectiveness)
- Activity monitoring (Limited effectiveness)

**Control Effectiveness**: 40% (Inadequate)

**Residual Risk Score**: 9 (Medium - requires treatment)

### High Risks (Risk Score 10-15)

#### Risk R004: Cloud Misconfiguration Data Exposure
- **Asset**: A001 - Customer Database, A005 - Employee Directory
- **Threat**: Accidental exposure via misconfiguration
- **Vulnerability**: V008 - Weak access controls, Human error
- **Likelihood**: 4 (High)
- **Impact**: 3 (Moderate)
- **Asset Value**: 4 (High)
- **Risk Score**: 12 (High)

**Business Impact Analysis:**
- Financial: $500K in fines and remediation costs
- Operational: 2 days incident response and remediation
- Reputational: Industry coverage, regulatory attention
- Legal: Data protection violation penalties

**Current Controls:**
- Cloud configuration management (Moderate effectiveness)
- Access reviews (Limited effectiveness)
- Change management (Moderate effectiveness)

**Control Effectiveness**: 60% (Partial)

**Residual Risk Score**: 5 (Medium - monitor and improve)

### Medium Risks (Risk Score 6-9)

#### Risk R005: Business Email Compromise
- **Asset**: A006 - Email Systems
- **Threat**: Social engineering and phishing attacks
- **Vulnerability**: User awareness, email security controls
- **Likelihood**: 4 (High)
- **Impact**: 2 (Minor)
- **Asset Value**: 3 (Medium)
- **Risk Score**: 8 (Medium)

**Business Impact Analysis:**
- Financial: $100K in fraudulent transfers and investigation
- Operational: 1 day incident response and communication
- Reputational: Limited impact, internal communications
- Legal: Minimal regulatory impact

**Current Controls:**
- Email security gateway (High effectiveness)
- User awareness training (Moderate effectiveness)
- Multi-factor authentication (High effectiveness)

**Control Effectiveness**: 75% (Good)

**Residual Risk Score**: 2 (Low - acceptable risk)

### Risk Heat Map

```
           IMPACT
         1   2   3   4   5
L  5 |    |   | H | C | C |
I  4 | L  | M | H | H | C |
K  3 | L  | L | M | H | H |
E  2 | L  | L | L | M | H |
L  1 | L  | L | L | L | M |

Legend:
L = Low Risk (1-3)
M = Medium Risk (4-6)
H = High Risk (7-12)
C = Critical Risk (13-25)

Risk Distribution:
R001: Critical (5,4) - SQL Injection
R002: Critical (5,4) - Ransomware
R003: High (5,3) - Insider Threat
R004: High (3,4) - Cloud Misconfiguration
R005: Medium (2,4) - Email Compromise
```

## Azure/Cloud-Specific Risk Assessment

### Cloud Service Provider Risks

#### Azure Service Dependencies
| Service | Risk Type | Impact | Mitigation |
|---------|-----------|---------|------------|
| Azure AD | Service outage | High | Hybrid identity, MFA alternatives |
| Azure SQL | Data availability | Critical | Geo-redundancy, backups |
| Azure Storage | Data loss | Critical | Geo-replication, versioning |
| Azure Network | Connectivity loss | High | ExpressRoute, VPN backup |

#### Shared Responsibility Model Risks
- **Microsoft Responsibility**: Physical security, infrastructure patching
- **Customer Responsibility**: Data classification, identity management, network controls
- **Shared Responsibility**: Operating system patching, network configuration

### Cloud-Specific Threat Vectors
1. **Account Takeover**: Compromised cloud admin accounts
2. **Resource Hijacking**: Unauthorized resource provisioning
3. **Data Residency**: Compliance violations due to data location
4. **API Vulnerabilities**: Insecure cloud service APIs
5. **Container Escape**: Container security weaknesses

## Risk Treatment Options

### Risk Treatment Strategies

#### Avoid (Eliminate the Risk)
- Discontinue vulnerable services or processes
- Redesign systems to eliminate vulnerabilities
- Change business processes to avoid threats

#### Reduce (Mitigate the Risk)
- Implement security controls to reduce likelihood
- Implement business controls to reduce impact
- Enhance monitoring and detection capabilities

#### Transfer (Share the Risk)
- Cyber insurance for financial impact transfer
- Third-party security services
- Cloud service provider security features

#### Accept (Retain the Risk)
- Formally acknowledge and document residual risk
- Management approval for risk acceptance
- Regular review and monitoring of accepted risks

### Risk Treatment Plan

#### Critical Risk Treatment (0-30 days)

**R001 - Data Breach via SQL Injection**
- **Treatment**: Reduce
- **Actions**: 
  - Immediate patching of SQL injection vulnerability
  - Implement database activity monitoring
  - Deploy advanced web application firewall
  - Conduct penetration testing validation
- **Owner**: [Security Team Lead]
- **Budget**: $150K
- **Timeline**: 30 days
- **Success Criteria**: Vulnerability eliminated, monitoring operational

**R002 - Ransomware Attack**
- **Treatment**: Reduce + Transfer
- **Actions**:
  - Implement endpoint detection and response (EDR)
  - Enhance backup and recovery capabilities
  - Deploy privileged access management (PAM)
  - Purchase cyber insurance coverage
- **Owner**: [IT Operations Manager]
- **Budget**: $200K + Insurance premium
- **Timeline**: 30 days
- **Success Criteria**: EDR deployed, backup recovery tested

**R003 - Insider Data Theft**
- **Treatment**: Reduce
- **Actions**:
  - Implement data loss prevention (DLP)
  - Deploy user and entity behavior analytics (UEBA)
  - Enhance privileged access monitoring
  - Implement data classification and labeling
- **Owner**: [Security Team Lead]
- **Budget**: $100K
- **Timeline**: 30 days
- **Success Criteria**: DLP operational, anomalous behavior detection

#### High Risk Treatment (30-90 days)

**R004 - Cloud Misconfiguration**
- **Treatment**: Reduce
- **Actions**:
  - Implement cloud security posture management (CSPM)
  - Automate configuration compliance checking
  - Enhance change management processes
  - Conduct cloud security training
- **Owner**: [Cloud Architect]
- **Budget**: $75K
- **Timeline**: 60 days
- **Success Criteria**: CSPM deployed, configuration drift eliminated

#### Medium Risk Treatment (90-180 days)

**R005 - Business Email Compromise**
- **Treatment**: Reduce
- **Actions**:
  - Enhance email security with advanced threat protection
  - Implement email authentication (DMARC, SPF, DKIM)
  - Conduct phishing simulation training
  - Deploy email encryption for sensitive communications
- **Owner**: [IT Security Manager]
- **Budget**: $50K
- **Timeline**: 90 days
- **Success Criteria**: Email security enhanced, user awareness improved

## Risk Monitoring and Review

### Key Risk Indicators (KRIs)
- Number of critical vulnerabilities identified
- Mean time to patch critical vulnerabilities
- Security incident frequency and severity
- Failed authentication attempts
- Privileged access usage patterns
- Data exfiltration alerts
- Cloud resource configuration changes

### Risk Review Schedule
- **Monthly**: Critical and high-risk review
- **Quarterly**: Complete risk register review
- **Semi-annually**: Risk assessment methodology review
- **Annually**: Comprehensive risk assessment update

### Risk Reporting
- **Weekly**: KRI dashboard for security team
- **Monthly**: Risk status report to management
- **Quarterly**: Risk committee review and decisions
- **Annually**: Board-level risk assessment presentation

## Residual Risk Assessment

### Accepted Residual Risks

| Risk ID | Description | Residual Risk Level | Acceptance Rationale | Review Date |
|---------|-------------|--------------------|--------------------|-------------|
| R003 | Insider Data Theft | Medium | Cost-benefit analysis, monitoring in place | [Date] |
| R004 | Cloud Misconfiguration | Low | Controls implemented, regular monitoring | [Date] |
| R005 | Email Compromise | Low | Acceptable risk level, good controls | [Date] |

### Risk Acceptance Criteria
- **Critical**: No residual critical risks accepted
- **High**: Require C-level approval and detailed justification
- **Medium**: Require management approval and mitigation plan
- **Low**: May be accepted with appropriate monitoring

## Compliance and Regulatory Considerations

### Regulatory Requirements
- **GDPR**: Data breach notification, privacy impact assessments
- **SOX**: Financial data protection, audit requirements
- **HIPAA**: Healthcare information protection (if applicable)
- **PCI DSS**: Payment card data security (if applicable)

### Industry Standards Alignment
- **ISO 27001**: Risk management requirements
- **NIST Framework**: Risk assessment and management
- **CIS Controls**: Implementation-focused security controls

## Risk Assessment Validation

### Internal Validation
- **Peer Review**: Risk assessment reviewed by security team
- **Management Review**: Senior management validation of findings
- **Business Owner Review**: Asset owners validate risk scenarios

### External Validation
- **Third-Party Assessment**: Independent risk assessment validation
- **Penetration Testing**: Technical validation of identified vulnerabilities
- **Red Team Exercise**: Realistic attack scenario validation

## Continuous Improvement

### Risk Assessment Maturity Enhancement
1. **Automation**: Implement automated risk assessment tools
2. **Integration**: Connect risk assessment with business processes
3. **Quantification**: Enhance quantitative risk analysis capabilities
4. **Intelligence**: Integrate threat intelligence and market data

### Lessons Learned
- Document lessons learned from security incidents
- Update risk scenarios based on emerging threats
- Enhance assessment methodology based on experience
- Share knowledge with industry peers and forums

## Conclusion

This risk assessment has identified [number] risks across the organization's information assets, with [number] critical risks requiring immediate attention. The assessment demonstrates the need for a comprehensive risk treatment program with an investment of approximately $[amount] to address critical and high-priority risks.

Key findings include:
1. Critical vulnerabilities in customer-facing applications require immediate patching
2. Ransomware preparedness needs significant enhancement
3. Insider threat monitoring capabilities are insufficient
4. Cloud security posture management requires implementation

The organization should prioritize the implementation of the risk treatment plan to reduce the overall risk posture from [current level] to an acceptable level of [target level] within [timeframe].

---

**Risk Assessment Approval:**
- Risk Assessment Team Lead: [Name] [Date]
- Information Security Manager: [Name] [Date]
- Chief Information Security Officer: [Name] [Date]
- Chief Risk Officer: [Name] [Date]

**Next Steps:**
1. Present findings to executive leadership
2. Secure budget approval for risk treatment activities
3. Initiate critical risk treatment projects
4. Establish ongoing risk monitoring processes
5. Schedule next comprehensive risk assessment

**Document Control:**
- Version: 1.0
- Date: [Date]
- Next Review: [Date + 12 months]
- Classification: Confidential