# Azure Logging & Monitoring Standard

**Document Version:** 2.1  
**Effective Date:** [Current Date]  
**Review Date:** [Quarterly]  
**Owner:** Security & Compliance Team  
**Approved By:** CISO  

## 1. Executive Summary

This document defines the enterprise logging and monitoring standards for Azure environments to ensure comprehensive security visibility, regulatory compliance, and operational excellence. This standard supports ISO 27001:2022, SOC 2 Type II, and other regulatory requirements through systematic log collection, analysis, and retention practices.

## 2. Purpose and Scope

### 2.1 Purpose
- Establish consistent logging and monitoring practices across all Azure resources
- Ensure compliance with ISO 27001:2022 Annex A controls (A.12.4.1-A.12.4.4)
- Meet SOC 2 Trust Service Criteria for security monitoring and logging
- Enable effective incident detection, response, and forensic investigation
- Provide operational visibility and performance monitoring capabilities

### 2.2 Scope
This standard applies to:
- All Azure subscriptions and resources within the organization
- All data processing activities in Azure environments
- All personnel with access to Azure logging and monitoring systems
- Third-party integrations that generate or access log data

## 3. Regulatory and Framework Alignment

### 3.1 ISO 27001:2022 Control Mapping
| Control | Description | Implementation |
|---------|-------------|---------------|
| A.12.4.1 | Event logging | Comprehensive event logging across all systems |
| A.12.4.2 | Protection of log information | Immutable storage, access controls, integrity monitoring |
| A.12.4.3 | Administrator and operator logs | Privileged activity monitoring and segregation |
| A.12.4.4 | Clock synchronization | NTP synchronization across all systems |
| A.16.1.7 | Collection of evidence | Forensic log collection and preservation |

### 3.2 SOC 2 Trust Service Criteria
| Criterion | Control Activity | Logging Requirement |
|-----------|-----------------|-------------------|
| CC6.1 | Logical access controls | Authentication and authorization event logging |
| CC6.2 | Authentication policies | Failed login attempts and account lockouts |
| CC6.3 | Network security | Network traffic and firewall logs |
| CC7.1 | System monitoring | System availability and performance monitoring |
| CC7.2 | Intrusion detection | Security event detection and alerting |

## 4. Log Sources and Data Types

### 4.1 Azure Service Logs
#### 4.1.1 Mandatory Log Sources
| Azure Service | Log Type | Data Sources | Retention |
|---------------|----------|--------------|-----------|
| Azure Active Directory | Sign-in, Audit, Provisioning | AuditLogs, SignInLogs, ProvisioningLogs | 7 years |
| Azure Resource Manager | Activity Logs | Azure Activity Log | 7 years |
| Virtual Machines | OS & Security Logs | Windows: Security, System, Application<br>Linux: Syslog, Auth | 3 years |
| Network Security Groups | Flow Logs | NSG Flow Logs v2 | 2 years |
| Azure Firewall | Network Logs | AzureFirewallApplicationRule, AzureFirewallNetworkRule | 2 years |
| Key Vault | Audit Logs | KeyVaultData | 7 years |
| SQL Database | Audit & Vulnerability | SQLSecurityAuditEvents, SQLVulnerabilityAssessmentResult | 7 years |
| Storage Accounts | Access Logs | StorageBlobLogs, StorageFileLogs | 3 years |
| App Services | Application Logs | AppServiceHTTPLogs, AppServiceConsoleLogs | 1 year |
| Azure Kubernetes | Container Logs | ContainerLogV2, KubePodInventory | 1 year |

#### 4.1.2 Recommended Log Sources
- Application Insights telemetry and performance data
- Azure Monitor metrics and diagnostic data
- Azure Sentinel security analytics
- Custom application logs via Log Analytics agent

### 4.2 Log Classification and Handling
| Classification | Examples | Retention | Access Level |
|----------------|----------|-----------|---------------|
| **Critical Security** | Authentication events, privilege escalation, security violations | 7 years | Restricted |
| **Compliance Required** | Financial transactions, PII access, audit trails | 7 years | Controlled |
| **Operational** | Application performance, system health, availability | 3 years | Standard |
| **Diagnostic** | Debug logs, trace data, development metrics | 1 year | Standard |

## 5. Logging Infrastructure Architecture

### 5.1 Core Components
#### 5.1.1 Log Analytics Workspace Configuration
- **Primary Workspace**: Single Log Analytics workspace per business unit
- **Geo-replication**: Cross-region backup for business continuity
- **Capacity Reservation**: Minimum 100GB/day commitment for cost optimization
- **Data Retention**: Tiered retention based on log classification

#### 5.1.2 Diagnostic Settings Standard
**All Azure resources must implement the following diagnostic configuration:**

```json
{
  "properties": {
    "workspaceId": "/subscriptions/{subscription-id}/resourcegroups/{rg}/providers/microsoft.operationalinsights/workspaces/{workspace}",
    "storageAccountId": "/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage}",
    "logs": [
      {
        "category": "AuditEvent",
        "enabled": true,
        "retentionPolicy": {
          "enabled": true,
          "days": 2555
        }
      }
    ],
    "metrics": [
      {
        "category": "AllMetrics",
        "enabled": true,
        "retentionPolicy": {
          "enabled": true,
          "days": 365
        }
      }
    ]
  }
}
```

### 5.2 Microsoft Sentinel SIEM Configuration
#### 5.2.1 Data Connectors (Mandatory)
- Azure Activity connector
- Azure Active Directory connector
- Office 365 connector
- Microsoft Defender for Cloud connector
- Azure Firewall connector
- DNS Analytics connector

#### 5.2.2 Analytics Rules Requirements
- **High-fidelity rules**: < 5% false positive rate
- **Coverage**: Minimum 80% MITRE ATT&CK technique coverage
- **Response time**: Critical alerts < 15 minutes, High alerts < 1 hour
- **Tuning cycle**: Monthly review and optimization

### 5.3 Immutable Storage Configuration
#### 5.3.1 Critical Log Immutability
```json
{
  "immutabilityPolicy": {
    "properties": {
      "immutabilityPeriodSinceCreationInDays": 2555,
      "state": "Locked"
    }
  },
  "legalHold": {
    "hasLegalHold": true,
    "tags": ["compliance", "audit", "litigation-hold"]
  }
}
```

## 6. Access Controls and Segregation of Duties

### 6.1 Role-Based Access Control (RBAC)
| Role | Permissions | Justification |
|------|-------------|---------------|
| **Security Administrator** | Full Sentinel access, policy management | Security incident response |
| **Compliance Auditor** | Read-only access to all logs | Audit and compliance verification |
| **SOC Analyst** | Sentinel investigation, case management | Security monitoring and analysis |
| **System Administrator** | Infrastructure logs, performance metrics | Operational troubleshooting |
| **Application Owner** | Application-specific logs only | Development and support |

### 6.2 Segregation of Duties Matrix
| Activity | Security Team | IT Operations | Compliance | External Auditor |
|----------|---------------|---------------|------------|------------------|
| Log Policy Creation | Primary | Contribute | Review | - |
| Alert Configuration | Primary | Secondary | Review | - |
| Incident Investigation | Primary | Support | Observer | - |
| Log Access Review | Primary | - | Verify | - |
| Compliance Reporting | Support | - | Primary | Access |
| Audit Log Review | Secondary | - | Primary | Primary |

## 7. Monitoring and Alerting Framework

### 7.1 Alert Severity Classification
| Severity | Response Time | Escalation | Examples |
|----------|---------------|------------|----------|
| **Critical** | 15 minutes | Immediate page | Data breach, system compromise |
| **High** | 1 hour | Email + SMS | Failed authentication spike, malware detection |
| **Medium** | 4 hours | Email | Policy violations, unusual activity |
| **Low** | 24 hours | Email | Information events, scheduled maintenance |
| **Informational** | No SLA | Dashboard | Normal operations, statistics |

### 7.2 Key Performance Indicators (KPIs)
#### 7.2.1 Operational Metrics
- **Log Ingestion Rate**: Target 99.9% successful ingestion
- **Alert Response Time**: Average < SLA targets
- **False Positive Rate**: < 5% for high/critical alerts
- **Mean Time to Detection (MTTD)**: < 15 minutes for critical events
- **Mean Time to Response (MTTR)**: < 1 hour for critical incidents

#### 7.2.2 Compliance Metrics
- **Log Retention Compliance**: 100% adherence to retention policies
- **Access Review Completion**: 100% quarterly reviews completed
- **Audit Trail Completeness**: 100% for critical security events
- **Control Effectiveness**: > 95% for automated controls

### 7.3 Baseline Alert Rules
#### 7.3.1 Security-Critical Alerts
```kql
// Multiple failed logins from single IP
SigninLogs
| where TimeGenerated > ago(5m)
| where ResultType != 0
| summarize FailureCount = count() by IPAddress, bin(TimeGenerated, 1m)
| where FailureCount >= 10
```

```kql
// Privilege escalation events
AuditLogs
| where TimeGenerated > ago(15m)
| where OperationName contains "Add member to role"
| where Result == "success"
| where TargetResources has "Global Administrator"
```

## 8. Data Retention and Lifecycle Management

### 8.1 Retention Policy Framework
| Data Classification | Log Analytics | Archive Storage | Legal Hold | Disposal Method |
|---------------------|---------------|-----------------|------------|-----------------|
| **Critical Security** | 2 years hot | 5 years cold | Indefinite | Secure deletion |
| **Compliance** | 1 year hot | 6 years cold | 7 years | Certified destruction |
| **Operational** | 6 months hot | 2.5 years cold | None | Standard deletion |
| **Diagnostic** | 90 days hot | 11 months cold | None | Automated purge |

### 8.2 Archive and Backup Strategy
#### 8.2.1 Hot Tier (Log Analytics)
- Real-time querying and alerting
- Full KQL query capabilities
- Interactive dashboards and workbooks

#### 8.2.2 Cold Tier (Azure Blob Archive)
- Cost-optimized long-term storage
- Compliance and audit access
- Immutable blob storage with legal hold

#### 8.2.3 Backup and Recovery
- Cross-region geo-replication for critical logs
- Point-in-time recovery capabilities
- Regular backup validation and testing

## 9. Implementation Roadmap

### 9.1 Phase 1: Foundation (Weeks 1-4)
- Deploy Log Analytics workspace with proper configuration
- Enable diagnostic settings on all critical resources
- Implement basic RBAC controls
- Configure data retention policies

### 9.2 Phase 2: Security Monitoring (Weeks 5-8)
- Deploy Microsoft Sentinel with core data connectors
- Implement baseline analytics rules
- Configure alerting and notification channels
- Establish SOC procedures and playbooks

### 9.3 Phase 3: Compliance (Weeks 9-12)
- Implement immutable storage for critical logs
- Complete compliance mapping and gap analysis
- Establish audit trails and evidence collection
- Conduct control effectiveness testing

### 9.4 Phase 4: Optimization (Weeks 13-16)
- Fine-tune alert rules and reduce false positives
- Implement advanced analytics and ML detection
- Optimize cost through data lifecycle management
- Complete staff training and certification

## 10. Compliance Validation and Testing

### 10.1 Control Testing Procedures
#### 10.1.1 Log Integrity Verification
- Monthly hash verification of archived logs
- Quarterly sampling of log completeness
- Annual penetration testing of logging systems

#### 10.1.2 Access Control Testing
- Quarterly access reviews and recertification
- Semi-annual segregation of duties validation
- Annual privileged access assessment

### 10.2 Audit Evidence Collection
#### 10.2.1 ISO 27001 Evidence
- Log retention policy documentation
- Access control matrices and reviews
- Incident response logs and metrics
- Control effectiveness reports

#### 10.2.2 SOC 2 Evidence
- System-generated reports on log activities
- Exception reports for failed log ingestion
- Access provisioning and deprovisioning logs
- Change management logs for logging infrastructure

## 11. Metrics and Reporting

### 11.1 Executive Dashboard Metrics
- Security posture score (composite metric)
- Compliance percentage by framework
- Critical incident count and resolution times
- Log infrastructure availability and performance

### 11.2 Operational Reports
#### 11.2.1 Daily Reports
- Critical and high-severity alert summary
- Log ingestion health and volumes
- Failed authentication attempts and anomalies
- System availability and performance metrics

#### 11.2.2 Weekly Reports
- Security incident trends and analysis
- Compliance exception reports
- Alert tuning and optimization recommendations
- Capacity planning and cost optimization

#### 11.2.3 Monthly Reports
- Comprehensive security posture assessment
- Compliance scorecard with gap analysis
- Log retention compliance status
- Training and awareness metrics

## 12. Incident Response Integration

### 12.1 SIEM Integration Requirements
- Automated case creation for critical alerts
- Integration with ITSM for ticket management
- Evidence preservation for forensic analysis
- Chain of custody documentation

### 12.2 Forensic Capabilities
- Complete audit trail reconstruction
- Timeline analysis and correlation
- Evidence export in industry-standard formats
- Legal hold and litigation support

## 13. Training and Awareness

### 13.1 Role-Based Training Requirements
| Role | Training Requirements | Frequency | Certification |
|------|----------------------|-----------|---------------|
| **Security Analysts** | SIEM operation, threat hunting | Annual | Industry certification |
| **System Administrators** | Log configuration, troubleshooting | Bi-annual | Vendor certification |
| **Compliance Officers** | Audit procedures, evidence collection | Annual | Professional certification |
| **All Staff** | Security awareness, incident reporting | Annual | Internal assessment |

## 14. Exception Management

### 14.1 Exception Request Process
1. Business justification documentation
2. Risk assessment and mitigation controls
3. Approval by CISO or designee
4. Regular review and revalidation
5. Documented compensating controls

### 14.2 Acceptable Exceptions
- Legacy systems with technical limitations
- Short-term maintenance windows
- Development/testing environments (with appropriate controls)
- Third-party systems with contractual limitations

## 15. Continuous Improvement

### 15.1 Review and Update Schedule
- **Quarterly**: Policy effectiveness review
- **Semi-annually**: Technology and tool assessment
- **Annually**: Comprehensive standard revision
- **Ad-hoc**: Incident-driven improvements

### 15.2 Industry Best Practice Alignment
- Regular benchmarking against industry standards
- Participation in security communities and forums
- Evaluation of emerging technologies and threats
- Integration of lessons learned from incidents

## 16. Appendices

### Appendix A: Azure Service Diagnostic Settings Templates
### Appendix B: KQL Query Library
### Appendix C: Alert Rule Templates
### Appendix D: Compliance Mapping Matrix
### Appendix E: Incident Response Playbooks

---

**Document Control:**
- This document is reviewed quarterly and updated as needed
- All changes must be approved by the CISO or designated security authority
- Version history and change log maintained separately
- Distribution controlled - Internal Use Only
