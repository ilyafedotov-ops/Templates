# Comprehensive Azure Security Assessment Plan

**Document Version**: 2.0  
**Date**: _______________  
**Assessment Type**: ☐ ISO 27001 ☐ SOC 2 Type II ☐ Hybrid ☐ Azure Security Best Practices  
**Assessment Lead**: ________________________  
**Executive Sponsor**: ________________________

## Executive Summary

### Business Context
**Organization**: _________________________  
**Industry**: _________________________  
**Regulatory Requirements**: ☐ GDPR ☐ HIPAA ☐ PCI DSS ☐ SOX ☐ ISO 27001 ☐ SOC 2 ☐ Other: _______  
**Business Criticality**: ☐ Mission Critical ☐ Business Critical ☐ Important ☐ Standard  
**Assessment Trigger**: ☐ Compliance Requirement ☐ Risk Assessment ☐ Incident Response ☐ Due Diligence ☐ Periodic Review

### Assessment Objectives
1. **Primary Objectives**:
   - ☐ Validate compliance with ISO 27001:2022 Annex A controls
   - ☐ Assess SOC 2 Trust Services Criteria implementation
   - ☐ Evaluate Azure security posture against Microsoft Cloud Security Benchmark
   - ☐ Identify critical security risks and control gaps
   - ☐ Establish baseline security metrics and KPIs

2. **Secondary Objectives**:
   - ☐ Review security governance and organizational controls
   - ☐ Assess cloud security architecture maturity
   - ☐ Evaluate DevSecOps integration and automation
   - ☐ Review incident response and business continuity capabilities
   - ☐ Provide strategic security roadmap recommendations

### Success Criteria
- **Quantitative Metrics**:
  - Security maturity score: Target ≥ 75% (3.0/4.0)
  - Control effectiveness: Target ≥ 85% effective controls
  - Risk reduction: Target ≥ 50% high/critical risk mitigation
  - Compliance coverage: Target 100% applicable controls assessed

- **Qualitative Outcomes**:
  - Clear understanding of security posture
  - Actionable remediation roadmap
  - Enhanced security awareness and capabilities
  - Improved security governance processes

## Detailed Scope Definition

### In-Scope Components

#### **Azure Environment Scope**
- **Management Groups**: _________________________
- **Subscriptions**: 
  - Production: _________________________
  - Staging: _________________________  
  - Development: _________________________
  - Sandbox: _________________________

- **Regions**: _________________________
- **Resource Groups**: ☐ All ☐ Critical only ☐ Specific: _________

#### **Technology Scope**
**Identity & Access Management**:
- ☐ Azure Active Directory tenants
- ☐ Privileged Identity Management (PIM)
- ☐ Conditional Access policies
- ☐ Multi-factor authentication
- ☐ Identity Protection
- ☐ Guest user management
- ☐ Service principals and managed identities

**Network Security**:
- ☐ Virtual networks and subnets
- ☐ Network Security Groups (NSGs)
- ☐ Azure Firewall
- ☐ Application Gateway / Web Application Firewall
- ☐ Private endpoints and service endpoints
- ☐ Azure Bastion
- ☐ ExpressRoute/VPN connections
- ☐ DDoS Protection

**Compute & Applications**:
- ☐ Virtual machines
- ☐ Azure App Service
- ☐ Azure Functions
- ☐ Azure Kubernetes Service (AKS)
- ☐ Azure Container Instances
- ☐ Logic Apps
- ☐ Service Fabric

**Data & Storage**:
- ☐ Azure SQL Database/Managed Instance
- ☐ Cosmos DB
- ☐ Storage Accounts (Blob, File, Table, Queue)
- ☐ Azure Data Factory
- ☐ Azure Synapse Analytics
- ☐ Azure Data Lake

**Security & Monitoring**:
- ☐ Microsoft Defender for Cloud
- ☐ Microsoft Sentinel
- ☐ Azure Monitor / Log Analytics
- ☐ Azure Key Vault
- ☐ Azure Information Protection
- ☐ Azure Policy
- ☐ Azure Security Center

**DevOps & CI/CD**:
- ☐ Azure DevOps Services
- ☐ GitHub repositories and actions
- ☐ Azure Container Registry
- ☐ Release pipelines
- ☐ Infrastructure as Code (IaC) templates

#### **Process & Governance Scope**
- ☐ Information Security Management System (ISMS)
- ☐ Risk management processes
- ☐ Change management procedures
- ☐ Incident response capabilities
- ☐ Business continuity and disaster recovery
- ☐ Vendor and third-party risk management
- ☐ Security awareness and training programs

### Out-of-Scope Items
- On-premises infrastructure (unless hybrid integration points)
- Third-party SaaS applications (unless Azure-integrated)
- Physical security of Azure datacenters
- Microsoft's internal security controls
- Network infrastructure owned by ISPs or connectivity providers
- Other: _________________________

### Assessment Boundaries
**Organizational Boundaries**: _________________________  
**Geographical Boundaries**: _________________________  
**Technical Boundaries**: _________________________  
**Time Period**: From _______ to _______

## Stakeholder Matrix & RACI

| Role | Individual | Responsibility | Contact |
|------|------------|----------------|---------|
| **Executive Sponsor** | _____________ | Accountable for assessment outcomes | _____________ |
| **Assessment Lead** | _____________ | Responsible for assessment execution | _____________ |
| **Security Lead** | _____________ | Subject matter expert, evidence provider | _____________ |
| **Azure Architect** | _____________ | Technical architecture guidance | _____________ |
| **DevOps Lead** | _____________ | CI/CD and automation insights | _____________ |
| **Compliance Officer** | _____________ | Regulatory requirement interpretation | _____________ |
| **IT Operations Manager** | _____________ | Infrastructure and operations | _____________ |
| **Data Protection Officer** | _____________ | Privacy and data governance | _____________ |
| **Business Process Owners** | _____________ | Business context and requirements | _____________ |

### RACI Matrix for Assessment Activities
| Activity | Exec Sponsor | Assessment Lead | Security Lead | Technical Teams |
|----------|--------------|----------------|---------------|----------------|
| **Assessment Planning** | A | R | C | I |
| **Risk Assessment** | A | R | C | C |
| **Control Testing** | I | R | C | C |
| **Evidence Collection** | I | R | C | R |
| **Findings Documentation** | I | R | C | I |
| **Remediation Planning** | A | C | R | C |
| **Executive Reporting** | R | R | C | I |

## Assessment Methodology Framework

### Assessment Approach
**Methodology Framework**: ☐ NIST CSF ☐ ISO 27001 ☐ COBIT ☐ Custom Hybrid  
**Assessment Model**: ☐ Self-Assessment ☐ Independent Assessment ☐ Hybrid

### Compliance Framework Mapping

#### **ISO 27001:2022 Coverage**
- **Annex A Controls**: 93 controls across 4 themes
- **Assessment Focus**:
  - Organizational controls (37 controls)
  - People controls (8 controls)
  - Physical and environmental controls (14 controls)
  - Technological controls (34 controls)

#### **SOC 2 Trust Services Criteria**
- **Common Criteria (CC)**: Organization & management, Communication & information, Risk assessment, Monitoring activities, Control activities
- **Availability (A)**: System availability commitments
- **Confidentiality (C)**: Confidential information protection  
- **Processing Integrity (PI)**: System processing completeness and accuracy
- **Privacy (P)**: Personal information collection and processing

#### **Microsoft Cloud Security Benchmark (MCSB)**
- **Security Domains**: Network security, Identity management, Privileged access, Data protection, Asset management, Logging & threat detection, Incident response, Posture & vulnerability management, Endpoint security, Backup & recovery, DevOps security

#### **CIS Azure Foundations Benchmark**
- **Identity and Access Management**: 22 controls
- **Security Center**: 23 controls  
- **Storage Accounts**: 8 controls
- **Database Services**: 8 controls
- **Logging and Monitoring**: 12 controls
- **Networking**: 7 controls
- **Virtual Machines**: 7 controls
- **Key Vault**: 5 controls
- **App Services**: 10 controls
- **Additional Security Considerations**: 15 controls

### Assessment Phases

#### **Phase 1: Planning & Preparation (Duration: 1-2 weeks)**
**Objectives**: Establish assessment foundation and stakeholder alignment

**Key Activities**:
1. **Stakeholder Engagement**
   - Executive briefing and sponsor alignment
   - Assessment team formation and training
   - Stakeholder interview scheduling
   - Communication plan execution

2. **Scope Finalization**
   - Detailed scope validation and documentation
   - Asset inventory and criticality assessment
   - Compliance requirement analysis
   - Risk appetite and tolerance definition

3. **Assessment Planning**
   - Assessment schedule development
   - Resource allocation and access provisioning
   - Evidence collection framework establishment
   - Quality assurance procedures definition

**Deliverables**:
- Finalized assessment plan
- Stakeholder communication matrix
- Asset inventory and criticality matrix
- Assessment schedule and resource plan

#### **Phase 2: Discovery & Information Gathering (Duration: 2-3 weeks)**
**Objectives**: Collect comprehensive information about current security posture

**Key Activities**:
1. **Documentation Review**
   - Security policies and procedures analysis
   - Architecture documentation review
   - Previous audit reports and assessments
   - Incident response and change management records

2. **Stakeholder Interviews**
   - Executive leadership interviews (governance focus)
   - Technical team interviews (implementation focus)
   - Process owner interviews (operational focus)
   - End-user interviews (awareness and usability)

3. **Technical Discovery**
   - Azure configuration assessment
   - Automated tool deployment and scanning
   - Network architecture analysis
   - Application security review

4. **Evidence Collection**
   - Control implementation evidence gathering
   - Configuration exports and screenshots
   - Log analysis and monitoring review
   - Policy compliance validation

**Deliverables**:
- Comprehensive questionnaire responses
- Technical configuration assessment
- Evidence repository and catalog
- Stakeholder interview summaries

#### **Phase 3: Control Assessment & Testing (Duration: 3-4 weeks)**
**Objectives**: Evaluate control design adequacy and operating effectiveness

**Key Activities**:
1. **Control Design Assessment**
   - Control mapping to compliance requirements
   - Design adequacy evaluation
   - Gap identification and documentation
   - Compensating control analysis

2. **Control Operating Effectiveness Testing**
   - Sample-based control testing
   - Automated control validation
   - Manual testing procedures execution
   - Exception analysis and documentation

3. **Risk Assessment**
   - Threat modeling and risk identification
   - Vulnerability assessment integration
   - Risk likelihood and impact analysis
   - Residual risk calculation

4. **Compliance Validation**
   - Framework requirement validation
   - Evidence adequacy assessment
   - Compliance gap identification
   - Remediation priority analysis

**Testing Techniques**:
- **Inquiry**: Interviews with process owners and operators
- **Inspection**: Review of documents, configurations, and evidence
- **Observation**: Direct observation of control performance
- **Re-performance**: Independent execution of control procedures
- **Automated Testing**: Tool-based validation and monitoring

**Deliverables**:
- Control assessment results matrix
- Risk assessment and register
- Compliance gap analysis
- Testing evidence packages

#### **Phase 4: Analysis & Risk Rating (Duration: 1-2 weeks)**
**Objectives**: Analyze findings and provide risk-based prioritization

**Key Activities**:
1. **Findings Analysis**
   - Root cause analysis for identified gaps
   - Impact and likelihood assessment
   - Business context integration
   - Trend and pattern identification

2. **Risk Quantification**
   - Quantitative risk scoring application
   - Business impact assessment
   - Risk heat map development
   - Risk appetite alignment validation

3. **Prioritization**
   - Risk-based finding prioritization
   - Resource requirement estimation
   - Quick win identification
   - Strategic initiative alignment

4. **Benchmarking**
   - Industry comparison and benchmarking
   - Maturity level assessment
   - Best practice gap identification
   - Improvement opportunity analysis

**Deliverables**:
- Detailed findings register
- Risk assessment and quantification
- Priority matrix and heat map
- Maturity assessment results

#### **Phase 5: Reporting & Recommendations (Duration: 1-2 weeks)**
**Objectives**: Communicate findings and provide actionable recommendations

**Key Activities**:
1. **Report Development**
   - Executive summary creation
   - Detailed findings documentation
   - Recommendation development
   - Visual dashboard creation

2. **Stakeholder Communication**
   - Executive briefing preparation
   - Technical team communication
   - Management presentation development
   - Stakeholder feedback integration

3. **Remediation Planning**
   - Action plan development
   - Timeline and milestone definition
   - Resource requirement analysis
   - Success criteria establishment

4. **Knowledge Transfer**
   - Findings presentation and discussion
   - Remediation guidance provision
   - Tool and process training
   - Ongoing support planning

**Deliverables**:
- Executive assessment report
- Detailed technical findings
- Remediation action plan
- Security roadmap and strategy

#### **Phase 6: Remediation Planning & Handoff (Duration: 1 week)**
**Objectives**: Establish clear path forward and ensure successful handoff

**Key Activities**:
1. **Remediation Strategy**
   - Strategic roadmap development
   - Tactical action plan creation
   - Resource allocation recommendations
   - Timeline and milestone planning

2. **Governance Framework**
   - Ongoing monitoring plan
   - Progress tracking mechanisms
   - Escalation procedures
   - Review and validation schedules

3. **Capability Building**
   - Training needs assessment
   - Skill gap identification
   - Knowledge transfer execution
   - Resource requirement planning

4. **Continuous Improvement**
   - Metrics and KPI definition
   - Monitoring and alerting setup
   - Regular assessment scheduling
   - Improvement process establishment

**Deliverables**:
- Strategic security roadmap
- Detailed remediation plan
- Governance and monitoring framework
- Capability development plan

## Evidence Collection Framework

### Evidence Categories
1. **Design Evidence**: Policies, procedures, standards, and architectural documentation
2. **Implementation Evidence**: Configurations, screenshots, system outputs, and code
3. **Operating Evidence**: Logs, reports, monitoring data, and performance metrics
4. **Compliance Evidence**: Audit trails, certifications, and regulatory documentation

### Evidence Collection Methods
- **Automated Collection**: Azure Resource Graph queries, Policy compliance exports, Sentinel analytics
- **Manual Collection**: Screenshots, document reviews, interview notes
- **Tool-Based Collection**: Security scanning results, monitoring dashboards, log analysis
- **Observation**: Process walkthroughs, control demonstrations, system interactions

### Evidence Repository Structure
```
Evidence Repository/
├── 01-Governance/
│   ├── Policies/
│   ├── Procedures/
│   ├── Risk-Management/
│   └── Compliance/
├── 02-Identity/
│   ├── Azure-AD/
│   ├── PIM/
│   ├── Conditional-Access/
│   └── Access-Reviews/
├── 03-Network/
│   ├── Architecture/
│   ├── Firewall/
│   ├── Private-Endpoints/
│   └── Monitoring/
├── 04-Data/
│   ├── Classification/
│   ├── Encryption/
│   ├── Backup/
│   └── Access-Controls/
├── 05-Monitoring/
│   ├── Log-Analytics/
│   ├── Sentinel/
│   ├── Defender/
│   └── Alerting/
├── 06-DevSecOps/
│   ├── Source-Control/
│   ├── CI-CD/
│   ├── Container-Security/
│   └── IaC/
├── 07-Vulnerability/
│   ├── Scanning/
│   ├── Patching/
│   ├── Assessments/
│   └── Remediation/
├── 08-Incident-Response/
│   ├── Plans/
│   ├── Procedures/
│   ├── Training/
│   └── Exercises/
└── 09-Business-Continuity/
    ├── BIA/
    ├── DR-Plans/
    ├── Testing/
    └── Communication/
```

### Evidence Handling Requirements
- **Security**: All evidence encrypted in transit and at rest
- **Access Control**: Role-based access to evidence repository
- **Retention**: Evidence retained per regulatory and organizational requirements
- **Chain of Custody**: Complete audit trail for all evidence
- **Privacy**: Personal data handling per privacy regulations

## Risk Management Framework

### Risk Identification Methods
- **Threat Modeling**: STRIDE, PASTA, or OCTAVE methodology
- **Vulnerability Assessment**: Automated scanning and manual testing
- **Control Gap Analysis**: Framework requirement vs. implementation gaps
- **Industry Intelligence**: Threat intelligence and industry-specific risks
- **Historical Analysis**: Previous incidents and lessons learned

### Risk Assessment Methodology

#### **Qualitative Risk Assessment**
**Likelihood Scale**:
- **Very Low (1)**: Remote possibility, highly unlikely
- **Low (2)**: Low possibility, unlikely but possible
- **Medium (3)**: Some possibility, reasonably likely
- **High (4)**: High possibility, likely to occur
- **Very High (5)**: Very high possibility, almost certain

**Impact Scale**:
- **Very Low (1)**: Negligible impact to business operations
- **Low (2)**: Minor impact, minimal business disruption
- **Medium (3)**: Moderate impact, some business disruption
- **High (4)**: Significant impact, major business disruption
- **Very High (5)**: Severe impact, critical business disruption

**Risk Matrix**:
| Impact/Likelihood | Very Low | Low | Medium | High | Very High |
|-------------------|----------|-----|--------|------|-----------|
| **Very High** | Medium | High | High | Critical | Critical |
| **High** | Low | Medium | High | High | Critical |
| **Medium** | Low | Low | Medium | Medium | High |
| **Low** | Very Low | Low | Low | Medium | Medium |
| **Very Low** | Very Low | Very Low | Low | Low | Medium |

#### **Quantitative Risk Assessment**
**Annual Loss Expectancy (ALE) Calculation**:
- ALE = Single Loss Expectancy (SLE) × Annual Rate of Occurrence (ARO)
- SLE = Asset Value × Exposure Factor
- Used for high-value or high-impact scenarios

### Risk Treatment Strategies
1. **Accept**: Acknowledge risk and accept potential consequences
2. **Avoid**: Eliminate risk by removing or changing the activity
3. **Mitigate**: Reduce likelihood or impact through controls
4. **Transfer**: Share risk through insurance or third-party services

## Quality Assurance Framework

### Assessment Quality Standards
- **Independence**: Assessment team independent from assessed operations
- **Competence**: Certified assessors with relevant experience
- **Objectivity**: Unbiased evaluation based on evidence
- **Professional Skepticism**: Critical evaluation of evidence and controls
- **Due Professional Care**: Thorough and competent assessment performance

### Quality Control Procedures
1. **Planning Review**: Independent review of assessment plan
2. **Evidence Review**: Supervisory review of collected evidence
3. **Testing Review**: Independent validation of testing procedures
4. **Report Review**: Multi-level review of assessment results
5. **Client Feedback**: Stakeholder feedback integration

### Quality Metrics
- **Coverage**: Percentage of in-scope controls assessed
- **Evidence Quality**: Adequate, relevant, and reliable evidence
- **Testing Depth**: Appropriate sample sizes and testing techniques
- **Timeliness**: Assessment completed within planned timeframes
- **Stakeholder Satisfaction**: Feedback scores and comments

## Communication Plan

### Communication Matrix
| Stakeholder Group | Frequency | Method | Content |
|-------------------|-----------|---------|---------|
| **Executive Sponsors** | Weekly | Status Reports | High-level progress, issues, decisions needed |
| **Assessment Team** | Daily | Standups | Task progress, blockers, coordination |
| **Technical Teams** | Bi-weekly | Working Sessions | Technical findings, evidence collection |
| **Security Team** | Weekly | Progress Reviews | Control assessment status, findings |
| **IT Operations** | As needed | Ad-hoc | Access requests, system information |

### Communication Protocols
- **Escalation**: Clear escalation path for issues and decisions
- **Confidentiality**: All communications treated as confidential
- **Documentation**: Meeting notes and decisions documented
- **Feedback**: Regular feedback collection and incorporation

## Timeline & Milestones

### Assessment Schedule
| Phase | Start Date | End Date | Duration | Key Milestones |
|-------|------------|----------|----------|----------------|
| **Planning** | _______ | _______ | 1-2 weeks | Plan approval, team formation |
| **Discovery** | _______ | _______ | 2-3 weeks | Evidence collection complete |
| **Assessment** | _______ | _______ | 3-4 weeks | Control testing complete |
| **Analysis** | _______ | _______ | 1-2 weeks | Risk assessment complete |
| **Reporting** | _______ | _______ | 1-2 weeks | Report delivery |
| **Handoff** | _______ | _______ | 1 week | Remediation plan approved |

### Critical Dependencies
- **Access Provisioning**: Azure subscription access, system accounts
- **Stakeholder Availability**: Key personnel for interviews and reviews
- **Documentation Availability**: Current policies, procedures, and configurations
- **Tool Deployment**: Security scanning tools and monitoring access
- **Management Support**: Executive sponsorship and organizational commitment

## Resource Requirements

### Assessment Team Structure
| Role | FTE | Skills Required |
|------|-----|----------------|
| **Assessment Lead** | 1.0 | Security assessment leadership, Azure expertise |
| **Senior Security Assessor** | 1.0 | ISO 27001/SOC 2 experience, control testing |
| **Azure Security Specialist** | 1.0 | Azure security services, configuration assessment |
| **DevSecOps Specialist** | 0.5 | CI/CD security, automation tools |
| **Risk Analyst** | 0.5 | Risk assessment, quantitative analysis |
| **Technical Writer** | 0.3 | Report writing, documentation |

### Technology Requirements
- **Assessment Tools**: Security scanning, configuration analysis
- **Collaboration Platform**: Secure document sharing and communication
- **Evidence Repository**: Encrypted storage with access controls
- **Analysis Tools**: Data analysis, visualization, reporting platforms
- **Azure Access**: Appropriate permissions for configuration review

### Budget Considerations
- **Personnel Costs**: Assessment team time and expertise
- **Technology Costs**: Tool licensing, cloud resources
- **Travel Costs**: On-site visits if required
- **Third-party Costs**: External services or specialized tools
- **Contingency**: 10-15% buffer for scope changes or issues

## Risk & Contingency Planning

### Assessment Risks
| Risk | Impact | Likelihood | Mitigation Strategy |
|------|--------|------------|-------------------|
| **Limited Access** | High | Medium | Early access provisioning, executive support |
| **Stakeholder Availability** | Medium | High | Flexible scheduling, multiple interview slots |
| **Incomplete Documentation** | Medium | Medium | Multiple evidence sources, observation methods |
| **Scope Creep** | Medium | Medium | Clear scope documentation, change control |
| **Technical Issues** | Low | Medium | Backup tools, alternative methods |

### Contingency Plans
- **Schedule Delays**: Flexible timeline with buffer periods
- **Resource Constraints**: Backup team members, outsourcing options
- **Technical Challenges**: Alternative assessment methods, expert consultation
- **Stakeholder Changes**: Rapid re-engagement, knowledge transfer
- **Scope Changes**: Formal change control process, impact assessment

## Success Metrics & KPIs

### Assessment Success Metrics
- **Scope Coverage**: 100% of planned controls assessed
- **Evidence Quality**: 95% of evidence rated adequate or better
- **Stakeholder Satisfaction**: Average rating ≥ 4.0/5.0
- **Timeline Performance**: Completion within 110% of planned duration
- **Budget Performance**: Completion within 105% of planned budget

### Post-Assessment Success Metrics
- **Remediation Progress**: 80% of high/critical findings addressed within 90 days
- **Risk Reduction**: 50% reduction in high/critical risks within 6 months
- **Control Improvement**: 25% improvement in control maturity scores
- **Compliance Achievement**: 95% compliance with applicable requirements
- **Security Incidents**: 30% reduction in security incidents

## Deliverables & Reports

### Primary Deliverables
1. **Executive Assessment Report** (15-25 pages)
   - Executive summary and key findings
   - Risk assessment and business impact
   - Strategic recommendations and roadmap
   - Compliance status and gaps

2. **Detailed Technical Report** (50-100 pages)
   - Comprehensive findings documentation
   - Control-by-control assessment results
   - Evidence summary and analysis
   - Detailed recommendations and remediation guidance

3. **Risk Register & Remediation Plan** (20-30 pages)
   - Prioritized risk inventory
   - Detailed action plans and timelines
   - Resource requirements and ownership
   - Progress tracking and monitoring framework

4. **Compliance Mapping Matrix** (Excel/PDF)
   - Framework requirement mappings
   - Control implementation status
   - Evidence cross-references
   - Gap analysis and remediation tracking

### Supporting Deliverables
- **Security Posture Dashboard**: Visual metrics and KPIs
- **Control Effectiveness Report**: Statistical analysis and trends
- **Evidence Portfolio**: Organized evidence repository
- **Presentation Materials**: Executive and technical presentations
- **Knowledge Transfer Documentation**: Process guides and training materials

## Approval & Sign-off

### Plan Approval
| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Executive Sponsor** | _______________ | _______________ | _______ |
| **Assessment Lead** | _______________ | _______________ | _______ |
| **Security Lead** | _______________ | _______________ | _______ |
| **IT Director** | _______________ | _______________ | _______ |

### Plan Acceptance Criteria
- ☐ Scope and objectives clearly defined and agreed
- ☐ Stakeholder roles and responsibilities established
- ☐ Timeline and resource commitments confirmed
- ☐ Quality and success criteria established
- ☐ Communication plan and reporting schedule agreed
- ☐ Risk mitigation and contingency plans reviewed

---

**Document Control**:
- **Created By**: _______________ **Date**: _______
- **Reviewed By**: _______________ **Date**: _______  
- **Approved By**: _______________ **Date**: _______
- **Next Review**: _______
