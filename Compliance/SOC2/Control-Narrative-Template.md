# SOC 2 Control Narrative Template - Type II Examination

**Document Control Information**
- **Template Version**: 2.0
- **Effective Date**: [INSERT DATE]
- **Last Updated**: [INSERT DATE]
- **Document Owner**: [CONTROL OWNER NAME]
- **Review Cycle**: Annual
- **Approved By**: [APPROVER NAME AND TITLE]

---

## 1. Control Identification

### 1.1 Control Reference
- **Control ID**: [UNIQUE CONTROL IDENTIFIER]
- **Control Family**: [e.g., CC1, CC2, CC3, CC4, CC5, CC6, CC7, CC8, A1, P1, etc.]
- **Control Classification**: [Entity-Level / System-Level / Complementary User Entity Controls]
- **Control Type**: [Preventive / Detective / Corrective]
- **Automation Level**: [Manual / Semi-Automated / Fully Automated]

### 1.2 Trust Services Criteria Mapping
- **Primary TSC**: [Reference to specific TSC criteria]
- **Secondary TSC**: [Additional applicable criteria]
- **Common Criteria Points of Focus**: [List specific points of focus addressed]
- **Additional Criteria Points of Focus**: [Any availability, confidentiality, processing integrity, or privacy points]

### 1.3 Regulatory and Framework Alignment
- **ISO 27001 Control**: [Corresponding ISO control reference]
- **NIST CSF Function**: [Identify, Protect, Detect, Respond, Recover]
- **CIS Controls**: [Corresponding CIS control number]
- **Azure Security Benchmark**: [Corresponding ASB control]

---

## 2. Control Objective and Risk Context

### 2.1 Control Objective Statement
**Primary Objective**: [Clear, measurable statement of what the control achieves]

**Specific Objectives**:
- [Specific objective 1]
- [Specific objective 2]
- [Specific objective 3]

### 2.2 Risk Context
**Inherent Risk**: [Description of risk if control doesn't exist]
- **Risk Category**: [Operational / Financial / Compliance / Reputational / Strategic]
- **Risk Rating**: [Critical / High / Medium / Low]
- **Impact Assessment**: [Quantitative and qualitative impact description]
- **Likelihood Assessment**: [Probability of risk occurrence without controls]

**Residual Risk**: [Risk remaining after control implementation]
- **Residual Risk Rating**: [Critical / High / Medium / Low]
- **Risk Tolerance**: [Acceptable level of residual risk]

### 2.3 Business Process Context
**Business Process**: [Name of business process this control supports]
**Process Owner**: [Role/title responsible for the business process]
**Sub-processes Affected**: [List of affected sub-processes]
**Stakeholders**: [Internal and external parties affected]

---

## 3. Detailed Control Description

### 3.1 Control Design Description
**Control Activities Overview**: [High-level description of what the control does]

**Detailed Control Activities**:
1. **Activity 1**: [Specific action taken]
   - **Performed By**: [Role/system]
   - **Method**: [How it's performed]
   - **Inputs**: [What information/data is used]
   - **Outputs**: [What is produced]

2. **Activity 2**: [Specific action taken]
   - **Performed By**: [Role/system]
   - **Method**: [How it's performed]
   - **Inputs**: [What information/data is used]
   - **Outputs**: [What is produced]

[Continue for all control activities]

### 3.2 Azure-Specific Implementation Details

#### 3.2.1 Azure Services Utilized
- **Primary Azure Services**: [List of main Azure services]
- **Supporting Azure Services**: [Additional services that support the control]
- **Integration Points**: [How services interact for control execution]

#### 3.2.2 Azure Security Controls
- **Identity and Access Management**: [Azure AD configurations, RBAC, PIM]
- **Network Security**: [NSGs, ASGs, Azure Firewall, private endpoints]
- **Data Protection**: [Encryption, key management, data classification]
- **Monitoring and Logging**: [Azure Monitor, Log Analytics, Sentinel]
- **Compliance and Governance**: [Azure Policy, Blueprints, Security Center]

#### 3.2.3 Configuration Standards
- **Policy Assignments**: [Relevant Azure Policy assignments]
- **Security Baselines**: [Applied security configuration baselines]
- **Compliance Frameworks**: [Azure Security Benchmark alignment]

### 3.3 Control Execution Flow
```
[Step 1] → [Step 2] → [Step 3] → [Decision Point] → [Action A/B] → [Monitoring] → [Reporting]
```

**Detailed Flow Description**:
1. **Trigger Event**: [What initiates the control]
2. **Execution Steps**: [Sequential steps in control operation]
3. **Decision Points**: [Key decision criteria and approvals]
4. **Exception Handling**: [How exceptions are processed]
5. **Completion Criteria**: [How control completion is determined]

---

## 4. Operating Effectiveness Requirements

### 4.1 Frequency and Timing
- **Control Frequency**: [Continuous / Real-time / Daily / Weekly / Monthly / Quarterly / Annually / Event-driven]
- **Specific Timing**: [Exact timing requirements]
- **Business Hours**: [When control operates]
- **Holiday/Weekend Coverage**: [Coverage during non-business hours]

### 4.2 Performance Standards
- **Service Level Objectives (SLOs)**:
  - **Availability Target**: [e.g., 99.9% uptime]
  - **Response Time**: [Maximum acceptable response time]
  - **Processing Time**: [Time to complete control activity]
  - **Error Rate**: [Maximum acceptable error rate]

### 4.3 Key Performance Indicators (KPIs)
| KPI | Target | Measurement Method | Reporting Frequency |
|-----|--------|--------------------|-------------------|
| [KPI 1] | [Target Value] | [How measured] | [Frequency] |
| [KPI 2] | [Target Value] | [How measured] | [Frequency] |
| [KPI 3] | [Target Value] | [How measured] | [Frequency] |

### 4.4 Monitoring and Alerting
**Automated Monitoring**:
- **Monitoring Tools**: [Azure Monitor, custom dashboards, third-party tools]
- **Metrics Tracked**: [Specific metrics monitored]
- **Alert Thresholds**: [When alerts are triggered]
- **Alert Recipients**: [Who receives alerts]

**Dashboard and Reporting**:
- **Real-time Dashboards**: [Links to monitoring dashboards]
- **Periodic Reports**: [Scheduled reports generated]
- **Trend Analysis**: [How trends are analyzed and reported]

---

## 5. Roles and Responsibilities

### 5.1 RACI Matrix
| Activity | Control Owner | Process Owner | IT Operations | Security Team | Compliance | External Auditor |
|----------|---------------|---------------|---------------|---------------|------------|------------------|
| Control Design | R | A | C | C | I | I |
| Daily Operations | A | R | R | I | I | - |
| Monitoring | I | C | R | A | C | - |
| Exception Handling | A | R | C | C | I | - |
| Reporting | R | C | I | C | A | I |
| Annual Review | R | C | I | C | A | C |

**Legend**: R = Responsible, A = Accountable, C = Consulted, I = Informed

### 5.2 Detailed Role Descriptions
**Control Owner**: [Detailed responsibilities and qualifications]
**Process Owner**: [Detailed responsibilities and qualifications]
**IT Operations**: [Detailed responsibilities and qualifications]
**Security Team**: [Detailed responsibilities and qualifications]

### 5.3 Segregation of Duties
- **Conflicting Responsibilities**: [Activities that must be separated]
- **Independence Requirements**: [Roles that must remain independent]
- **Review and Approval Chains**: [Multi-level approval requirements]

---

## 6. Evidence and Documentation

### 6.1 Evidence Types and Sources
**Automated Evidence**:
- **System Logs**: [Types of logs generated]
  - **Location**: [Where logs are stored]
  - **Retention Period**: [How long logs are kept]
  - **Format**: [Log format and structure]
  
**Manual Evidence**:
- **Forms and Checklists**: [Manual documentation created]
- **Approvals**: [Required approvals and sign-offs]
- **Reviews**: [Periodic review documentation]

**Third-Party Evidence**:
- **External Reports**: [Reports from service providers]
- **Certifications**: [Relevant third-party certifications]
- **Attestations**: [External attestations received]

### 6.2 Evidence Storage and Retrieval
**Storage Locations**:
- **Primary Repository**: [Main evidence storage location]
- **Backup Repository**: [Secondary storage location]
- **Cloud Storage**: [Azure storage accounts, security configurations]

**Access Controls**:
- **Read Access**: [Roles with read access to evidence]
- **Write Access**: [Roles with modification rights]
- **Administrative Access**: [Roles with full administrative rights]

**Retention and Disposal**:
- **Retention Period**: [How long evidence is retained]
- **Disposal Procedures**: [How evidence is securely disposed]
- **Legal Hold Procedures**: [How evidence is preserved for legal purposes]

### 6.3 Evidence Integrity and Authentication
- **Digital Signatures**: [Use of digital signatures for evidence]
- **Audit Trails**: [How changes to evidence are tracked]
- **Version Control**: [How evidence versions are managed]
- **Integrity Monitoring**: [How evidence integrity is verified]

---

## 7. Testing and Validation Procedures

### 7.1 Design Testing Procedures
**Test Objectives**: [What design aspects are being tested]

**Test Steps**:
1. **Step 1**: [Detailed test procedure]
   - **Expected Result**: [What should happen]
   - **Pass Criteria**: [How to determine if test passed]
   
2. **Step 2**: [Detailed test procedure]
   - **Expected Result**: [What should happen]
   - **Pass Criteria**: [How to determine if test passed]

**Documentation Review**:
- **Policies and Procedures**: [Documents to review]
- **System Configurations**: [Configurations to validate]
- **Role Definitions**: [Role assignments to verify]

### 7.2 Operating Effectiveness Testing Procedures
**Test Period**: [Specific period being tested]
**Population Definition**: [What constitutes the testing population]

**Sampling Methodology**:
- **Sample Size**: [Number of items to test]
- **Selection Method**: [Random, systematic, judgmental]
- **Sample Justification**: [Why this sample size is appropriate]

**Test Procedures**:
1. **Procedure 1**: [Detailed operating effectiveness test]
   - **Sample Selection**: [How samples are selected]
   - **Testing Steps**: [Step-by-step test procedures]
   - **Expected Results**: [What constitutes proper operation]
   - **Exception Criteria**: [What constitutes an exception]

### 7.3 Continuous Monitoring and Testing
**Real-time Monitoring**: [How control is monitored continuously]
**Automated Testing**: [Automated tests that run regularly]
**Self-Assessment Procedures**: [How management tests the control]

---

## 8. Exception Management

### 8.1 Exception Identification and Classification
**Exception Types**:
- **System Exceptions**: [Technical failures or malfunctions]
- **Process Exceptions**: [Deviations from standard procedures]
- **Compliance Exceptions**: [Regulatory or policy violations]
- **Performance Exceptions**: [Failure to meet SLOs or KPIs]

**Exception Severity Levels**:
- **Critical**: [Immediate threat to control objectives]
- **High**: [Significant impact on control effectiveness]
- **Medium**: [Moderate impact, requires attention]
- **Low**: [Minor impact, monitoring required]

### 8.2 Exception Response Procedures
**Immediate Response** (within [X] hours):
- **Assessment**: [How exceptions are initially assessed]
- **Containment**: [Steps to contain the exception]
- **Notification**: [Who is notified and how]

**Investigation and Resolution** (within [X] business days):
- **Root Cause Analysis**: [How root causes are determined]
- **Corrective Actions**: [Steps to fix the issue]
- **Preventive Measures**: [Steps to prevent recurrence]

### 8.3 Compensating Controls
**When Compensating Controls Apply**: [Circumstances requiring compensating controls]

**Available Compensating Controls**:
1. **Compensating Control 1**: [Description and implementation]
2. **Compensating Control 2**: [Description and implementation]

**Effectiveness Assessment**: [How compensating controls are evaluated]

---

## 9. Management Review and Oversight

### 9.1 Periodic Review Requirements
**Review Frequency**: [How often control is reviewed]
**Review Participants**: [Roles involved in reviews]
**Review Scope**: [What aspects are reviewed]

**Review Criteria**:
- **Control Design Adequacy**: [Assessment of control design]
- **Operating Effectiveness**: [Assessment of control operation]
- **Efficiency**: [Assessment of control efficiency]
- **Risk Coverage**: [Assessment of risk mitigation]

### 9.2 Management Reporting
**Reporting Hierarchy**: [Management levels receiving reports]
**Report Content**: [What information is reported]
**Reporting Schedule**: [When reports are generated and distributed]

**Escalation Procedures**:
- **Level 1**: [Initial escalation criteria and recipients]
- **Level 2**: [Secondary escalation criteria and recipients]
- **Level 3**: [Executive escalation criteria and recipients]

### 9.3 Continuous Improvement
**Performance Metrics Analysis**: [How performance data is analyzed]
**Benchmark Comparisons**: [How control performance is benchmarked]
**Enhancement Opportunities**: [Process for identifying improvements]
**Change Implementation**: [How changes are implemented and tested]

---

## 10. Change Management and Control Updates

### 10.1 Change Control Process
**Change Request Procedures**: [How changes are requested and approved]
**Impact Assessment**: [How change impacts are evaluated]
**Testing Requirements**: [How changes are tested before implementation]
**Rollback Procedures**: [How changes are reversed if needed]

### 10.2 Version Control and Documentation
**Version Numbering**: [How control versions are numbered]
**Change Documentation**: [What changes are documented and how]
**Historical Records**: [How historical versions are maintained]

### 10.3 Communication and Training
**Stakeholder Communication**: [How changes are communicated]
**Training Requirements**: [Training needed for control changes]
**Knowledge Transfer**: [How knowledge is transferred for changes]

---

## 11. Third-Party Service Provider Considerations

### 11.1 Service Provider Assessment
**Due Diligence Requirements**: [Evaluation criteria for service providers]
**Certification Requirements**: [Required certifications (SOC 2, ISO 27001, etc.)]
**Control Reliance**: [Controls being relied upon from service providers]

### 11.2 Ongoing Monitoring
**Monitoring Procedures**: [How service provider controls are monitored]
**Report Review**: [How service provider reports are reviewed]
**Performance Metrics**: [KPIs for service provider performance]

### 11.3 Contract and SLA Management
**Contract Requirements**: [Control-related contract provisions]
**Service Level Agreements**: [Relevant SLAs with service providers]
**Right to Audit**: [Audit rights and procedures]

---

## 12. Risk Assessment and Control Effectiveness Evaluation

### 12.1 Risk Assessment Methodology
**Risk Identification**: [How risks to the control are identified]
**Risk Analysis**: [How risks are analyzed and evaluated]
**Risk Treatment**: [How identified risks are addressed]

### 12.2 Control Effectiveness Metrics
**Quantitative Metrics**:
- **Control Reliability**: [Percentage of successful control executions]
- **Error Rate**: [Percentage of control failures or errors]
- **Recovery Time**: [Time to restore control after failure]

**Qualitative Metrics**:
- **Control Maturity**: [Assessment of control sophistication]
- **Staff Competency**: [Assessment of personnel performing control]
- **Technology Effectiveness**: [Assessment of supporting technology]

### 12.3 Effectiveness Evaluation Process
**Evaluation Frequency**: [How often effectiveness is evaluated]
**Evaluation Criteria**: [Standards used to assess effectiveness]
**Improvement Actions**: [Actions taken based on evaluations]

---

## 13. Integration with Monitoring and Logging Systems

### 13.1 Azure Monitor Integration
**Log Analytics Workspace**: [Workspace configuration and data sources]
**Custom Metrics**: [Control-specific metrics collected]
**Alerting Rules**: [Azure Monitor alerts configured]
**Dashboard Configuration**: [Azure Monitor dashboards created]

### 13.2 Azure Sentinel Integration
**Data Connectors**: [Sentinel connectors configured for control]
**Analytics Rules**: [Sentinel rules monitoring control effectiveness]
**Playbooks**: [Automated response playbooks for control exceptions]
**Workbooks**: [Sentinel workbooks for control monitoring]

### 13.3 Third-Party Tool Integration
**SIEM Integration**: [Integration with security information and event management]
**GRC Platform Integration**: [Integration with governance, risk, and compliance tools]
**Ticketing System Integration**: [Integration with incident management systems]

---

## 14. Compliance and Audit Considerations

### 14.1 Audit Preparation
**Evidence Compilation**: [Process for preparing audit evidence]
**Documentation Review**: [Review of control documentation before audit]
**Personnel Preparation**: [Preparation of staff for audit interviews]

### 14.2 Audit Testing Support
**Sample Provision**: [How audit samples are provided]
**System Access**: [Providing auditors with necessary system access]
**Subject Matter Experts**: [Availability of SMEs during audit]

### 14.3 Audit Response and Remediation
**Finding Response**: [Process for responding to audit findings]
**Remediation Planning**: [How remediation plans are developed]
**Follow-up Procedures**: [How remediation progress is tracked]

---

## 15. Appendices

### Appendix A: Control Testing Worksheets
[Detailed testing worksheets for auditors and assessors]

### Appendix B: Evidence Collection Templates
[Templates for collecting and organizing control evidence]

### Appendix C: Risk Assessment Matrices
[Risk assessment templates and scoring methodologies]

### Appendix D: Azure Service Configuration Standards
[Detailed Azure configuration requirements supporting the control]

### Appendix E: Flowcharts and Process Diagrams
[Visual representations of control processes and workflows]

### Appendix F: Forms and Checklists
[Standard forms and checklists used in control execution]

---

**Document Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Control Owner | [Name] | [Signature] | [Date] |
| Process Owner | [Name] | [Signature] | [Date] |
| Compliance Manager | [Name] | [Signature] | [Date] |
| Chief Information Security Officer | [Name] | [Signature] | [Date] |

---

**Revision History**

| Version | Date | Author | Description of Changes |
|---------|------|--------|----------------------|
| 1.0 | [Date] | [Author] | Initial template creation |
| 2.0 | [Date] | [Author] | Enhanced for SOC 2 Type II compliance |

---

**Template Usage Instructions**

1. **Customization**: Replace all bracketed placeholders with environment-specific information
2. **Section Adaptation**: Modify sections based on control complexity and organizational needs
3. **Evidence Alignment**: Ensure evidence requirements align with Trust Services Criteria
4. **Review Cycle**: Establish regular review cycles to maintain template currency
5. **Training**: Provide training to control owners on template usage and completion requirements
