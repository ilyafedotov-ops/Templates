# Security Incident Response Report

**Document Classification:** CONFIDENTIAL  
**Report ID:** IR-[YYYY]-[###]  
**Report Date:** [Date]  
**Report Version:** 1.0  
**Report Status:** [Draft/Final]

---

## Executive Summary

### Incident Overview
- **Incident Type:** [Ransomware/Data Breach/Insider Threat/Supply Chain/Other]
- **Severity Level:** [Critical/High/Medium/Low]
- **Initial Detection:** [Date and Time - UTC]
- **Incident Closure:** [Date and Time - UTC]
- **Total Duration:** [Hours/Days]
- **Business Impact:** [Brief 1-2 sentence summary]

### Key Metrics
| Metric | Value |
|--------|--------|
| Time to Detection (TTD) | [X hours/minutes] |
| Time to Containment (TTC) | [X hours/minutes] |
| Time to Recovery (TTR) | [X hours/days] |
| Estimated Financial Impact | $[Amount] |
| Records/Accounts Affected | [Number] |
| Systems Impacted | [Number] |
| Regulatory Notifications Required | [Yes/No] |

### Critical Actions Taken
1. [Primary containment action]
2. [Key eradication measure]
3. [Recovery milestone]
4. [Communication/notification]

---

## Incident Details

### Initial Detection and Alerting

#### Detection Source
- **Primary Detection Method:** [Azure Sentinel Alert/User Report/Third-party Tool/Other]
- **Detection Time:** [Date and Time - UTC]
- **Detected By:** [Person/System/Tool]
- **Alert Details:**
  ```
  Alert Name: [Alert rule name]
  Severity: [High/Medium/Low]
  MITRE ATT&CK Technique: [Technique ID and name]
  Initial Indicators: [List key IoCs]
  ```

#### Azure Security Tools Involved
- **Azure Sentinel:** [Rules triggered, investigations opened]
- **Microsoft Defender for Cloud:** [Alerts generated]
- **Azure Log Analytics:** [Key queries and findings]
- **Microsoft 365 Defender:** [If applicable]
- **Azure Network Watcher:** [Traffic analysis]

### Incident Classification

#### NIST Framework Mapping
- **Identify:** [Assets affected, data types involved]
- **Protect:** [Failed controls, bypassed protections]
- **Detect:** [Detection mechanisms that worked/failed]
- **Respond:** [Response procedures activated]
- **Recover:** [Recovery procedures implemented]

#### MITRE ATT&CK Framework
| Tactic | Technique | Evidence |
|--------|-----------|----------|
| [Initial Access] | [T####: Technique Name] | [Evidence description] |
| [Execution] | [T####: Technique Name] | [Evidence description] |
| [Persistence] | [T####: Technique Name] | [Evidence description] |
| [Privilege Escalation] | [T####: Technique Name] | [Evidence description] |
| [Defense Evasion] | [T####: Technique Name] | [Evidence description] |
| [Credential Access] | [T####: Technique Name] | [Evidence description] |
| [Discovery] | [T####: Technique Name] | [Evidence description] |
| [Lateral Movement] | [T####: Technique Name] | [Evidence description] |
| [Collection] | [T####: Technique Name] | [Evidence description] |
| [Exfiltration] | [T####: Technique Name] | [Evidence description] |
| [Impact] | [T####: Technique Name] | [Evidence description] |

---

## Timeline Analysis

### Incident Timeline
| Date/Time (UTC) | Event | Source | Action Taken | Responsible Party |
|-----------------|--------|--------|--------------|-------------------|
| [YYYY-MM-DD HH:MM] | [Initial compromise/suspicious activity] | [Evidence source] | [Action] | [Person/Team] |
| [YYYY-MM-DD HH:MM] | [Detection/Alert triggered] | [Azure Sentinel/Tool] | [Escalation] | [SOC Analyst] |
| [YYYY-MM-DD HH:MM] | [Containment initiated] | [Response team] | [Isolation/blocking] | [Incident Commander] |
| [YYYY-MM-DD HH:MM] | [Eradication completed] | [Security team] | [Threat removal] | [Security Engineer] |
| [YYYY-MM-DD HH:MM] | [Recovery initiated] | [Operations team] | [System restoration] | [Ops Manager] |
| [YYYY-MM-DD HH:MM] | [Normal operations restored] | [Business owner] | [Validation] | [Business Owner] |

### Attack Chain Reconstruction
1. **Initial Vector:** [How the attacker gained access]
2. **Establishment:** [How persistence was achieved]
3. **Escalation:** [Privilege escalation methods]
4. **Internal Reconnaissance:** [Discovery activities]
5. **Lateral Movement:** [Spread to additional systems]
6. **Data Access/Collection:** [What data was accessed]
7. **Exfiltration/Impact:** [Data theft or business disruption]

---

## Impact Assessment

### Business Impact Analysis

#### Operational Impact
- **Systems Affected:**
  - Production Systems: [List with downtime]
  - Development Systems: [List with impact]
  - Support Systems: [List with impact]
- **Service Disruption:**
  - Customer-facing Services: [Duration and scope]
  - Internal Services: [Duration and scope]
  - Third-party Integrations: [Impact assessment]

#### Data Impact Assessment
- **Data Categories Affected:**
  - Personal Data (PII): [Volume and types]
  - Financial Data: [Volume and types]
  - Intellectual Property: [Volume and types]
  - System Credentials: [Types compromised]
- **Data Confidentiality:** [Accessed/Copied/Stolen]
- **Data Integrity:** [Modified/Corrupted/Destroyed]
- **Data Availability:** [Encrypted/Deleted/Inaccessible]

#### Financial Impact
| Cost Category | Estimated Cost | Notes |
|---------------|----------------|-------|
| Direct Response Costs | $[Amount] | [Personnel, vendors, tools] |
| Business Disruption | $[Amount] | [Lost revenue, productivity] |
| Data Recovery | $[Amount] | [Restoration, reconstruction] |
| Legal/Regulatory | $[Amount] | [Fines, legal fees] |
| Reputation Management | $[Amount] | [PR, customer compensation] |
| **Total Estimated Impact** | **$[Amount]** | |

#### Regulatory and Compliance Impact
- **GDPR:** [If EU personal data affected]
- **CCPA:** [If CA personal data affected]
- **HIPAA:** [If healthcare data affected]
- **SOX:** [If financial data affected]
- **Industry Regulations:** [Sector-specific requirements]

---

## Technical Analysis

### Azure Environment Assessment

#### Affected Azure Resources
- **Subscriptions:** [List subscription IDs and names]
- **Resource Groups:** [Affected resource groups]
- **Virtual Machines:** [Compromised/affected VMs]
- **Storage Accounts:** [Accessed storage accounts]
- **Databases:** [SQL, CosmosDB, other databases]
- **Network Components:** [VNets, NSGs, load balancers]
- **Identity Components:** [Azure AD, managed identities]

#### Azure Security Controls Analysis
- **Failed Controls:**
  - Azure Policies: [List bypassed or failed policies]
  - Conditional Access: [Failed CA policies]
  - Network Security Groups: [Ineffective rules]
  - Azure Firewall: [Bypassed rules]
  - Storage Security: [Failed access controls]

- **Effective Controls:**
  - Detection: [Controls that identified the incident]
  - Containment: [Controls that limited impact]
  - Monitoring: [Logging that provided visibility]

### Indicators of Compromise (IoCs)

#### Network Indicators
```
IP Addresses:
- [Malicious IP 1] - [Context/purpose]
- [Malicious IP 2] - [Context/purpose]

Domains:
- [malicious-domain.com] - [C2 server]
- [phishing-domain.com] - [Initial vector]

URLs:
- [Full malicious URLs]
```

#### File System Indicators
```
File Hashes (SHA256):
- [hash1] - [malware.exe - backdoor]
- [hash2] - [script.ps1 - persistence mechanism]

File Paths:
- C:\Windows\Temp\[malicious-file]
- /tmp/[suspicious-script]

Registry Keys (Windows):
- HKCU\Software\[persistence key]
```

#### Azure-Specific Indicators
```
Azure AD Indicators:
- Suspicious Sign-ins: [IP addresses, locations]
- Modified Applications: [App registrations changed]
- New Service Principals: [Unauthorized service principals]
- Privilege Escalations: [Role assignments]

Azure Resource Indicators:
- Suspicious Resource Creation: [Resource types and names]
- Configuration Changes: [NSG rules, storage permissions]
- Unusual Activity: [API calls, resource access patterns]
```

### Log Analysis Summary

#### Key Log Sources
- **Azure Activity Logs:** [Subscription-level activities]
- **Azure AD Sign-in Logs:** [Authentication events]
- **Azure Security Center:** [Security alerts and recommendations]
- **Azure Sentinel:** [SIEM analysis and hunting]
- **Application Logs:** [Custom application logging]

#### Critical Log Entries
```kql
// Example KQL queries used for analysis
SigninLogs
| where TimeGenerated > ago(7d)
| where RiskState == "atRisk"
| where IPAddress in ("[suspicious-ip-list]")
| project TimeGenerated, UserPrincipalName, IPAddress, Location

AuditLogs
| where TimeGenerated > ago(7d)
| where OperationName contains "role assignment"
| where Result == "success"
| project TimeGenerated, InitiatedBy, TargetResources
```

---

## Response Actions

### Incident Response Team
- **Incident Commander:** [Name, Role]
- **Security Lead:** [Name, Role]
- **IT Operations Lead:** [Name, Role]
- **Legal Counsel:** [Name, Role]
- **Communications Lead:** [Name, Role]
- **Business Owner:** [Name, Role]

### Containment Actions

#### Immediate Containment (Short-term)
1. **Network Isolation:**
   - Isolated affected VMs: [List VMs and methods]
   - Blocked malicious IPs: [IP addresses and method]
   - Updated NSG rules: [Specific rule changes]

2. **Identity and Access:**
   - Disabled compromised accounts: [Account names]
   - Reset passwords: [Scope of reset]
   - Revoked access tokens: [Token types and scope]

3. **System Containment:**
   - Shutdown affected systems: [System list and timing]
   - Isolated network segments: [Segment details]
   - Applied emergency patches: [Systems and patches]

#### Long-term Containment
1. **System Hardening:**
   - Updated security policies: [Policy changes]
   - Enhanced monitoring: [New rules and alerts]
   - Network segmentation: [New security zones]

2. **Access Control Improvements:**
   - Implemented zero trust: [Specific controls]
   - Enhanced MFA: [Scope and methods]
   - Privileged access review: [Review outcomes]

### Eradication Actions

#### Threat Removal
1. **Malware Removal:**
   - Systems cleaned: [List of systems and methods]
   - Malicious files deleted: [File list and verification]
   - Registry entries removed: [Registry modifications]

2. **Persistence Mechanisms:**
   - Scheduled tasks removed: [Task details]
   - Services uninstalled: [Service names]
   - User accounts deleted: [Rogue accounts]

3. **Configuration Remediation:**
   - Security policies updated: [Policy changes]
   - Vulnerabilities patched: [CVE numbers and systems]
   - Misconfigurations corrected: [Configuration changes]

### Recovery Actions

#### System Restoration
1. **Data Recovery:**
   - Backup restoration: [Systems and data restored]
   - Data integrity validation: [Validation methods and results]
   - Application testing: [Testing procedures and results]

2. **Service Restoration:**
   - Phased service restart: [Service order and timing]
   - Monitoring enhancement: [New monitoring capabilities]
   - Performance validation: [Performance metrics]

#### Business Process Recovery
1. **Operational Resumption:**
   - Critical processes restored: [Process list and timing]
   - User access restored: [User groups and timing]
   - Partner connectivity restored: [Partner systems]

---

## Root Cause Analysis

### 5-Whys Analysis
1. **Why did the incident occur?**
   [Primary reason - e.g., malware infection]

2. **Why did the malware succeed?**
   [Contributing factor - e.g., unpatched vulnerability]

3. **Why was the system unpatched?**
   [Process issue - e.g., patch management failure]

4. **Why did patch management fail?**
   [Resource issue - e.g., insufficient testing resources]

5. **Why were testing resources insufficient?**
   [Root cause - e.g., inadequate security budget allocation]

### Contributing Factors
- **Technical Factors:**
  - Unpatched vulnerabilities: [List CVEs and systems]
  - Configuration weaknesses: [Specific misconfigurations]
  - Insufficient monitoring: [Coverage gaps]

- **Process Factors:**
  - Inadequate procedures: [Process gaps identified]
  - Training deficiencies: [Knowledge gaps]
  - Communication failures: [Information flow issues]

- **Human Factors:**
  - Social engineering success: [Attack vector details]
  - Policy violations: [Specific violations]
  - Oversight failures: [Supervision gaps]

### Lessons Learned
1. **What went well?**
   - [Positive aspects of the response]
   - [Effective controls and procedures]

2. **What could be improved?**
   - [Response improvements needed]
   - [Process enhancements required]

3. **What was missing?**
   - [Gaps in detection/response]
   - [Missing tools or capabilities]

---

## Recommendations

### Immediate Actions (0-30 days)
1. **Critical Security Improvements:**
   - [Specific security control implementation]
   - [Urgent vulnerability remediation]
   - [Enhanced monitoring deployment]

2. **Process Improvements:**
   - [Incident response procedure updates]
   - [Emergency communication enhancements]
   - [Backup and recovery testing]

### Short-term Actions (1-3 months)
1. **Technology Enhancements:**
   - [Security tool deployment/upgrade]
   - [Network architecture improvements]
   - [Identity management enhancements]

2. **Training and Awareness:**
   - [Security awareness training]
   - [Technical skill development]
   - [Incident response exercises]

### Long-term Actions (3-12 months)
1. **Strategic Initiatives:**
   - [Security architecture improvements]
   - [Zero trust implementation]
   - [Advanced threat protection]

2. **Organizational Changes:**
   - [Security governance improvements]
   - [Resource allocation changes]
   - [Third-party risk management]

---

## Regulatory and Legal Considerations

### Breach Notification Requirements
- **Timeline for Notifications:**
  - Regulatory authorities: [72 hours for GDPR, specific timelines]
  - Affected individuals: [Without undue delay, typically 30 days]
  - Law enforcement: [If criminal activity suspected]

- **Notification Status:**
  - [✓/✗] Data Protection Authority notified
  - [✓/✗] Affected individuals notified
  - [✓/✗] Customer notifications sent
  - [✓/✗] Partner notifications sent

### Legal Implications
- **Potential Liability:** [Assessment of legal exposure]
- **Regulatory Compliance:** [Status of compliance requirements]
- **Insurance Claims:** [Cyber insurance claim status]
- **Legal Holds:** [Litigation hold requirements]

---

## Communication and Reporting

### Internal Communications
- **Executive Briefings:** [Schedule and participants]
- **Board Reporting:** [Board notification requirements]
- **Employee Communications:** [Internal announcements]

### External Communications
- **Customer Communications:** [Customer notification approach]
- **Media Response:** [Public relations strategy]
- **Partner Notifications:** [Third-party communications]
- **Regulatory Communications:** [Authority interactions]

---

## Evidence Preservation

### Digital Evidence
- **Log Files:** [Preserved log sources and retention]
- **System Images:** [Forensic images taken]
- **Memory Dumps:** [Systems with memory captures]
- **Network Captures:** [Network traffic recordings]

### Chain of Custody
- **Evidence Custodian:** [Person responsible]
- **Storage Location:** [Secure storage details]
- **Access Log:** [Who accessed evidence when]

---

## Appendices

### Appendix A: Detailed Timeline
[Comprehensive minute-by-minute timeline if needed]

### Appendix B: Technical Analysis
[Detailed technical findings, malware analysis, etc.]

### Appendix C: Log Extracts
[Relevant log entries and analysis queries]

### Appendix D: Communication Templates
[Sample communications used during incident]

### Appendix E: Regulatory Correspondence
[Copies of regulatory notifications and responses]

---

**Document Control**
- **Author:** [Security Incident Response Team]
- **Reviewer:** [Security Manager/CISO]
- **Approver:** [Executive Sponsor]
- **Distribution:** [List of authorized recipients]
- **Retention:** [Document retention period]
- **Classification:** [Information classification level]

---
*This document contains confidential and privileged information. Distribution is restricted to authorized personnel only.*