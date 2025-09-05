# Comprehensive Risk Scoring & Assessment Methodology

**Document Version**: 2.0  
**Date**: _______________  
**Next Review**: _______________  
**Approved By**: _______________

## Executive Summary

This document defines the comprehensive risk scoring methodology for Azure security assessments, integrating quantitative and qualitative approaches to provide accurate risk prioritization and business impact assessment. The methodology aligns with industry standards including ISO 31000, NIST Risk Management Framework, and Azure-specific risk factors.

### Key Features
- **Hybrid Scoring**: Combines qualitative and quantitative risk assessment methods
- **Business Alignment**: Integrates business impact and asset criticality
- **Industry Standards**: Incorporates CVSS 3.1, OWASP risk rating, and cloud security benchmarks
- **Azure Integration**: Includes Azure-specific risk factors and security service metrics
- **Automation Ready**: Structured for integration with Azure Policy, Sentinel, and Defender for Cloud

## Risk Assessment Framework

### 1. Qualitative Risk Assessment

#### **Likelihood Assessment Scale (1-5)**

| Score | Rating | Description | Indicators | Annual Probability |
|-------|--------|-------------|------------|-------------------|
| **5** | **Almost Certain** | Event will occur in most circumstances | Strong attack vectors, known exploits, high exposure | > 90% |
| **4** | **Likely** | Event will probably occur in most circumstances | Multiple attack vectors, documented vulnerabilities | 60-90% |
| **3** | **Possible** | Event might occur at some time | Some attack vectors, potential vulnerabilities | 30-60% |
| **2** | **Unlikely** | Event could occur at some time | Limited attack vectors, low exposure | 10-30% |
| **1** | **Rare** | Event may occur only in exceptional circumstances | No known attack vectors, well protected | < 10% |

#### **Likelihood Assessment Criteria**

**Technical Factors**:
- **Exploitability (Weight: 30%)**
  - Public exploits available: +2
  - Proof of concept exists: +1
  - Technical complexity: Simple (+2), Moderate (+1), High (0)
  - Required privileges: None (+2), Low (+1), High (0)

- **Attack Surface (Weight: 25%)**
  - Internet-facing services: +2
  - Network exposure level: External (+2), Internal (+1), Isolated (0)
  - Authentication requirements: None (+2), Weak (+1), Strong (0)
  - Network segmentation: None (+2), Basic (+1), Advanced (0)

- **Vulnerability Characteristics (Weight: 25%)**
  - CVSS Base Score: >9.0 (+2), 7.0-8.9 (+1), <7.0 (0)
  - Age of vulnerability: >1 year (+2), 6-12 months (+1), <6 months (0)
  - Patch availability: No patch (+2), Complex patch (+1), Simple patch (0)

- **Detection & Response (Weight: 20%)**
  - Monitoring coverage: None (+2), Basic (+1), Comprehensive (0)
  - Detection capability: None (+2), Limited (+1), Effective (0)
  - Response capability: None (+2), Manual (+1), Automated (0)

#### **Impact Assessment Scale (1-5)**

| Score | Rating | Description | Financial Impact | Operational Impact | Compliance Impact |
|-------|--------|-------------|-----------------|-------------------|------------------|
| **5** | **Catastrophic** | Severe long-term consequences | > $10M | Complete shutdown | Major regulatory action |
| **4** | **Major** | Significant medium-term consequences | $1M - $10M | Significant disruption | Regulatory investigation |
| **3** | **Moderate** | Some short-term consequences | $100K - $1M | Some disruption | Minor compliance gaps |
| **2** | **Minor** | Minimal short-term consequences | $10K - $100K | Minor disruption | Internal non-compliance |
| **1** | **Insignificant** | No significant consequences | < $10K | No disruption | No compliance impact |

#### **Impact Assessment Criteria**

**Business Impact Factors (Weight: 40%)**:
- **Financial Impact**
  - Direct financial loss
  - Business disruption costs
  - Recovery and remediation costs
  - Regulatory fines and penalties
  - Legal and litigation costs

- **Operational Impact**
  - Service availability degradation
  - Performance impact on critical systems
  - Customer experience degradation
  - Productivity loss
  - Supply chain disruption

**Data Impact Factors (Weight: 30%)**:
- **Data Classification Impact**
  - Public data: 0 points
  - Internal data: 1 point
  - Confidential data: 2 points
  - Highly confidential/regulated: 3 points

- **Data Volume Impact**
  - < 1,000 records: 0 points
  - 1,000 - 10,000 records: 1 point
  - 10,000 - 100,000 records: 2 points
  - > 100,000 records: 3 points

**Compliance & Legal Factors (Weight: 20%)**:
- **Regulatory Requirements**
  - GDPR: High impact (+2)
  - HIPAA: High impact (+2)
  - PCI DSS: High impact (+2)
  - SOX: Medium impact (+1)
  - Industry-specific regulations: Variable

**Reputation & Trust Factors (Weight: 10%)**:
- Customer trust impact
- Brand reputation damage
- Market confidence impact
- Partner relationship impact

#### **Qualitative Risk Matrix**

| Impact/Likelihood | Rare (1) | Unlikely (2) | Possible (3) | Likely (4) | Almost Certain (5) |
|-------------------|----------|-------------|-------------|------------|-------------------|
| **Catastrophic (5)** | Medium | High | High | Critical | Critical |
| **Major (4)** | Low | Medium | High | High | Critical |
| **Moderate (3)** | Low | Low | Medium | Medium | High |
| **Minor (2)** | Very Low | Low | Low | Medium | Medium |
| **Insignificant (1)** | Very Low | Very Low | Low | Low | Medium |

### 2. Quantitative Risk Assessment

#### **Annual Loss Expectancy (ALE) Calculation**

**Formula**: ALE = SLE × ARO

Where:
- **Single Loss Expectancy (SLE)** = Asset Value × Exposure Factor
- **Annual Rate of Occurrence (ARO)** = Expected frequency of occurrence per year

#### **Asset Valuation Framework**

**Asset Categories**:

| Asset Type | Valuation Method | Typical Range |
|------------|------------------|---------------|
| **Data Assets** | Replacement cost + business value | $10K - $50M |
| **Application Systems** | Development cost + business dependency | $100K - $20M |
| **Infrastructure** | Replacement cost + downtime impact | $50K - $10M |
| **Intellectual Property** | Market value + competitive advantage | $1M - $100M+ |
| **Reputation** | Brand value assessment | $5M - $1B+ |

**Asset Criticality Matrix**:

| Criticality | Description | Multiplier | Examples |
|-------------|-------------|------------|----------|
| **Mission Critical** | Essential for business survival | 4.0x | Core revenue systems, primary databases |
| **Business Critical** | Important for business operations | 3.0x | CRM systems, financial applications |
| **Important** | Significant business value | 2.0x | HR systems, internal tools |
| **Standard** | Standard business value | 1.0x | Development systems, archives |

#### **Exposure Factor Assessment**

| Threat Type | Typical Exposure Factor | Description |
|-------------|------------------------|-------------|
| **Data Breach** | 0.1 - 0.8 | Percentage of data compromised |
| **System Compromise** | 0.2 - 1.0 | Percentage of system functionality lost |
| **Service Disruption** | 0.1 - 1.0 | Percentage of service availability lost |
| **Intellectual Property Theft** | 0.1 - 1.0 | Percentage of competitive advantage lost |

#### **Cost Factor Integration**

**Direct Costs**:
- Investigation and forensics: $50K - $500K
- System recovery and rebuild: $100K - $2M
- Data recovery and restoration: $25K - $1M
- Third-party services: $50K - $1M
- Regulatory fines: $10K - $100M+

**Indirect Costs**:
- Business disruption: 2-10x direct costs
- Reputation damage: 1-5x direct costs
- Customer churn: 1-20x annual customer value
- Legal and litigation: $100K - $50M+

### 3. Azure-Specific Risk Factors

#### **Azure Service Risk Multipliers**

| Service Category | Base Risk Multiplier | Factors |
|------------------|----------------------|---------|
| **Compute Services** | 1.0 | +0.5 if public IP, +0.3 if no managed identity |
| **Data Services** | 1.5 | +0.5 if public endpoint, +0.3 if no encryption |
| **Network Services** | 0.8 | +0.7 if permissive NSG rules, +0.5 if no WAF |
| **Identity Services** | 1.2 | +0.8 if no MFA, +0.5 if weak password policies |
| **Security Services** | 0.5 | -0.3 if properly configured and monitored |

#### **Azure Security Control Effectiveness**

| Control Category | Effectiveness Score | Impact on Risk Score |
|------------------|-------------------|----------------------|
| **Microsoft Defender for Cloud** | 0.7 - 0.9 | -20% to -40% risk reduction |
| **Azure Policy** | 0.6 - 0.8 | -15% to -30% risk reduction |
| **Microsoft Sentinel** | 0.8 - 0.9 | -25% to -35% risk reduction |
| **Conditional Access** | 0.7 - 0.9 | -20% to -40% risk reduction |
| **Private Endpoints** | 0.8 - 0.9 | -30% to -50% risk reduction |

#### **Cloud-Specific Risk Considerations**

**Shared Responsibility Model Impact**:
- Customer responsibility areas: Full risk ownership
- Shared responsibility areas: 50% risk reduction
- Microsoft responsibility areas: 90% risk reduction

**Multi-Tenancy Risks**:
- Tenant isolation failures: +1.5x multiplier
- Cross-tenant data exposure: +2.0x multiplier
- Privilege escalation across tenants: +1.8x multiplier

### 4. CVSS Integration Framework

#### **CVSS 3.1 Base Score Integration**

**CVSS Score Mapping to Likelihood**:
- **9.0 - 10.0 (Critical)**: Likelihood +2 points
- **7.0 - 8.9 (High)**: Likelihood +1 point
- **4.0 - 6.9 (Medium)**: Likelihood +0 points
- **0.1 - 3.9 (Low)**: Likelihood -1 point

**Environmental Score Adjustments**:
- **Confidentiality Requirement**: High (+0.5), Medium (0), Low (-0.5)
- **Integrity Requirement**: High (+0.5), Medium (0), Low (-0.5)
- **Availability Requirement**: High (+0.5), Medium (0), Low (-0.5)

#### **Temporal Score Considerations**
- **Exploit Code Maturity**: Functional (+1), Proof of concept (+0.5), Unproven (0)
- **Remediation Level**: Unavailable (+1), Workaround (+0.5), Official fix (0)
- **Report Confidence**: Confirmed (+0.5), Reasonable (+0.25), Unknown (0)

### 5. Risk Score Calculation

#### **Composite Risk Score Formula**

**Final Risk Score = (Qualitative Score × 0.6) + (Quantitative Score × 0.4) × Azure Multiplier × Control Effectiveness**

Where:
- **Qualitative Score**: (Likelihood × Impact) normalized to 0-10
- **Quantitative Score**: ALE normalized to 0-10 scale
- **Azure Multiplier**: Service-specific risk adjustments
- **Control Effectiveness**: Reduction based on implemented controls

#### **Risk Score Normalization**

| Raw Score | Risk Level | Priority | SLA Target |
|-----------|------------|----------|------------|
| **9.0 - 10.0** | **Critical** | P0 | 24 hours |
| **7.0 - 8.9** | **High** | P1 | 7 days |
| **4.0 - 6.9** | **Medium** | P2 | 30 days |
| **2.0 - 3.9** | **Low** | P3 | 90 days |
| **0.0 - 1.9** | **Very Low** | P4 | 180 days |

### 6. Control Effectiveness Assessment

#### **Control Design Evaluation**

| Rating | Score | Description | Criteria |
|--------|-------|-------------|----------|
| **Adequate** | 3 | Well-designed control | Addresses root cause, follows best practices |
| **Needs Improvement** | 2 | Partially effective design | Some gaps, requires enhancement |
| **Deficient** | 1 | Poorly designed control | Significant gaps, major redesign needed |

#### **Control Operating Effectiveness**

| Rating | Score | Description | Evidence Required |
|--------|-------|-------------|-------------------|
| **Effective** | 3 | Consistent, reliable operation | Multiple samples, no exceptions |
| **Partially Effective** | 2 | Generally effective with exceptions | Some exceptions, corrective action |
| **Ineffective** | 1 | Unreliable or inconsistent operation | Frequent failures, major remediation |

#### **Control Maturity Assessment**

**Maturity Levels (Based on CMMI)**:

| Level | Name | Score | Description | Characteristics |
|-------|------|-------|-------------|----------------|
| **5** | **Optimizing** | 4.0 | Continuous improvement | Metrics-driven optimization |
| **4** | **Managed** | 3.0 | Quantitatively managed | Performance measurements |
| **3** | **Defined** | 2.0 | Standardized process | Documented procedures |
| **2** | **Repeatable** | 1.0 | Basic process discipline | Some documentation |
| **1** | **Initial** | 0.0 | Ad hoc processes | Informal, reactive |

### 7. Risk Appetite & Tolerance Framework

#### **Organizational Risk Appetite**

**Risk Appetite Levels**:
- **Conservative**: Accept only low risks (score < 3.0)
- **Moderate**: Accept low to medium risks (score < 6.0)
- **Aggressive**: Accept low to high risks (score < 8.0)
- **Risk-taking**: Accept all but critical risks (score < 9.0)

#### **Risk Tolerance Thresholds**

| Business Function | Maximum Acceptable Risk | Justification Required |
|-------------------|------------------------|----------------------|
| **Revenue Generation** | Medium (6.0) | Above 6.0 requires board approval |
| **Customer Data** | Low (3.0) | Above 3.0 requires CISO approval |
| **Financial Systems** | Low (3.0) | Above 3.0 requires CFO approval |
| **Development/Test** | High (8.0) | Above 8.0 requires CTO approval |

### 8. Remediation Priority Matrix

#### **Priority Calculation**

**Priority Score = (Risk Score × Business Impact Weight) × Exploitability Factor**

**Business Impact Weights**:
- Revenue-impacting systems: 1.5x
- Customer-facing systems: 1.3x
- Internal systems: 1.0x
- Development/test systems: 0.7x

**Exploitability Factors**:
- Exploit available publicly: 1.5x
- Proof of concept exists: 1.2x
- No known exploits: 1.0x

#### **Remediation Timeframes**

| Priority | Risk Level | Target Timeline | Escalation | Approval Required |
|----------|------------|----------------|------------|-------------------|
| **P0** | Critical | 24 hours | Immediate | CISO |
| **P1** | High | 7 days | 48 hours | Security Lead |
| **P2** | Medium | 30 days | Weekly | Team Lead |
| **P3** | Low | 90 days | Monthly | Manager |
| **P4** | Very Low | 180 days | Quarterly | Team Lead |

### 9. Metrics & Reporting

#### **Risk Metrics**

**Primary KPIs**:
- **Mean Risk Score**: Average risk score across all findings
- **Risk Velocity**: Rate of risk score change over time
- **Control Effectiveness**: Percentage of effective controls
- **Compliance Score**: Percentage of compliant controls
- **Remediation Rate**: Percentage of findings remediated on time

**Risk Distribution Metrics**:
- Percentage of findings by risk level
- Risk concentration by business function
- Control maturity distribution
- Trend analysis over time

#### **Reporting Framework**

**Executive Dashboard**:
- Risk heat map by business function
- Top 10 critical risks
- Control effectiveness trends
- Compliance status overview
- Remediation progress tracking

**Technical Reports**:
- Detailed risk register
- Control assessment results
- Vulnerability trending
- Patch compliance metrics
- Security posture scoring

### 10. Risk Score Examples

#### **Example 1: Public-Facing Web Application with SQL Injection**

**Qualitative Assessment**:
- Likelihood: 4 (Likely) - Public exploit available, minimal complexity
- Impact: 4 (Major) - Customer data exposure, regulatory fines

**Quantitative Assessment**:
- Asset Value: $5M (customer database)
- Exposure Factor: 0.6 (60% of data at risk)
- SLE: $3M
- ARO: 0.8 (80% annual probability)
- ALE: $2.4M

**Azure Factors**:
- Service: App Service with SQL Database (+1.5 multiplier)
- Public endpoint: +0.5
- No WAF: +0.5

**Control Effectiveness**: 0.6 (some monitoring, basic policies)

**Final Risk Score**: 8.7 (High Priority)

#### **Example 2: Internal VM with Missing Patches**

**Qualitative Assessment**:
- Likelihood: 2 (Unlikely) - Internal network, requires network access
- Impact: 2 (Minor) - Development system, minimal data

**Quantitative Assessment**:
- Asset Value: $100K
- Exposure Factor: 0.3
- SLE: $30K
- ARO: 0.2
- ALE: $6K

**Azure Factors**:
- Service: Virtual Machine (1.0 multiplier)
- Private network: No additional multiplier

**Control Effectiveness**: 0.8 (good network segmentation)

**Final Risk Score**: 2.1 (Low Priority)

### 11. Quality Assurance

#### **Scoring Validation**

**Validation Checks**:
- Independent review of high/critical risk scores
- Statistical analysis of score distribution
- Peer review of quantitative calculations
- Business stakeholder validation of impact assessments

**Calibration Process**:
- Regular benchmarking against industry standards
- Historical incident correlation analysis
- External assessment validation
- Continuous methodology refinement

---

**Document Control**:
- **Version**: 2.0
- **Created By**: _______________ **Date**: _______
- **Reviewed By**: _______________ **Date**: _______
- **Approved By**: _______________ **Date**: _______
- **Next Review**: _______________ (Annual)
