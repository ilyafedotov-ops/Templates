# Comprehensive Azure Security Assessment Questionnaire

**Instructions**: This comprehensive questionnaire drives discovery interviews and evidence collection for Azure security assessments. Answer all applicable questions with specific details and link to supporting artifacts. Use ratings: Not Applicable (N/A), Not Implemented (0), Basic (1), Intermediate (2), Advanced (3), Optimized (4).

## Section 1: Governance & Risk Management (15 questions)

### Information Security Management System (ISMS)
1. **ISMS Framework**: Do you maintain a formal Information Security Management System? Which framework (ISO 27001, NIST, custom)? What is the defined scope and boundaries?
   - Evidence: ISMS policy, scope statement, security organization chart
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

2. **Risk Management Process**: Describe your risk assessment methodology. When was the last comprehensive risk assessment conducted? How often are risk assessments updated?
   - Evidence: Risk management policy, recent risk assessment reports, risk register
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

3. **Risk Treatment Plans**: How are identified risks treated? Do you maintain formal risk treatment plans with assigned owners and timelines?
   - Evidence: Risk treatment plans, risk acceptance forms, mitigation tracking
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

4. **Business Impact Analysis**: Have you conducted a Business Impact Analysis (BIA)? How do you prioritize systems and data based on business criticality?
   - Evidence: BIA documents, system criticality matrix, RPO/RTO definitions
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

5. **Security Governance**: What is your security governance structure? Who is accountable for cloud security decisions? How are security policies approved and communicated?
   - Evidence: Security charter, governance committee minutes, policy approval workflow
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Change Management & Controls
6. **Change Management Process**: Describe your change management process. Do you have a Change Advisory Board (CAB)? How are emergency changes handled and documented?
   - Evidence: Change management policy, CAB charter, emergency change procedures
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

7. **Configuration Management**: How do you manage configuration baselines? Do you have automated configuration drift detection? How are unauthorized changes detected and remediated?
   - Evidence: Configuration management database, baseline documents, drift detection reports
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

8. **Asset Management**: Do you maintain a comprehensive inventory of cloud assets? How are asset owners identified and accountable for security? What is your asset lifecycle management process?
   - Evidence: Asset inventory, asset ownership matrix, lifecycle procedures
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Security Policies & Procedures
9. **Security Policy Framework**: What security policies are in place? How often are they reviewed and updated? Who approves policy changes?
   - Evidence: Security policy suite, policy review schedule, approval records
   - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

10. **Compliance Management**: What regulatory requirements apply to your organization? How do you track and demonstrate compliance? When was your last external audit?
    - Evidence: Compliance matrix, audit reports, remediation plans
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

11. **Third-Party Risk Management**: How do you assess and manage third-party security risks? Do you have vendor security requirements and ongoing monitoring?
    - Evidence: Vendor risk assessments, security requirements, monitoring reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

12. **Security Awareness Training**: What security awareness training programs are in place? How do you measure training effectiveness? What is the training completion rate?
    - Evidence: Training curriculum, completion reports, phishing test results
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

13. **Incident Response Governance**: Do you have a formal incident response plan? Who leads incident response? How are lessons learned captured and implemented?
    - Evidence: Incident response plan, team structure, post-incident reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

14. **Security Metrics & KPIs**: What security metrics do you track? How do you measure security program effectiveness? Do you have security dashboards for leadership?
    - Evidence: Security metrics framework, KPI reports, executive dashboards
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

15. **Budget & Resource Management**: What is your security budget allocation? How do you justify security investments? Do you have adequate security staffing?
    - Evidence: Security budget, ROI analysis, staffing assessments
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 2: Identity & Access Management (25 questions)

### Azure Active Directory Configuration
16. **Azure AD Tenant Architecture**: How many Azure AD tenants do you have? What is your tenant strategy (single/multi-tenant)? How do you manage tenant-to-tenant trust relationships?
    - Evidence: Tenant architecture diagram, trust configuration, B2B policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

17. **Multi-Factor Authentication (MFA)**: Is MFA enforced for all users? What MFA methods are supported? Are there any MFA exemptions, and how are they justified?
    - Evidence: MFA policies, method configuration, exemption documentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

18. **Conditional Access Policies**: What Conditional Access policies are implemented? How do you test policy effectiveness? Do you have break-glass account procedures?
    - Evidence: CA policy export, test results, break-glass documentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

19. **Privileged Identity Management (PIM)**: Is PIM enabled for privileged roles? What approval and notification workflows are configured? How do you audit privileged access activations?
    - Evidence: PIM configuration, approval workflows, activation reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

20. **Identity Protection**: Is Azure AD Identity Protection enabled? How do you respond to risk detections? What automated remediation actions are configured?
    - Evidence: Identity Protection policies, risk reports, remediation workflows
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Access Management & Controls
21. **Role-Based Access Control (RBAC)**: What is your RBAC strategy for Azure subscriptions and resources? How do you implement least privilege? Do you use custom roles?
    - Evidence: RBAC matrix, custom role definitions, access review reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

22. **Access Reviews**: Are periodic access reviews conducted? What is the review frequency for different access types? How are review results remediated?
    - Evidence: Access review configuration, completion reports, remediation actions
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

23. **Service Principal Management**: How do you manage service principals and application registrations? Are service principal credentials rotated regularly? Do you use managed identities?
    - Evidence: Service principal inventory, credential rotation policies, managed identity usage
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

24. **Guest User Management**: How do you manage external/guest user access? What approval processes are in place? How do you monitor guest user activities?
    - Evidence: Guest user policies, approval workflows, activity monitoring
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

25. **Administrative Account Security**: How are administrative accounts protected? Do you have dedicated admin accounts? Are administrative activities logged and monitored?
    - Evidence: Admin account policies, privileged access workstations, activity logs
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Identity Federation & Integration
26. **Hybrid Identity**: Do you have on-premises identity integration (Azure AD Connect)? How is identity synchronization secured? Are there password synchronization or passthrough authentication configurations?
    - Evidence: Azure AD Connect configuration, security settings, sync reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

27. **Single Sign-On (SSO)**: What applications are integrated with Azure AD SSO? How do you manage application permissions? Are there any applications using legacy authentication?
    - Evidence: App registration list, permission analysis, legacy app inventory
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

28. **API Access Management**: How do you secure API access to Azure resources? Are managed identities used consistently? How do you manage API keys and certificates?
    - Evidence: API authentication configuration, managed identity usage, key management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

29. **Identity Governance**: Do you have identity lifecycle management processes? How are user accounts provisioned and deprovisioned? Is there automated account cleanup?
    - Evidence: Lifecycle procedures, provisioning workflows, cleanup automation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

30. **Authentication Protocols**: What authentication protocols are supported? Are legacy protocols (basic auth, NTLM) disabled? Do you enforce modern authentication?
    - Evidence: Protocol configuration, legacy auth reports, enforcement policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Secrets & Certificate Management
31. **Azure Key Vault Implementation**: How many Key Vaults do you have? What is your Key Vault architecture and access model? Are Key Vaults in different regions?
    - Evidence: Key Vault inventory, architecture diagram, access policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

32. **Key Management**: Do you use customer-managed keys (CMK)? What is your key rotation strategy? How are keys backed up and recovered?
    - Evidence: CMK configuration, rotation policies, backup procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

33. **Certificate Management**: How are SSL/TLS certificates managed? Do you have automated certificate renewal? How do you monitor certificate expiration?
    - Evidence: Certificate inventory, renewal automation, monitoring alerts
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

34. **Secrets Management**: How are application secrets managed? Do applications use Key Vault references? Are secrets rotated regularly?
    - Evidence: Secret management policies, Key Vault integration, rotation schedules
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

35. **Hardware Security Modules (HSM)**: Do you use Azure Dedicated HSM or Managed HSM? What types of keys are stored in HSMs? How is HSM access controlled?
    - Evidence: HSM configuration, key types, access controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Identity Security Monitoring
36. **Sign-in Monitoring**: How do you monitor user sign-in activities? Are there alerts for suspicious sign-ins? How do you investigate identity-related incidents?
    - Evidence: Sign-in reports, alerting configuration, incident procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

37. **Privileged Access Monitoring**: How do you monitor privileged access activities? Are PIM activations logged and reviewed? What are your privileged access baselines?
    - Evidence: Privileged access logs, PIM reports, baseline documentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

38. **Identity Risk Assessment**: How do you assess identity-related risks? Do you have identity risk scoring? How are high-risk identities managed?
    - Evidence: Identity risk framework, risk scores, high-risk procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

39. **Access Analytics**: Do you perform access analytics to identify over-privileged accounts? How do you detect dormant accounts? What access certification processes are in place?
    - Evidence: Access analytics reports, dormant account cleanup, certification processes
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

40. **Identity Incident Response**: How do you respond to identity compromise incidents? What is your account lockout and recovery process? Do you have automated response capabilities?
    - Evidence: Identity incident procedures, lockout policies, automation workflows
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 3: Network Security Architecture (20 questions)

### Network Design & Segmentation
41. **Azure Landing Zone Architecture**: What Azure landing zone architecture do you use (CAF, custom)? How many management groups and subscriptions are in scope? What is your naming convention?
    - Evidence: Landing zone diagram, management group structure, naming standards
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

42. **Hub-Spoke Topology**: Do you implement hub-spoke network topology? What services are deployed in the hub? How is connectivity between spokes controlled?
    - Evidence: Network topology diagram, hub services, spoke connectivity rules
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

43. **Network Segmentation**: How do you implement network segmentation? Are there dedicated subnets for different tiers (web, app, data)? How is east-west traffic controlled?
    - Evidence: Subnet design, segmentation strategy, traffic flow diagrams
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

44. **Zero Trust Network**: Do you implement Zero Trust network principles? How do you verify all network traffic? What micro-segmentation strategies are used?
    - Evidence: Zero Trust architecture, traffic verification, micro-segmentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

45. **Software-Defined Perimeter**: Do you use software-defined perimeter solutions? How is dynamic access control implemented? What conditional access policies apply to network access?
    - Evidence: SDP implementation, dynamic access controls, network CA policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Perimeter Security
46. **Azure Firewall Implementation**: Is Azure Firewall deployed? What firewall rules are configured? How do you manage and audit firewall rules? Do you use Firewall Manager?
    - Evidence: Firewall configuration, rule documentation, audit reports
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

47. **Web Application Firewall (WAF)**: Is WAF deployed for web applications? What WAF rules and policies are configured? How do you handle false positives?
    - Evidence: WAF configuration, custom rules, false positive procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

48. **DDoS Protection**: Is Azure DDoS Protection Standard enabled? For which resources? How do you monitor DDoS attacks? What is your DDoS response plan?
    - Evidence: DDoS configuration, monitoring setup, response procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

49. **Load Balancer Security**: How are load balancers configured for security? Are health probes properly secured? How do you implement load balancer access controls?
    - Evidence: Load balancer configuration, health probe setup, access controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

50. **CDN Security**: Do you use Azure CDN? How is CDN security configured? Are custom domains properly secured with certificates? How do you protect against CDN-based attacks?
    - Evidence: CDN configuration, security settings, certificate management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Private Connectivity
51. **Private Endpoints**: What services use private endpoints? How do you manage private endpoint DNS resolution? Are there any public endpoints that should be private?
    - Evidence: Private endpoint inventory, DNS configuration, public endpoint audit
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

52. **Virtual Network Service Endpoints**: Where are service endpoints used? How do you secure service endpoint traffic? What is your migration plan from service endpoints to private endpoints?
    - Evidence: Service endpoint configuration, security settings, migration plan
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

53. **Private Link Services**: Do you publish services via Private Link? How is access to Private Link services controlled? What monitoring is in place?
    - Evidence: Private Link services, access controls, monitoring configuration
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

54. **ExpressRoute/VPN Security**: How is hybrid connectivity secured? Are there dedicated ExpressRoute circuits? How do you secure VPN connections? What encryption is used?
    - Evidence: Connectivity architecture, encryption settings, security configuration
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

55. **DNS Security**: How is DNS resolution secured? Do you use Azure Private DNS zones? How do you protect against DNS attacks? Is DNS filtering implemented?
    - Evidence: DNS architecture, private zones, security controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Network Access Controls
56. **Network Security Groups (NSGs)**: How are NSGs configured and managed? Do you use Application Security Groups (ASGs)? How do you audit NSG rules for least privilege?
    - Evidence: NSG configuration, ASG usage, rule audit procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

57. **Just-in-Time (JIT) Access**: Is JIT VM access enabled? For which virtual machines? How do you manage JIT access requests and approvals?
    - Evidence: JIT configuration, access requests, approval workflows
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

58. **Azure Bastion**: Is Azure Bastion used for secure remote access? How many Bastion hosts are deployed? What access controls are in place for Bastion?
    - Evidence: Bastion deployment, access controls, usage monitoring
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

59. **Network Monitoring**: What network monitoring tools are deployed? How do you detect network anomalies? Are there automated response capabilities?
    - Evidence: Monitoring tools, anomaly detection, automated responses
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

60. **Network Compliance**: How do you ensure network configurations comply with security policies? Do you have automated compliance checking? How are non-compliant configurations remediated?
    - Evidence: Compliance policies, automated checking, remediation procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 4: Data Protection & Encryption (18 questions)

### Data Classification & Governance
61. **Data Classification Framework**: Do you have a formal data classification scheme? How is sensitive data identified and labeled? What automated data discovery tools are used?
    - Evidence: Classification policies, labeling procedures, discovery tools
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

62. **Data Loss Prevention (DLP)**: Are DLP policies implemented? What channels are monitored (email, cloud, endpoints)? How do you handle DLP violations?
    - Evidence: DLP policies, monitoring coverage, violation procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

63. **Data Residency & Sovereignty**: How do you ensure data residency requirements are met? Are there restrictions on data location? How do you handle cross-border data transfers?
    - Evidence: Residency policies, location restrictions, transfer procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

64. **Personal Data Protection**: How do you handle personal data (GDPR, CCPA)? What processes are in place for data subject rights? How do you track personal data location?
    - Evidence: Privacy policies, rights procedures, data mapping
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

65. **Data Retention & Disposal**: What are your data retention policies? How is data securely disposed of at end-of-life? Are there automated data lifecycle management processes?
    - Evidence: Retention policies, disposal procedures, lifecycle automation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Encryption Implementation
66. **Encryption at Rest**: What data stores use encryption at rest? Do you use customer-managed keys (CMK) or Microsoft-managed keys? How is key rotation managed?
    - Evidence: Encryption inventory, key management, rotation schedules
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

67. **Encryption in Transit**: Is encryption in transit enforced for all data communications? What protocols and ciphers are allowed? Are there any unencrypted channels?
    - Evidence: Transport encryption policies, protocol configuration, channel audit
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

68. **Database Encryption**: How are databases encrypted? Is Transparent Data Encryption (TDE) enabled? Do you use Always Encrypted or Dynamic Data Masking?
    - Evidence: Database encryption status, TDE configuration, advanced encryption features
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

69. **File and Storage Encryption**: How is file storage encrypted? Are Azure Storage accounts encrypted? Do you use client-side encryption for sensitive files?
    - Evidence: Storage encryption configuration, client-side encryption usage
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

70. **Application-Level Encryption**: Do applications implement additional encryption for sensitive fields? How are encryption keys managed at the application level?
    - Evidence: Application encryption, field-level encryption, key management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Backup & Recovery
71. **Backup Strategy**: What backup strategies are implemented? Are backups encrypted? How often are backup restores tested? What is your backup retention policy?
    - Evidence: Backup policies, encryption configuration, test procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

72. **Disaster Recovery**: What are your Recovery Point Objectives (RPO) and Recovery Time Objectives (RTO)? When was your last DR test? Are DR procedures documented and current?
    - Evidence: DR plan, RPO/RTO documentation, test results
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

73. **Business Continuity**: How do you ensure business continuity during outages? What are your failover procedures? Do you have automated failover capabilities?
    - Evidence: Business continuity plan, failover procedures, automation configuration
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

74. **Backup Security**: How are backups protected from ransomware and unauthorized access? Do you use immutable backup storage? How is backup access controlled?
    - Evidence: Backup security measures, immutable storage, access controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

75. **Cross-Region Replication**: Do you replicate data across regions? How is cross-region replication secured? What are your geo-redundancy requirements?
    - Evidence: Replication configuration, security measures, redundancy policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Data Access & Monitoring
76. **Data Access Controls**: How is access to sensitive data controlled? Do you implement attribute-based access control (ABAC)? How are data access permissions regularly reviewed?
    - Evidence: Access control policies, ABAC implementation, review procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

77. **Database Activity Monitoring**: How do you monitor database access and activities? Are there alerts for suspicious data access patterns? What database audit logging is enabled?
    - Evidence: Database monitoring, alert configuration, audit logging
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

78. **Data Exfiltration Prevention**: What controls prevent unauthorized data exfiltration? How do you monitor for large data downloads or transfers? Are there automated blocking capabilities?
    - Evidence: Exfiltration controls, monitoring alerts, automated blocking
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 5: Logging, Monitoring & SIEM (22 questions)

### Centralized Logging
79. **Log Analytics Architecture**: How many Log Analytics workspaces do you have? What is your workspace strategy (centralized vs. distributed)? How do you manage workspace access?
    - Evidence: Workspace architecture, access controls, data flow diagrams
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

80. **Log Collection Coverage**: What Azure services send logs to Log Analytics? Are all critical resources covered? What on-premises logs are collected?
    - Evidence: Data source inventory, diagnostic settings, collection coverage
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

81. **Log Retention Policies**: What are your log retention policies by data type? How do you balance cost vs. compliance requirements? Do you use log archival strategies?
    - Evidence: Retention policies, archival configuration, cost optimization
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

82. **Log Data Quality**: How do you ensure log data quality and completeness? Are there monitoring capabilities for missing logs? How do you handle log parsing failures?
    - Evidence: Data quality monitoring, completeness checks, error handling
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

83. **Log Security**: How are logs protected from tampering? Do you use log immutability features? How is access to logs controlled and audited?
    - Evidence: Log protection measures, immutability configuration, access controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Microsoft Sentinel Implementation
84. **Sentinel Deployment**: Is Microsoft Sentinel deployed? What data connectors are enabled? How do you manage Sentinel costs?
    - Evidence: Sentinel configuration, connector inventory, cost management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

85. **Analytics Rules**: How many analytics rules are deployed? What is your rule development and testing process? How do you handle rule performance and tuning?
    - Evidence: Analytics rules inventory, development process, performance metrics
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

86. **Threat Intelligence**: How do you integrate threat intelligence into Sentinel? What threat intel feeds are used? How do you validate threat intel quality?
    - Evidence: Threat intel integration, feed sources, quality validation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

87. **Incident Management**: What is your incident classification and prioritization process? How are incidents assigned and tracked? What are your mean time to acknowledgment (MTTA) and resolution (MTTR) targets?
    - Evidence: Incident procedures, classification schema, SLA targets
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

88. **Security Orchestration (SOAR)**: Are automated response playbooks deployed? What types of incidents trigger automation? How do you maintain and update playbooks?
    - Evidence: Playbook inventory, trigger configuration, maintenance procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Security Monitoring & Analytics
89. **Security Dashboards**: What security dashboards are available? Who has access to security metrics? How often are dashboards reviewed and updated?
    - Evidence: Dashboard inventory, access controls, review procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

90. **Behavioral Analytics**: Do you use user and entity behavior analytics (UEBA)? How are behavioral baselines established? What anomalies trigger alerts?
    - Evidence: UEBA configuration, baseline procedures, anomaly detection
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

91. **Threat Hunting**: Do you perform proactive threat hunting? What hunting methodologies are used? How often are hunting activities conducted?
    - Evidence: Hunting procedures, methodologies, activity schedule
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

92. **Alert Management**: How do you manage alert fatigue? What is your alert tuning process? How do you handle false positives and false negatives?
    - Evidence: Alert management procedures, tuning process, FP/FN handling
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

93. **Metrics & KPIs**: What security metrics do you track? How do you measure SOC effectiveness? Are there service level agreements for security operations?
    - Evidence: Metrics framework, effectiveness measures, SLA documentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Compliance & Audit Logging
94. **Audit Trail Completeness**: How do you ensure comprehensive audit trails? What activities are logged across all systems? How do you detect audit log gaps?
    - Evidence: Audit logging policies, activity coverage, gap detection
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

95. **Regulatory Compliance Logging**: How do you meet regulatory logging requirements? What logs are required for compliance audits? How do you demonstrate log integrity?
    - Evidence: Compliance logging requirements, audit preparations, integrity measures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

96. **Log Analysis Capabilities**: What tools and techniques are used for log analysis? Do you have automated log correlation? How do you perform forensic analysis?
    - Evidence: Analysis tools, correlation capabilities, forensic procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

97. **Monitoring Coverage Assessment**: How do you assess the effectiveness of your monitoring coverage? Are there regular monitoring gap assessments? How do you validate detection capabilities?
    - Evidence: Coverage assessments, gap analysis, validation testing
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

98. **Integration with External Systems**: How does your logging integrate with external systems (ITSM, GRC, etc.)? What data sharing agreements are in place? How is data integrity maintained in transfers?
    - Evidence: Integration documentation, data sharing agreements, integrity controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

99. **Log Performance & Scalability**: How do you ensure log processing performance at scale? What are your data ingestion limits? How do you handle log volume spikes?
    - Evidence: Performance monitoring, scalability planning, capacity management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

100. **Monitoring Team Structure**: What is your security monitoring team structure? Are there 24/7 operations? How do you handle coverage for holidays and vacations?
    - Evidence: Team structure, coverage model, staffing procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 6: DevSecOps & CI/CD Security (20 questions)

### Source Code Management
101. **Source Code Security**: How is source code protected? What authentication methods are required? Are there branch protection policies in place?
    - Evidence: SCM security settings, authentication configuration, branch policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

102. **Code Review Process**: What code review requirements are enforced? How many reviewers are required? Are there automated code quality gates?
    - Evidence: Review policies, approval requirements, quality gates
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

103. **Secret Management in Code**: How do you prevent secrets in source code? Are there pre-commit hooks for secret detection? What happens when secrets are found?
    - Evidence: Secret detection tools, pre-commit hooks, incident procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

104. **Code Signing**: Are commits digitally signed? How is code integrity verified? What signing keys are used and how are they managed?
    - Evidence: Signing policies, verification procedures, key management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

105. **Open Source Security**: How do you manage open source dependencies? Are there vulnerability scanning processes for dependencies? What is your policy on license compliance?
    - Evidence: Dependency management, vulnerability scanning, license policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### CI/CD Pipeline Security
106. **Pipeline Security Architecture**: How are CI/CD pipelines secured? What authentication is required? Are there network restrictions on pipeline access?
    - Evidence: Pipeline architecture, authentication requirements, network controls
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

107. **Static Application Security Testing (SAST)**: Are SAST tools integrated into pipelines? What languages and frameworks are covered? How are SAST findings triaged?
    - Evidence: SAST tool configuration, coverage analysis, triage procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

108. **Dynamic Application Security Testing (DAST)**: Is DAST performed as part of the pipeline? What types of applications are tested? How are DAST results integrated with other security tools?
    - Evidence: DAST configuration, application coverage, tool integration
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

109. **Infrastructure as Code (IaC) Security**: How is IaC scanned for security issues? What tools are used? Are there custom rules for organizational policies?
    - Evidence: IaC scanning tools, custom rules, policy enforcement
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

110. **Security Gates**: What security gates are implemented in pipelines? At what stages do security checks occur? What happens when security checks fail?
    - Evidence: Security gate configuration, check points, failure procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Container & Artifact Security
111. **Container Image Scanning**: How are container images scanned for vulnerabilities? What registries are used? Are there policies for base image approval?
    - Evidence: Image scanning configuration, registry security, base image policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

112. **Container Runtime Security**: How is container runtime security managed? Are there runtime monitoring tools deployed? What runtime policies are enforced?
    - Evidence: Runtime security tools, monitoring configuration, policy enforcement
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

113. **Image Signing & Verification**: Are container images digitally signed? How is image provenance verified? What happens when unsigned images are detected?
    - Evidence: Image signing process, verification procedures, unsigned image handling
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

114. **Software Bill of Materials (SBOM)**: Are SBOMs generated for applications? What SBOM formats are used? How are SBOMs used for vulnerability management?
    - Evidence: SBOM generation, format standards, vulnerability correlation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

115. **Artifact Repository Security**: How are build artifacts secured? What access controls are in place for artifact repositories? Are artifacts scanned before storage?
    - Evidence: Repository security, access controls, scanning procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Deployment Security
116. **Environment Promotion**: How are applications promoted between environments? What approval processes are required for production deployments? Are there automated security validations?
    - Evidence: Promotion procedures, approval workflows, validation automation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

117. **Zero-Downtime Deployments**: How do you achieve zero-downtime deployments? What rollback procedures are in place? How quickly can you rollback problematic deployments?
    - Evidence: Deployment strategies, rollback procedures, rollback timing
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

118. **Configuration Management**: How are application configurations managed securely? Are configuration changes tracked? How do you prevent configuration drift?
    - Evidence: Configuration management, change tracking, drift prevention
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

119. **Production Security Validation**: What security validations occur post-deployment? Are there automated security tests in production? How do you verify security controls are functioning?
    - Evidence: Post-deployment validation, automated testing, control verification
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

120. **DevSecOps Metrics**: What metrics do you track for DevSecOps effectiveness? How do you measure security integration in the development process? What are your targets for security issue resolution?
    - Evidence: DevSecOps metrics, integration measurements, resolution targets
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 7: Vulnerability & Patch Management (15 questions)

### Vulnerability Assessment
121. **Microsoft Defender for Cloud**: Is Defender for Cloud enabled for all subscriptions? What Defender plans are active? How do you manage Defender recommendations?
    - Evidence: Defender configuration, plan coverage, recommendation management
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

122. **Vulnerability Scanning Coverage**: What assets are covered by vulnerability scanning? How frequently are scans performed? Are there authenticated vs. unauthenticated scans?
    - Evidence: Scanning coverage, scan frequency, authentication methods
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

123. **Third-Party Vulnerability Tools**: Are additional vulnerability scanning tools used beyond Defender? How do you correlate findings from multiple tools? What is your tool consolidation strategy?
    - Evidence: Additional tools, correlation processes, consolidation plans
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

124. **Vulnerability Risk Rating**: How do you prioritize vulnerabilities? Do you use CVSS scores or custom risk ratings? How do business context and asset criticality factor into priority?
    - Evidence: Prioritization methodology, risk rating system, business context integration
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

125. **Vulnerability Management Workflow**: What is your vulnerability remediation workflow? Who is responsible for different types of vulnerabilities? How are remediations tracked and verified?
    - Evidence: Remediation workflow, responsibility matrix, tracking procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Patch Management
126. **Azure Update Management**: Is Azure Update Management used? What systems are managed? How are patch groups organized and scheduled?
    - Evidence: Update Management configuration, system coverage, patch scheduling
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

127. **Patch Testing Process**: How are patches tested before deployment? What test environments are used? How long is the testing cycle for different patch types?
    - Evidence: Patch testing procedures, test environments, testing timelines
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

128. **Emergency Patching**: What is your emergency patching process? How quickly can critical patches be deployed? Who approves emergency patches?
    - Evidence: Emergency procedures, deployment timelines, approval processes
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

129. **Patch Compliance**: How do you measure patch compliance? What are your patch compliance targets? How do you handle systems that cannot be patched?
    - Evidence: Compliance metrics, targets, exception handling
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

130. **Third-Party Software Patching**: How are third-party applications patched? Do you have inventory of all third-party software? What is your process for end-of-life software?
    - Evidence: Third-party patching, software inventory, EOL procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Threat & Exposure Management
131. **Threat Intelligence Integration**: How is threat intelligence integrated into vulnerability management? Do you prioritize based on active threats? What threat feeds are used?
    - Evidence: Threat intel integration, prioritization methods, feed sources
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

132. **Attack Surface Management**: How do you manage your external attack surface? Are there tools for attack surface discovery and monitoring? How often is the attack surface reviewed?
    - Evidence: Attack surface management, discovery tools, review frequency
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

133. **Penetration Testing**: How often do you conduct penetration tests? Are tests performed internally or by external parties? How are findings remediated and retested?
    - Evidence: Penetration testing schedule, testing approach, remediation tracking
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

134. **Red Team Exercises**: Do you conduct red team exercises? What scenarios are tested? How are exercise results used to improve defenses?
    - Evidence: Red team procedures, exercise scenarios, improvement tracking
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

135. **Vulnerability Disclosure**: Do you have a vulnerability disclosure policy? How do you handle external security researchers? What is your response process for disclosed vulnerabilities?
    - Evidence: Disclosure policy, researcher engagement, response procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 8: Incident Response & Forensics (12 questions)

### Incident Response Planning
136. **Incident Response Plan**: Is there a formal incident response plan? When was it last updated? How often are plan updates and reviews conducted?
    - Evidence: IR plan document, update history, review schedule
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

137. **Incident Response Team**: Who comprises your incident response team? What are the roles and responsibilities? Are there backup personnel for each role?
    - Evidence: Team structure, role definitions, backup assignments
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

138. **Incident Classification**: How do you classify security incidents? What criteria determine incident severity? How quickly are incidents escalated?
    - Evidence: Classification schema, severity criteria, escalation procedures
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

139. **Communication Plans**: What are your incident communication procedures? Who needs to be notified for different incident types? How do you manage external communications?
    - Evidence: Communication procedures, notification matrices, external communication plans
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Incident Detection & Analysis
140. **Incident Detection Capabilities**: How are security incidents detected? What detection tools and methods are used? What is your mean time to detection (MTTD)?
    - Evidence: Detection capabilities, tool inventory, MTTD metrics
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

141. **Incident Analysis Process**: What is your incident analysis methodology? How do you determine incident scope and impact? What tools are used for analysis?
    - Evidence: Analysis methodology, scoping procedures, analysis tools
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

142. **Forensic Capabilities**: Do you have digital forensic capabilities? Are there trained forensic investigators? What forensic tools and processes are available?
    - Evidence: Forensic procedures, investigator training, tool inventory
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

143. **Evidence Collection**: How do you collect and preserve digital evidence? Are evidence handling procedures documented? How do you maintain chain of custody?
    - Evidence: Collection procedures, preservation methods, custody documentation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

### Incident Containment & Recovery
144. **Containment Strategies**: What incident containment strategies are available? How quickly can affected systems be isolated? Are there automated containment capabilities?
    - Evidence: Containment procedures, isolation methods, automation capabilities
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

145. **Recovery Procedures**: What are your incident recovery procedures? How do you ensure systems are clean before restoration? What validation steps are performed?
    - Evidence: Recovery procedures, cleaning validation, restoration verification
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

146. **Business Continuity During Incidents**: How do you maintain business operations during security incidents? What backup systems and procedures are available? How do you communicate with stakeholders?
    - Evidence: Continuity procedures, backup systems, stakeholder communication
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

147. **Post-Incident Activities**: What post-incident activities are performed? How do you conduct lessons learned sessions? How are improvements tracked and implemented?
    - Evidence: Post-incident procedures, lessons learned process, improvement tracking
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Section 9: Business Continuity & Disaster Recovery (8 questions)

148. **Business Impact Analysis**: Have you conducted a comprehensive Business Impact Analysis? How do you determine Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO)?
    - Evidence: BIA documentation, RTO/RPO definitions, criticality assessments
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

149. **Disaster Recovery Planning**: Do you have documented disaster recovery plans? How often are DR plans tested? What types of disaster scenarios are covered?
    - Evidence: DR plans, testing schedule, scenario coverage
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

150. **Backup Strategies**: What backup strategies are implemented across different data types? How are backup integrity and recoverability verified? What is your backup retention strategy?
    - Evidence: Backup procedures, integrity testing, retention policies
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

151. **High Availability Architecture**: How do you implement high availability for critical systems? What redundancy measures are in place? How is failover automated?
    - Evidence: HA architecture, redundancy design, failover automation
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

152. **Crisis Management**: Do you have crisis management procedures? Who leads crisis response? How do you coordinate with external parties during crises?
    - Evidence: Crisis procedures, leadership structure, external coordination
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

153. **Supply Chain Continuity**: How do you ensure continuity of critical suppliers and partners? What backup arrangements are in place? How do you assess supplier resilience?
    - Evidence: Supplier continuity plans, backup arrangements, resilience assessments
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

154. **Communications During Outages**: How do you communicate with stakeholders during outages? What communication channels are available if primary systems are down? How do you manage public communications?
    - Evidence: Communication procedures, backup channels, public relations plans
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

155. **Recovery Validation**: How do you validate that systems are fully recovered after an incident? What acceptance criteria are used? How do you ensure data integrity post-recovery?
    - Evidence: Validation procedures, acceptance criteria, integrity verification
    - Rating: [ ] N/A [ ] 0 [ ] 1 [ ] 2 [ ] 3 [ ] 4

## Assessment Summary

**Total Questions**: 155  
**Assessment Completion**: _____ questions answered / 155 total  
**Overall Maturity Score**: _____ / 620 points (Average: _____)

### Maturity Scoring by Domain
- **Governance & Risk Management**: _____ / 60
- **Identity & Access Management**: _____ / 100  
- **Network Security Architecture**: _____ / 80
- **Data Protection & Encryption**: _____ / 72
- **Logging, Monitoring & SIEM**: _____ / 88
- **DevSecOps & CI/CD Security**: _____ / 80
- **Vulnerability & Patch Management**: _____ / 60
- **Incident Response & Forensics**: _____ / 48
- **Business Continuity & DR**: _____ / 32

### Next Steps
1. **Priority Areas**: Identify domains with lowest maturity scores
2. **Evidence Collection**: Gather supporting evidence for all ratings
3. **Gap Analysis**: Document specific improvements needed
4. **Remediation Planning**: Develop action plans for identified gaps
5. **Follow-up Assessment**: Schedule reassessment timeline

---

**Assessment Completed By**: ________________________  
**Date**: _______________  
**Review Date**: _______________

