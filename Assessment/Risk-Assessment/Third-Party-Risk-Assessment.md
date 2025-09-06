# Third-Party Risk Assessment Template

## Document Control
| Field | Value |
|-------|--------|
| Document Title | Third-Party Risk Assessment |
| Version | 1.0 |
| Date | [Date] |
| Prepared By | [Vendor Risk Manager] |
| Reviewed By | [CPO/Legal/CISO] |
| Approved By | [CRO] |
| Classification | Confidential |
| Next Review Date | [Annual Review Date] |

## Executive Summary

### Assessment Scope
This third-party risk assessment evaluates risks associated with vendors, suppliers, business partners, and service providers that have access to organizational data, systems, or facilities, or provide critical services to business operations.

### Third-Party Risk Categories
1. **Operational Risks**: Service disruption, performance failures, dependency risks
2. **Security Risks**: Data breaches, cyber incidents, access control failures
3. **Compliance Risks**: Regulatory violations, audit failures, contractual non-compliance
4. **Financial Risks**: Vendor insolvency, cost overruns, hidden fees
5. **Reputation Risks**: Vendor misconduct, negative publicity, association risks
6. **Strategic Risks**: Vendor lock-in, competitive disadvantage, technology obsolescence
7. **Concentration Risks**: Over-reliance on single vendors or regions

### Assessment Results Summary
- **Critical Risk Vendors**: [Number] requiring immediate risk mitigation
- **High Risk Vendors**: [Number] requiring enhanced monitoring
- **Medium Risk Vendors**: [Number] requiring standard oversight
- **Low Risk Vendors**: [Number] requiring basic monitoring
- **Total Vendor Portfolio**: [Number] active vendors assessed

## 1. Assessment Methodology

### 1.1 Framework Alignment
This assessment is conducted in accordance with:
- **ISO 27036** - Information Security for Supplier Relationships
- **NIST SP 800-161** - Supply Chain Risk Management
- **FAIR (Factor Analysis of Information Risk)** for vendor risk quantification
- **COSO Enterprise Risk Management** framework
- **Shared Assessments SIG** standardized questionnaires
- **SOC 2** and **ISO 27001** control frameworks for security assessment

### 1.2 Third-Party Risk Assessment Process

#### Phase 1: Vendor Inventory and Classification
1. **Vendor Discovery and Cataloging**
   - Contract management system review
   - Accounts payable analysis
   - IT asset inventory correlation
   - Department-level vendor identification
   - Shadow IT discovery

2. **Vendor Classification Framework**
   - **Criticality Levels**: Critical, High, Medium, Low
   - **Risk Categories**: Security, Operational, Financial, Compliance
   - **Access Levels**: No access, Limited access, Privileged access, Administrative access
   - **Data Classification**: Public, Internal, Confidential, Restricted

#### Phase 2: Risk Identification and Analysis
1. **Inherent Risk Assessment**
   - Business criticality analysis
   - Data and system access evaluation
   - Geographic and regulatory risk factors
   - Vendor financial stability assessment
   - Vendor security posture evaluation

2. **Control Assessment**
   - Contractual protections evaluation
   - Service level agreement analysis
   - Security control verification
   - Compliance certification review
   - Monitoring and oversight assessment

#### Phase 3: Risk Evaluation and Treatment
1. **Residual Risk Calculation**
   - Risk scoring methodology
   - Control effectiveness evaluation
   - Risk aggregation and portfolio analysis
   - Risk appetite comparison

2. **Risk Treatment Planning**
   - Risk mitigation strategies
   - Contract renegotiation priorities
   - Vendor replacement analysis
   - Monitoring enhancement plans

### 1.3 Risk Rating Methodology

#### Vendor Criticality Scale (1-5)
| Level | Description | Business Impact | Examples |
|-------|-------------|----------------|-----------|
| 5 - Mission Critical | Service failure causes immediate business disruption | >$1M daily impact | Core banking systems, primary cloud provider |
| 4 - Business Critical | Service failure significantly impacts operations | $100K-$1M daily | HR systems, email services, key suppliers |
| 3 - Important | Service failure impacts efficiency | $10K-$100K daily | Office supplies, training providers |
| 2 - Supporting | Service failure causes minor inconvenience | $1K-$10K daily | Cleaning services, minor software tools |
| 1 - Non-Critical | Service failure has minimal impact | <$1K daily | Employee perks, non-essential services |

#### Data Access Risk Scale (1-5)
| Level | Data Classification | Access Type | Risk Level |
|-------|-------------------|-------------|------------|
| 5 - Unrestricted | Can access all data types including restricted | Administrative/root access | Very High |
| 4 - Privileged | Can access confidential and internal data | Privileged user access | High |
| 3 - Confidential | Can access confidential data only | Standard user access | Medium |
| 2 - Internal | Can access internal data only | Limited access | Low |
| 1 - Public | Can access public data only or no data access | No system access | Very Low |

#### Security Posture Scale (1-5)
| Level | Description | Certifications | Security Maturity |
|-------|-------------|---------------|-------------------|
| 5 - Advanced | Industry-leading security practices | SOC 2 Type II, ISO 27001, FedRAMP High | Advanced/Optimized |
| 4 - Strong | Robust security program | SOC 2 Type II, ISO 27001 | Managed/Quantitatively Managed |
| 3 - Adequate | Basic security controls in place | SOC 2 Type I, some compliance | Defined |
| 2 - Basic | Minimal security measures | Self-attestations only | Repeatable |
| 1 - Inadequate | Poor or unknown security posture | No certifications/assessments | Initial/Ad hoc |

#### Overall Risk Score Calculation
**Risk Score = (Criticality × Data Access Risk × Security Risk) ÷ Control Effectiveness**

Where Control Effectiveness = (Contractual Controls + Monitoring Controls + Technical Controls) ÷ 3

## 2. Vendor Portfolio Analysis

### 2.1 Vendor Inventory Summary

#### By Criticality Level
| Criticality Level | Count | % of Portfolio | Combined Spend | Top Risk Areas |
|-------------------|-------|----------------|----------------|----------------|
| Mission Critical | [#] | [%] | $[Amount] | [Primary risks] |
| Business Critical | [#] | [%] | $[Amount] | [Primary risks] |
| Important | [#] | [%] | $[Amount] | [Primary risks] |
| Supporting | [#] | [%] | $[Amount] | [Primary risks] |
| Non-Critical | [#] | [%] | $[Amount] | [Primary risks] |

#### By Service Category
| Category | Count | % of Spend | Critical Vendors | High Risk Count |
|----------|-------|------------|------------------|----------------|
| Cloud Services | [#] | [%] | [#] | [#] |
| Software/SaaS | [#] | [%] | [#] | [#] |
| Professional Services | [#] | [%] | [#] | [#] |
| Infrastructure/Hardware | [#] | [%] | [#] | [#] |
| Financial Services | [#] | [%] | [#] | [#] |
| Telecommunications | [#] | [%] | [#] | [#] |

### 2.2 Geographic Risk Distribution
| Region | Vendor Count | % of Spend | Data Processing | Regulatory Risks |
|--------|--------------|------------|-----------------|------------------|
| North America | [#] | [%] | [Yes/No] | [Risk factors] |
| Europe | [#] | [%] | [Yes/No] | [Risk factors] |
| Asia-Pacific | [#] | [%] | [Yes/No] | [Risk factors] |
| Other Regions | [#] | [%] | [Yes/No] | [Risk factors] |

## 3. Critical Vendor Risk Assessments

### 3.1 Vendor Risk Profile Template

#### VRA-001: [Vendor Name] - [Service Category]
- **Vendor Information**:
  - Company Name: [Name]
  - Primary Contact: [Name, Title, Contact]
  - Contract Manager: [Internal contact]
  - Contract Term: [Start date] to [End date]
  - Annual Spend: $[Amount]
  - Contract Value: $[Total value]

- **Service Description**:
  - Services Provided: [Detailed description]
  - Business Criticality: [Level 1-5]
  - Dependencies: [Other systems/vendors dependent on this service]
  - Service Level Requirements: [RTO, RPO, availability targets]

- **Risk Assessment**:
  - **Criticality Score**: [1-5] - [Justification]
  - **Data Access Risk**: [1-5] - [Types of data accessed]
  - **Security Posture**: [1-5] - [Assessment basis]
  - **Geographic Risk**: [1-5] - [Location-based risks]
  - **Financial Stability**: [1-5] - [Financial health assessment]
  - **Overall Risk Score**: [Calculated score] - [Risk Level]

- **Data and System Access**:
  - Data Types Accessed: [List data classifications]
  - System Access Level: [None/Read-only/Read-write/Administrative]
  - Network Connectivity: [VPN, direct connection, internet-only]
  - Authentication Method: [SSO, dedicated accounts, API keys]

- **Security and Compliance**:
  - Security Certifications: [SOC 2, ISO 27001, etc.]
  - Compliance Attestations: [GDPR, HIPAA, PCI-DSS, etc.]
  - Last Security Assessment: [Date and results summary]
  - Incident History: [Known security incidents]

- **Contractual Protections**:
  - Liability Caps: $[Amount] / [Percentage]
  - Indemnification: [Scope and limitations]
  - Insurance Requirements: [Types and amounts]
  - Data Protection Clauses: [GDPR, breach notification, etc.]
  - Security Requirements: [Specific security obligations]
  - Audit Rights: [Right to audit frequency and scope]
  - Termination Rights: [Conditions for termination]

### 3.2 Critical Vendor Assessments

#### Microsoft Azure (Cloud Infrastructure Provider)
- **Vendor Information**:
  - Company: Microsoft Corporation
  - Service Category: Cloud Infrastructure (IaaS/PaaS)
  - Criticality Level: Mission Critical (5)
  - Annual Spend: $[Amount]
  - Contract Type: Enterprise Agreement

- **Risk Assessment**:
  - **Criticality Score**: 5 - Hosts critical business applications and data
  - **Data Access Risk**: 5 - Administrative access to all organizational data
  - **Security Posture**: 5 - SOC 2 Type II, ISO 27001, FedRAMP High
  - **Geographic Risk**: 2 - Data centers in approved regions
  - **Financial Stability**: 1 - Strong financial position
  - **Overall Risk Score**: 25 (before controls) → 10 (after controls) = High Risk

- **Key Risk Areas**:
  - **Concentration Risk**: Heavy dependence on single cloud provider
  - **Data Sovereignty**: Cross-border data transfers
  - **Shared Responsibility**: Unclear responsibility boundaries
  - **Configuration Management**: Risk of misconfigurations
  - **Vendor Lock-in**: Difficulty migrating to alternative providers

- **Control Assessment**:
  - **Technical Controls**: Multi-region deployment, backup strategies
  - **Contractual Controls**: Data Processing Agreement, SLAs
  - **Monitoring Controls**: Azure Security Center, compliance monitoring
  - **Control Effectiveness**: 75% - Strong but some gaps remain

#### [Second Critical Vendor]
- **Assessment Details**: [Complete assessment following template]

## 4. Risk Analysis by Category

### 4.1 Operational Risks

#### OR-001: Single Points of Failure
- **Risk Description**: Critical business processes dependent on single vendors without adequate alternatives
- **Affected Vendors**: [List of vendors creating concentration risk]
- **Business Impact**: Service disruption, inability to serve customers
- **Likelihood**: Medium (3) - Vendor outages are common
- **Impact**: High (4) - Business operations halt
- **Risk Score**: 12 - High Risk
- **Mitigation Strategies**:
  - Develop vendor diversification strategy
  - Implement backup service providers
  - Create detailed continuity plans
  - Establish emergency procurement procedures

#### OR-002: Service Level Degradation
- **Risk Description**: Vendors failing to meet agreed service levels
- **Risk Assessment**: [Complete assessment]

#### OR-003: Technology Obsolescence
- **Risk Description**: Vendors using outdated or end-of-life technologies
- **Risk Assessment**: [Complete assessment]

### 4.2 Security Risks

#### SR-001: Data Breach at Vendor
- **Risk Description**: Vendor security incident resulting in compromise of organizational data
- **High-Risk Vendors**: [Vendors with access to sensitive data]
- **Potential Impact**:
  - Customer data exposure
  - Regulatory penalties
  - Reputation damage
  - Legal liability
- **Risk Factors**:
  - Weak vendor security posture
  - Inadequate data protection controls
  - Poor incident response capabilities
  - Lack of breach notification procedures
- **Quantitative Analysis**:
  - **Single Loss Expectancy**: $5,000,000
  - **Annual Rate of Occurrence**: 0.15 (15% chance)
  - **Annualized Loss Expectancy**: $750,000

#### SR-002: Unauthorized Access via Vendor Accounts
- **Risk Description**: Compromise of vendor access leading to unauthorized system access
- **Risk Assessment**: [Complete assessment]

#### SR-003: Supply Chain Attacks
- **Risk Description**: Attackers compromising vendor systems to attack downstream customers
- **Risk Assessment**: [Complete assessment]

### 4.3 Compliance Risks

#### CR-001: Regulatory Non-Compliance
- **Risk Description**: Vendor practices resulting in regulatory violations
- **Applicable Regulations**: GDPR, CCPA, SOX, HIPAA, PCI-DSS
- **Risk Assessment**: [Complete assessment]

#### CR-002: Audit Failures
- **Risk Description**: Vendor control failures discovered during audits
- **Risk Assessment**: [Complete assessment]

### 4.4 Financial Risks

#### FR-001: Vendor Insolvency
- **Risk Description**: Financial failure of critical vendors
- **High-Risk Indicators**:
  - Declining financial performance
  - Credit rating downgrades
  - Delayed payments to suppliers
  - Key personnel departures
- **Risk Assessment**: [Complete assessment]

#### FR-002: Cost Overruns and Hidden Fees
- **Risk Description**: Unexpected cost increases or undisclosed charges
- **Risk Assessment**: [Complete assessment]

## 5. Risk Treatment and Mitigation

### 5.1 Risk Treatment Strategy Framework

#### High-Risk Vendor Treatment Options
1. **Enhanced Due Diligence**: Increased assessment frequency and depth
2. **Contract Renegotiation**: Improved terms, SLAs, and protections
3. **Vendor Replacement**: Migration to lower-risk alternatives
4. **Risk Transfer**: Insurance or contractual risk transfer
5. **Additional Controls**: Technical or process controls to reduce risk

#### Medium-Risk Vendor Treatment
- Standard monitoring and periodic reassessment
- Basic contractual protections
- Incident response procedures
- Performance monitoring

#### Low-Risk Vendor Treatment
- Annual risk review
- Standard contract terms
- Basic monitoring procedures

### 5.2 Vendor Risk Mitigation Plans

#### Mitigation Plan 1: Microsoft Azure Risk Reduction
- **Target Risk Reduction**: High → Medium (Score 10 → 6)
- **Mitigation Actions**:
  
  1. **Multi-Cloud Strategy Implementation**
     - Identify workloads suitable for alternative cloud providers
     - Develop AWS secondary deployment for critical applications
     - Timeline: 12 months
     - Investment: $500K
     - Risk Reduction: 20%
  
  2. **Enhanced Configuration Management**
     - Implement Infrastructure as Code (Terraform)
     - Deploy Azure Policy for governance
     - Enable Azure Security Center premium
     - Timeline: 6 months
     - Investment: $200K
     - Risk Reduction: 15%
  
  3. **Improved Backup and Recovery**
     - Implement cross-region backups
     - Establish disaster recovery procedures
     - Test recovery procedures quarterly
     - Timeline: 4 months
     - Investment: $100K
     - Risk Reduction: 10%

- **Total Investment**: $800K
- **Expected Risk Reduction**: 45%
- **Monitoring**: Monthly Azure security posture reviews

#### Mitigation Plan 2: [Second High-Risk Vendor]
- **Treatment Strategy**: [Detail mitigation approach]

### 5.3 Contract Enhancement Priorities

#### Priority 1: Security and Data Protection
- **Enhanced Security Requirements**:
  - Mandatory security certifications (SOC 2 Type II minimum)
  - Encryption requirements for data at rest and in transit
  - Multi-factor authentication for all access
  - Regular penetration testing and vulnerability assessments
  - Incident response and breach notification procedures

- **Data Protection Clauses**:
  - Data Processing Agreements aligned with GDPR
  - Data residency requirements
  - Right to audit and inspect
  - Data return/deletion procedures upon termination
  - Subprocessor notification and approval requirements

#### Priority 2: Service Level and Performance
- **Enhanced SLA Requirements**:
  - Availability targets with financial penalties
  - Performance benchmarks and measurement
  - Disaster recovery and business continuity requirements
  - Change management notification procedures
  - Root cause analysis for incidents

#### Priority 3: Risk Management and Compliance
- **Risk Management Clauses**:
  - Annual risk assessments and questionnaires
  - Compliance certification maintenance
  - Insurance requirements and evidence
  - Right to terminate for security incidents
  - Regulatory compliance obligations

## 6. Vendor Risk Monitoring

### 6.1 Ongoing Monitoring Framework

#### Real-Time Monitoring
- **Security Incident Alerts**: Automated monitoring of vendor security incidents
- **Financial Health Indicators**: Credit rating changes, financial news alerts
- **Service Performance**: SLA compliance monitoring and dashboards
- **Compliance Status**: Certification expiration tracking

#### Periodic Assessments
- **Quarterly Reviews**: High-risk vendor status updates
- **Annual Assessments**: Comprehensive risk reassessment for all critical vendors
- **Contract Reviews**: Regular review of contract terms and performance
- **Market Analysis**: Industry risk trend analysis and benchmarking

### 6.2 Key Risk Indicators (KRIs)

#### Vendor Performance KRIs
| KRI | Threshold | Measurement | Frequency | Owner |
|-----|-----------|-------------|-----------|-------|
| SLA Compliance Rate | <95% | % of SLA targets met | Monthly | Vendor Manager |
| Security Incident Count | >1 per quarter | Number of reported incidents | Continuous | CISO |
| Financial Health Score | <Investment Grade | Credit rating/financial metrics | Quarterly | CFO |
| Contract Compliance | <90% | % of contract terms met | Monthly | Legal |

#### Portfolio-Level KRIs
| KRI | Threshold | Measurement | Frequency | Owner |
|-----|-----------|-------------|-----------|-------|
| Vendor Concentration Risk | >40% of spend with single vendor | Spending concentration ratio | Monthly | CPO |
| High-Risk Vendor Count | >10% of portfolio | % of vendors rated high risk | Quarterly | Risk Manager |
| Contract Renewal Risk | >20% of critical contracts expiring | % of contracts expiring in 12 months | Quarterly | Contract Manager |

### 6.3 Risk Reporting and Escalation

#### Risk Dashboard Components
- Vendor risk heat map (risk score vs. business impact)
- Top 10 highest risk vendors
- Risk trend analysis (improving/stable/worsening)
- KRI alert summary
- New vendor onboarding pipeline
- Contract renewal calendar

#### Escalation Procedures
- **High Risk Alert**: Immediate notification to vendor manager and risk owner
- **Critical Incident**: Emergency response team activation
- **Contract Breach**: Legal team engagement and escalation to C-suite
- **Regulatory Issue**: Compliance team notification and regulatory reporting

## 7. Vendor Lifecycle Risk Management

### 7.1 Vendor Onboarding Risk Assessment

#### Pre-Contract Risk Assessment
1. **Initial Vendor Screening**
   - Financial stability check
   - Security posture assessment
   - Compliance verification
   - Reference checks
   - Conflict of interest review

2. **Due Diligence Requirements**
   - Security questionnaire (SIG Lite/Core)
   - Financial statements review
   - Insurance certificate verification
   - Background checks for key personnel
   - Site visits for critical vendors

3. **Risk-Based Approval Process**
   - Low Risk: Automated approval
   - Medium Risk: Department head approval
   - High Risk: Risk committee approval
   - Critical Risk: C-suite approval

#### Contract Negotiation Risk Controls
- Standard contract templates with security provisions
- Risk-based contract terms and liability limits
- Service level agreements with penalties
- Regular audit and inspection rights
- Termination rights for cause

### 7.2 Ongoing Vendor Management

#### Performance Monitoring
- Regular service level reviews
- Customer satisfaction surveys
- Performance scorecards
- Incident tracking and analysis
- Cost and value analysis

#### Relationship Management
- Regular business reviews with critical vendors
- Strategic planning alignment
- Innovation and improvement initiatives
- Issue escalation and resolution
- Contract optimization opportunities

### 7.3 Vendor Exit and Transition

#### Exit Planning
- Data return and deletion procedures
- Knowledge transfer requirements
- System access revocation
- Alternative vendor identification
- Transition timeline and milestones

#### Risk Management During Transitions
- Continuity planning and backup providers
- Data security during migration
- Service level maintenance
- Staff training on new systems/processes
- Post-transition risk assessment

## 8. Appendices

### Appendix A: Complete Vendor Risk Register
[Detailed risk register for all assessed vendors]

### Appendix B: Vendor Assessment Questionnaires
[Security, operational, and compliance questionnaires]

### Appendix C: Contract Template Library
[Standard contract clauses for different risk levels]

### Appendix D: Vendor Risk Assessment Methodologies
[Detailed scoring methodologies and calculation formulas]

### Appendix E: Industry Benchmarking Data
[Comparative analysis with industry standards]

### Appendix F: Regulatory Requirements Matrix
[Mapping of regulations to vendor risk requirements]

### Appendix G: Vendor Emergency Contact List
[24/7 contact information for critical vendors]

### Appendix H: Business Impact Analysis Results
[BIA results showing vendor criticality to business processes]

---

**Document Classification**: Confidential - Internal Use Only
**Distribution**: CRO, CPO, CISO, Legal Team, Vendor Managers
**Retention Period**: 7 years from vendor contract termination
**Review Cycle**: Annual comprehensive review, quarterly updates for high-risk vendors