# Penetration Test Planning Template

## Executive Summary

### Assessment Objective
- **Primary Goal**: [Define the primary security objective]
- **Business Driver**: [Compliance requirement, security validation, incident response]
- **Success Criteria**: [Measurable outcomes and deliverables]
- **Assessment Type**: [External, Internal, Web Application, Wireless, Social Engineering, Physical]

### Key Stakeholders
- **Executive Sponsor**: [Name, Title, Contact]
- **Technical Lead**: [Name, Title, Contact]
- **Business Owner**: [Name, Title, Contact]
- **IT Security Team**: [Names, Contacts]
- **External Vendor**: [Company, Lead Consultant, Contact]

## 1. Pre-Engagement Planning

### 1.1 Scope Definition

#### In-Scope Assets
| Asset Type | Details | IP Ranges/URLs | Business Impact |
|------------|---------|----------------|-----------------|
| Web Applications | [Application names] | [URLs/IPs] | [High/Medium/Low] |
| Network Infrastructure | [Subnets, VLANs] | [IP ranges] | [High/Medium/Low] |
| Wireless Networks | [SSID names] | [Frequency bands] | [High/Medium/Low] |
| Cloud Infrastructure | [Azure resources] | [Subscriptions/RGs] | [High/Medium/Low] |
| Mobile Applications | [App names] | [Platforms] | [High/Medium/Low] |

#### Out-of-Scope Assets
- [List explicitly excluded systems]
- [Third-party managed services]
- [Production databases with PII]
- [Critical business systems during business hours]

### 1.2 Rules of Engagement (RoE)

#### Testing Windows
- **Primary Window**: [Day/Time in local timezone]
- **Emergency Contact**: [24/7 contact information]
- **Blackout Periods**: [Business-critical periods to avoid]
- **Maximum Impact**: [DoS testing limitations]

#### Testing Methodology
- **Approach**: [Black Box / Gray Box / White Box]
- **Standards Alignment**: PTES, OWASP Testing Guide v4.0, NIST SP 800-115
- **Automated Tools**: [Approved scanning tools]
- **Manual Testing**: [Custom exploitation techniques]

#### Legal and Compliance
- **Authorization**: [Signed authorization letter required]
- **Data Handling**: [Classification and retention policies]
- **Regulatory Requirements**: [PCI-DSS, HIPAA, SOX, GDPR considerations]
- **Insurance Coverage**: [Professional liability requirements]

### 1.3 Communication Plan

#### Reporting Structure
- **Daily Briefings**: [Who, When, Format]
- **Critical Finding Notification**: [Escalation path within 4 hours]
- **Weekly Status Reports**: [Stakeholder distribution]
- **Final Report Delivery**: [Timeline and format]

#### Emergency Procedures
- **System Outage**: [Immediate notification process]
- **Data Exposure**: [Incident response activation]
- **Legal Issues**: [Legal counsel engagement]

## 2. Intelligence Gathering Phase

### 2.1 Reconnaissance Activities

#### Passive Information Gathering
- **OSINT Sources**: 
  - Public records and databases
  - Social media reconnaissance
  - DNS enumeration and subdomain discovery
  - Search engine intelligence gathering
  - Public code repositories (GitHub, GitLab)
  - Certificate transparency logs
  - Cached content analysis

#### Active Information Gathering
- **Network Discovery**:
  - Port scanning and service enumeration
  - Banner grabbing and version identification
  - Network topology mapping
  - SSL/TLS certificate analysis
  - DNS zone transfers and brute forcing

#### Azure-Specific Reconnaissance
- **Azure AD Enumeration**:
  - Tenant discovery via login.microsoftonline.com
  - User enumeration through various Azure services
  - Application and service principal discovery
  - OAuth configuration analysis
- **Azure Resource Discovery**:
  - Storage account enumeration
  - Web app and function app discovery
  - Public blob container identification
  - Azure SQL database exposure assessment

### 2.2 Threat Intelligence Integration
- **Known Attack Patterns**: [Industry-specific threats]
- **Vulnerability Databases**: [CVE, NVD, vendor advisories]
- **Threat Actor TTPs**: [APT groups, cybercriminal methods]

## 3. Vulnerability Assessment Phase

### 3.1 Automated Scanning

#### Network Vulnerability Scanning
- **Tools**: Nessus, Qualys, OpenVAS, Rapid7
- **Scan Types**: 
  - Credentialed vs. Non-credentialed
  - Internal vs. External perspectives
  - Service-specific scans (Web, DB, Mail)

#### Web Application Scanning
- **Tools**: Burp Suite Professional, OWASP ZAP, Acunetix
- **Coverage Areas**:
  - OWASP Top 10 vulnerabilities
  - Business logic flaws
  - Authentication and session management
  - API security assessment

#### Cloud Security Scanning
- **Azure Security Tools**:
  - Azure Security Center/Defender assessment
  - ScoutSuite for multi-cloud assessment
  - Prowler for Azure CIS benchmark
  - Custom PowerShell/CLI scripts for misconfigurations

### 3.2 Manual Vulnerability Validation
- **False Positive Elimination**: [Manual verification process]
- **Business Logic Testing**: [Application-specific vulnerabilities]
- **Configuration Review**: [Security hardening assessment]

## 4. Exploitation Phase

### 4.1 Exploitation Strategy

#### Risk-Based Approach
- **Critical Vulnerabilities**: Immediate exploitation with client notification
- **High-Risk Findings**: Controlled exploitation with evidence collection
- **Medium/Low Risk**: Proof-of-concept development

#### Azure Cloud Exploitation
- **Identity and Access**:
  - Azure AD privilege escalation
  - Service principal abuse
  - Managed identity exploitation
- **Resource Exploitation**:
  - Storage account access
  - VM privilege escalation
  - Container escape techniques
  - Serverless function abuse

### 4.2 Post-Exploitation Activities
- **Data Access Validation**: [Sensitive data identification]
- **Lateral Movement**: [Network traversal techniques]
- **Persistence Mechanisms**: [Maintaining access methods]
- **Evidence Collection**: [Screenshot, logs, data samples]

### 4.3 Social Engineering Testing
- **Phishing Campaigns**: [Email-based attacks]
- **Vishing/SMSishing**: [Phone and SMS attacks]
- **Physical Security**: [Badge cloning, tailgating]
- **USB Drop Tests**: [Malware delivery testing]

## 5. Risk Assessment and Analysis

### 5.1 Risk Scoring Methodology

#### CVSS v3.1 Scoring
| Risk Level | CVSS Score | Business Impact | Remediation Priority |
|------------|------------|-----------------|---------------------|
| Critical | 9.0-10.0 | Immediate business disruption | Emergency (24-48 hours) |
| High | 7.0-8.9 | Significant business impact | Urgent (1-2 weeks) |
| Medium | 4.0-6.9 | Moderate business impact | Standard (1-3 months) |
| Low | 0.1-3.9 | Minimal business impact | Routine (3-6 months) |

#### Business Risk Factors
- **Data Classification**: [Public, Internal, Confidential, Restricted]
- **System Criticality**: [Mission-critical, Important, Standard]
- **Regulatory Impact**: [Compliance violation penalties]
- **Reputation Risk**: [Public exposure potential]

### 5.2 Attack Path Analysis
- **Kill Chain Mapping**: [Mitre ATT&CK framework alignment]
- **Attack Tree Construction**: [Multi-step exploitation paths]
- **Choke Point Identification**: [Critical control failures]

## 6. Testing Methodologies

### 6.1 Black Box Testing
- **External Perspective**: No internal knowledge provided
- **Attack Simulation**: Real-world attacker approach
- **Time Investment**: Extended reconnaissance phase
- **Discovery Focus**: Public attack surface enumeration

### 6.2 Gray Box Testing
- **Limited Knowledge**: Network diagrams, basic architecture
- **Balanced Approach**: Combines external and insider perspectives
- **Efficiency Gains**: Reduced reconnaissance time
- **Targeted Testing**: Focus on specific vulnerabilities

### 6.3 White Box Testing
- **Complete Knowledge**: Source code, configurations, credentials
- **Comprehensive Coverage**: Maximum vulnerability identification
- **Code Review**: Static and dynamic analysis
- **Architecture Assessment**: Design-level security flaws

## 7. Specialized Testing Areas

### 7.1 API Security Testing
- **REST/GraphQL APIs**: Authentication, authorization, input validation
- **API Gateway Security**: Rate limiting, authentication bypass
- **Microservices Communication**: Inter-service authentication
- **API Documentation Review**: Swagger/OpenAPI analysis

### 7.2 Container Security Testing
- **Docker/AKS Security**: Container escape, privilege escalation
- **Image Vulnerability Scanning**: Base image and dependency analysis
- **Runtime Security**: Behavioral monitoring and anomaly detection
- **Secrets Management**: Hardcoded credentials, secret exposure

### 7.3 Serverless Security Testing
- **Azure Functions**: Function-as-a-Service security assessment
- **Event-driven Vulnerabilities**: Trigger manipulation, resource exhaustion
- **Cold Start Exploitation**: Initialization phase vulnerabilities
- **Third-party Integrations**: External service dependencies

## 8. Evidence Collection and Documentation

### 8.1 Evidence Standards
- **Screenshots**: Timestamped with system information
- **Log Files**: Relevant entries with context
- **Network Captures**: Packet analysis for proof
- **Code Samples**: Exploit code and payloads
- **Video Recordings**: Complex exploitation chains

### 8.2 Chain of Custody
- **Evidence Tracking**: Unique identifiers and timestamps
- **Storage Security**: Encrypted evidence repositories
- **Access Controls**: Limited access with audit logging
- **Retention Policy**: Evidence lifecycle management

## 9. Quality Assurance

### 9.1 Peer Review Process
- **Technical Review**: Senior consultant validation
- **Methodology Compliance**: PTES standard adherence
- **Evidence Verification**: Independent validation
- **Report Quality**: Grammar, clarity, technical accuracy

### 9.2 Client Validation
- **Finding Confirmation**: Client-side verification
- **False Positive Discussion**: Disputed findings resolution
- **Impact Assessment**: Business impact validation
- **Remediation Feasibility**: Implementation practicality

## 10. Deliverables and Timeline

### 10.1 Report Structure
1. **Executive Summary**: Business-focused findings
2. **Technical Findings**: Detailed vulnerability analysis
3. **Risk Assessment**: Prioritized remediation roadmap
4. **Appendices**: Technical evidence and references

### 10.2 Delivery Timeline
- **Daily Status Updates**: Progress communication
- **Critical Finding Alerts**: Immediate notification (4-hour SLA)
- **Draft Report**: [Timeline from test completion]
- **Final Report**: [Timeline after client feedback]
- **Remediation Validation**: [Follow-up testing schedule]

## 11. Post-Assessment Activities

### 11.1 Remediation Support
- **Findings Clarification**: Technical discussion sessions
- **Remediation Guidance**: Implementation recommendations
- **Retest Coordination**: Validation testing scheduling
- **Progress Tracking**: Remediation milestone monitoring

### 11.2 Lessons Learned
- **Methodology Improvements**: Process enhancement opportunities
- **Tool Effectiveness**: Technology stack optimization
- **Client Feedback**: Service delivery improvements
- **Knowledge Transfer**: Internal capability building

## Template Completion Checklist

- [ ] Scope definition completed and approved
- [ ] Rules of engagement signed by all parties
- [ ] Legal authorization obtained
- [ ] Technical team briefed and prepared
- [ ] Testing tools configured and validated
- [ ] Communication plan activated
- [ ] Emergency procedures documented
- [ ] Evidence collection procedures established
- [ ] Quality assurance process defined
- [ ] Deliverable timeline communicated

## Risk and Compliance Considerations

### Legal Requirements
- **Computer Fraud and Abuse Act (CFAA)**: U.S. federal law compliance
- **GDPR Article 32**: EU data protection regulation
- **Industry Standards**: PCI-DSS, HIPAA, SOX requirements
- **International Laws**: Cross-border testing considerations

### Insurance and Liability
- **Professional Liability**: Minimum coverage requirements
- **Cyber Liability**: Data breach protection
- **Errors and Omissions**: Testing mistake coverage
- **Indemnification**: Mutual protection clauses

---

**Document Control**
- **Version**: 1.0
- **Last Updated**: [Date]
- **Next Review**: [Date]
- **Owner**: [Security Team]
- **Approval**: [CISO Signature]