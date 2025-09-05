# Enterprise Shared Responsibility Matrix for Azure Cloud Environments

## Executive Summary

This comprehensive shared responsibility matrix defines the distribution of security, operational, and compliance responsibilities between Microsoft Azure, customer organizations, and third-party service providers across all Azure service models. This framework aligns with ISO 27001:2022, SOC 2 Type II, PCI DSS, and other regulatory requirements to ensure clear accountability, risk ownership, and operational excellence in enterprise cloud deployments.

## Responsibility Framework

### Responsibility Levels
- **Azure**: Microsoft Azure is fully responsible
- **Customer**: Customer organization is fully responsible  
- **Shared**: Joint responsibility with clearly defined boundaries
- **Third-Party**: External vendor or service provider responsible
- **N/A**: Not applicable to the service model

### Service Model Definitions
- **IaaS**: Infrastructure as a Service (Virtual Machines, Storage, Networking)
- **PaaS**: Platform as a Service (App Service, SQL Database, AKS)
- **SaaS**: Software as a Service (Azure AD, Microsoft 365 integration)
- **Serverless**: Function-based computing (Azure Functions, Logic Apps)
- **Container**: Containerized workloads (ACI, AKS, Container Apps)

## Core Infrastructure Security Domains

| Security Domain | IaaS | PaaS | SaaS | Serverless | Container | Compliance Requirements |
|---|---|---|---|---|---|---|
| **Physical Infrastructure** |
| Data center physical security | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.11.1, SOC 2: CC6.1 |
| Hardware provisioning & maintenance | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.11.2 |
| Environmental controls | Azure | Azure | Azure | Azure | Azure | SOC 2: CC6.4 |
| Power & cooling systems | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.11.2.4 |
| **Host Infrastructure** |
| Hypervisor security | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.13.1.1 |
| Host OS patching & hardening | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.12.6.1 |
| Host-level antimalware | Azure | Azure | Azure | Azure | Azure | SOC 2: CC7.2 |
| Hardware security modules | Azure | Azure | Azure | Azure | Azure | ISO 27001: A.10.1.2 |

## Network Security Responsibilities

| Network Security Domain | IaaS | PaaS | SaaS | Serverless | Container | Risk Owner |
|---|---|---|---|---|---|---|
| **Network Infrastructure** |
| Physical network security | Azure | Azure | Azure | Azure | Azure | Azure |
| Network fabric isolation | Azure | Azure | Azure | Azure | Azure | Azure |
| DDoS protection (basic) | Azure | Azure | Azure | Azure | Azure | Azure |
| **Virtual Networking** |
| Virtual network configuration | Customer | Shared | Azure | Shared | Shared | Customer |
| Subnet design & segmentation | Customer | Customer | N/A | Customer | Customer | Customer |
| Network Security Groups (NSGs) | Customer | Customer | N/A | Customer | Customer | Customer |
| Application Security Groups | Customer | Customer | N/A | Customer | Customer | Customer |
| **Advanced Network Controls** |
| Azure Firewall configuration | Customer | Customer | N/A | Customer | Customer | Customer |
| Web Application Firewall (WAF) | Customer | Shared | Azure | Shared | Shared | Customer |
| Private endpoints configuration | Customer | Customer | Azure | Customer | Customer | Customer |
| Service endpoints configuration | Customer | Customer | N/A | Customer | Customer | Customer |
| **Connectivity & Routing** |
| ExpressRoute configuration | Customer | Customer | Customer | Customer | Customer | Customer |
| VPN Gateway management | Customer | Customer | Customer | Customer | Customer | Customer |
| Route table management | Customer | Customer | N/A | Customer | Customer | Customer |
| DNS configuration | Customer | Customer | Shared | Customer | Customer | Customer |

## Identity & Access Management

| IAM Domain | IaaS | PaaS | SaaS | Serverless | Container | Compliance Framework |
|---|---|---|---|---|---|---|
| **Identity Infrastructure** |
| Azure AD tenant configuration | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.2, SOC 2: CC6.2 |
| Directory synchronization | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.2.5 |
| Multi-factor authentication | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.4.2 |
| Conditional access policies | Customer | Customer | Customer | Customer | Customer | SOC 2: CC6.6 |
| **Access Controls** |
| Role-based access control (RBAC) | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.1.2 |
| Privileged identity management | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.2.3 |
| Just-in-time access | Customer | Customer | Customer | Customer | Customer | SOC 2: CC6.3 |
| Service principal management | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.2.1 |
| **Authentication & Authorization** |
| Managed identity configuration | Customer | Customer | N/A | Customer | Customer | ISO 27001: A.9.2.4 |
| Certificate management | Customer | Customer | Shared | Customer | Customer | ISO 27001: A.10.1.2 |
| API authentication | Customer | Customer | Customer | Customer | Customer | SOC 2: CC6.7 |
| Token lifecycle management | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.9.2.6 |

## Data Protection & Encryption

| Data Protection Domain | IaaS | PaaS | SaaS | Serverless | Container | Risk Category |
|---|---|---|---|---|---|---|
| **Encryption at Rest** |
| Platform-managed encryption | Azure | Azure | Azure | Azure | Azure | High |
| Customer-managed keys (CMK) | Customer | Customer | Customer | Customer | Customer | Critical |
| Key vault management | Customer | Customer | Customer | Customer | Customer | Critical |
| Hardware security module (HSM) | Shared | Shared | Azure | Shared | Shared | High |
| **Encryption in Transit** |
| TLS/SSL configuration | Customer | Customer | Azure | Customer | Customer | High |
| VPN encryption | Customer | Customer | Customer | Customer | Customer | Medium |
| Application-level encryption | Customer | Customer | Customer | Customer | Customer | High |
| **Data Classification** |
| Data discovery & classification | Customer | Customer | Customer | Customer | Customer | High |
| Data loss prevention (DLP) | Customer | Customer | Customer | Customer | Customer | Medium |
| Information protection labels | Customer | Customer | Customer | Customer | Customer | Medium |
| **Data Lifecycle Management** |
| Data retention policies | Customer | Customer | Customer | Customer | Customer | High |
| Secure data disposal | Shared | Shared | Azure | Shared | Shared | High |
| Data residency compliance | Shared | Shared | Azure | Shared | Shared | Critical |

## Application Security

| Application Security Domain | IaaS | PaaS | SaaS | Serverless | Container | Development Phase |
|---|---|---|---|---|---|---|
| **Secure Development** |
| Secure coding practices | Customer | Customer | N/A | Customer | Customer | Design |
| Static application security testing | Customer | Customer | N/A | Customer | Customer | Development |
| Dynamic application security testing | Customer | Customer | N/A | Customer | Customer | Testing |
| Dependency scanning | Customer | Customer | N/A | Customer | Customer | CI/CD |
| **Runtime Protection** |
| Application firewall configuration | Customer | Shared | Azure | Shared | Shared | Deployment |
| Runtime application protection | Customer | Customer | Azure | Customer | Customer | Operations |
| API security & rate limiting | Customer | Customer | Azure | Customer | Customer | Operations |
| **Configuration Management** |
| Application configuration security | Customer | Customer | N/A | Customer | Customer | Deployment |
| Secrets management integration | Customer | Customer | Customer | Customer | Customer | Operations |
| Configuration drift detection | Customer | Customer | N/A | Customer | Customer | Operations |

## Monitoring, Logging & Compliance

| Monitoring Domain | IaaS | PaaS | SaaS | Serverless | Container | Audit Requirement |
|---|---|---|---|---|---|---|
| **Security Monitoring** |
| Security event collection | Customer | Shared | Azure | Shared | Shared | SOC 2: CC7.2, ISO 27001: A.12.4.1 |
| Threat detection rules | Customer | Customer | Azure | Customer | Customer | SOC 2: CC7.2 |
| Security incident response | Customer | Customer | Customer | Customer | Customer | ISO 27001: A.16.1 |
| Vulnerability scanning | Customer | Shared | Azure | Shared | Shared | ISO 27001: A.12.6.1 |
| **Audit Logging** |
| Platform audit log configuration | Azure | Azure | Azure | Azure | Azure | SOC 2: CC4.1 |
| Application audit logging | Customer | Customer | Customer | Customer | Customer | SOC 2: CC4.2 |
| Log retention & archival | Customer | Customer | Azure | Customer | Customer | ISO 27001: A.12.4.2 |
| Log integrity protection | Shared | Shared | Azure | Shared | Shared | SOC 2: CC4.1 |
| **Compliance Reporting** |
| Compliance dashboard configuration | Customer | Customer | Customer | Customer | Customer | All frameworks |
| Evidence collection automation | Customer | Customer | Customer | Customer | Customer | SOC 2: CC4.2 |
| Regulatory reporting | Customer | Customer | Customer | Customer | Customer | PCI DSS: 10.6 |

## Backup, Recovery & Business Continuity

| BC/DR Domain | IaaS | PaaS | SaaS | Serverless | Container | RTO/RPO Impact |
|---|---|---|---|---|---|---|
| **Backup Management** |
| Backup policy definition | Customer | Customer | Azure | Customer | Customer | High |
| Backup execution | Customer | Shared | Azure | Shared | Shared | High |
| Backup encryption | Shared | Shared | Azure | Shared | Shared | Critical |
| Cross-region backup replication | Customer | Customer | Azure | Customer | Customer | Medium |
| **Disaster Recovery** |
| DR plan development | Customer | Customer | Customer | Customer | Customer | Critical |
| DR testing procedures | Customer | Customer | Customer | Customer | Customer | High |
| Failover orchestration | Customer | Shared | Azure | Shared | Shared | Critical |
| Data synchronization | Customer | Shared | Azure | Shared | Shared | Critical |
| **High Availability** |
| Availability zone deployment | Customer | Customer | Azure | Customer | Customer | High |
| Load balancer configuration | Customer | Customer | Azure | Customer | Customer | Medium |
| Auto-scaling policies | Customer | Customer | Azure | Customer | Customer | Medium |

## Governance & Risk Management

| Governance Domain | Responsibility | Risk Level | Compliance Requirement |
|---|---|---|---|
| **Policy Management** |
| Azure Policy definition & assignment | Customer | High | ISO 27001: A.5.1 |
| Regulatory compliance monitoring | Customer | Critical | All frameworks |
| Exception management process | Customer | High | SOC 2: CC1.4 |
| Policy violation remediation | Customer | High | ISO 27001: A.16.1 |
| **Risk Assessment** |
| Cloud security risk assessment | Customer | Critical | ISO 27001: A.6.1.2 |
| Third-party risk evaluation | Customer | High | SOC 2: CC9.1 |
| Vendor security assessment | Customer | High | ISO 27001: A.15.1 |
| Supply chain risk management | Shared | High | SOC 2: CC9.2 |
| **Change Management** |
| Infrastructure change approval | Customer | High | ISO 27001: A.12.1.2 |
| Emergency change procedures | Customer | Critical | SOC 2: CC8.1 |
| Change impact assessment | Customer | High | ISO 27001: A.14.2.2 |

## Third-Party Integration Responsibilities

| Third-Party Domain | Customer | Azure | Third-Party | Risk Assessment |
|---|---|---|---|---|
| **Vendor Management** |
| Security vendor selection | ✓ | - | - | Customer risk |
| Vendor security assessment | ✓ | - | ✓ | Shared risk |
| Vendor access controls | ✓ | ✓ | ✓ | Shared risk |
| Contract security terms | ✓ | - | ✓ | Customer risk |
| **Service Integration** |
| API security configuration | ✓ | - | ✓ | Shared risk |
| Data sharing agreements | ✓ | - | ✓ | Customer risk |
| Incident notification procedures | ✓ | ✓ | ✓ | Shared risk |
| Performance SLA monitoring | ✓ | - | ✓ | Customer risk |

## Specific Azure Service Responsibilities

### Compute Services
| Service | Customer Responsibilities | Azure Responsibilities | Shared Responsibilities |
|---|---|---|---|
| **Virtual Machines** | Guest OS, applications, data, network config | Host infrastructure, hypervisor | Security updates coordination |
| **App Service** | Application code, configuration | Platform management, scaling | SSL certificates, monitoring |
| **Azure Functions** | Function code, triggers | Runtime environment | Monitoring configuration |
| **AKS** | Cluster configuration, workloads | Master node management | Security policies, updates |
| **Container Instances** | Container images, configuration | Container runtime | Resource allocation |

### Data Services
| Service | Customer Responsibilities | Azure Responsibilities | Shared Responsibilities |
|---|---|---|---|
| **Azure SQL Database** | Database schema, access control | Platform maintenance | Security configuration |
| **Cosmos DB** | Data modeling, consistency | Global distribution | Performance tuning |
| **Storage Accounts** | Access policies, encryption keys | Infrastructure redundancy | Network access rules |
| **Azure Synapse** | Data pipeline security | Service management | Data encryption |

### Security Services
| Service | Customer Responsibilities | Azure Responsibilities | Shared Responsibilities |
|---|---|---|---|
| **Key Vault** | Access policies, key rotation | HSM management | Audit logging |
| **Security Center** | Policy configuration, remediation | Threat intelligence | Security recommendations |
| **Sentinel** | Analytics rules, playbooks | Platform availability | Data ingestion |

## Compliance Framework Mapping

### ISO 27001:2022 Annex A Control Assignments
| Control Category | Customer Controls | Azure Controls | Shared Controls |
|---|---|---|---|
| **A.5 Information Security Policies** | 5.1.1, 5.1.2 | - | 5.1.1 |
| **A.6 Organization of Information Security** | 6.1.1, 6.1.2, 6.1.3 | - | 6.2.1 |
| **A.7 Human Resource Security** | 7.1.1, 7.1.2, 7.2.1 | 7.2.2, 7.2.3 | 7.3.1 |
| **A.8 Asset Management** | 8.1.1, 8.1.2, 8.1.3 | 8.1.4 | 8.2.1, 8.2.2 |
| **A.9 Access Control** | 9.1.1, 9.1.2, 9.2.1-9.2.6 | - | 9.3.1, 9.4.1-9.4.5 |
| **A.10 Cryptography** | 10.1.1, 10.1.2 | 10.1.3 | 10.1.2 |
| **A.11 Physical and Environmental Security** | 11.1.1, 11.1.2 | 11.1.1-11.2.7 | 11.1.3 |
| **A.12 Operations Security** | 12.1.1-12.1.4, 12.2.1, 12.3.1 | 12.1.2, 12.1.3 | 12.4.1-12.6.2 |
| **A.13 Communications Security** | 13.1.1-13.1.3, 13.2.1-13.2.4 | 13.1.1 | 13.1.2, 13.2.1 |

### SOC 2 Trust Services Criteria
| TSC Category | Customer Responsibility | Azure Responsibility | Evidence Requirements |
|---|---|---|---|
| **CC1.0 Control Environment** | Governance policies, risk management | Corporate governance | Policy documentation |
| **CC2.0 Communication & Information** | Internal communication | Service communication | Communication logs |
| **CC3.0 Risk Assessment** | Customer risk assessment | Platform risk assessment | Risk registers |
| **CC4.0 Monitoring Activities** | Security monitoring config | Platform monitoring | Monitoring reports |
| **CC5.0 Control Activities** | Access controls, change management | Infrastructure controls | Control testing |
| **CC6.0 Logical & Physical Access** | Logical access controls | Physical access controls | Access reviews |
| **CC7.0 System Operations** | Configuration management | System operations | Operational procedures |
| **CC8.0 Change Management** | Change approval processes | Platform change management | Change records |
| **CC9.0 Risk Mitigation** | Vendor risk management | Infrastructure risk mitigation | Risk assessments |

## Operational Procedures

### Regular Review Requirements
| Review Type | Frequency | Responsible Party | Documentation |
|---|---|---|---|
| Responsibility matrix updates | Quarterly | Customer Security Team | Version control |
| Service-specific reviews | As services change | Joint Customer/Azure | Service documentation |
| Compliance alignment review | Annually | Compliance Team | Audit reports |
| Third-party integration review | Bi-annually | Vendor Management | Risk assessments |
| Incident response effectiveness | Post-incident | Security Operations | Lessons learned |

### Escalation Procedures
| Issue Type | L1 Response | L2 Escalation | L3 Escalation | External Escalation |
|---|---|---|---|---|
| **Security Incident** | SOC Team (15 min) | Security Manager (1 hour) | CISO (4 hours) | Azure Support (immediate) |
| **Compliance Violation** | Compliance Analyst (1 hour) | Compliance Manager (4 hours) | Chief Compliance Officer (24 hours) | External Auditor (as required) |
| **Service Outage** | Operations Team (5 min) | Platform Team (30 min) | Engineering Manager (2 hours) | Azure Support (immediate) |
| **Data Breach** | DPO (immediate) | Legal Team (1 hour) | Executive Team (2 hours) | Regulatory bodies (72 hours) |

### Documentation Requirements
| Document Type | Owner | Update Frequency | Version Control | Approval Required |
|---|---|---|---|---|
| Shared Responsibility Matrix | Security Architecture | Quarterly | Git repository | Security Committee |
| Service-specific matrices | Service Teams | As needed | Service documentation | Service Owner |
| Compliance mappings | Compliance Team | Annually | Compliance system | Chief Compliance Officer |
| Risk registers | Risk Management | Monthly | Risk platform | Risk Committee |
| Incident playbooks | Security Operations | Bi-annually | Runbook system | Security Manager |

## Performance Metrics & KPIs

### Security Metrics
| Metric | Target | Measurement | Responsibility |
|---|---|---|---|
| Security incident response time | <2 hours (critical) | Ticket system | Customer SOC |
| Policy compliance rate | >98% | Azure Policy | Customer Governance |
| Vulnerability remediation | <30 days (high) | Vulnerability scanner | Customer Security |
| Access review completion | 100% quarterly | Identity system | Customer IAM |

### Operational Metrics
| Metric | Target | Measurement | Responsibility |
|---|---|---|---|
| Change success rate | >95% | Change management system | Customer Operations |
| Backup success rate | >99.9% | Backup monitoring | Shared |
| Availability SLA | 99.9% | Monitoring platform | Shared |
| Recovery time objective | <4 hours | DR testing | Customer BC/DR |

## Training & Competency Requirements

### Required Training Programs
| Role | Training Requirement | Frequency | Validation |
|---|---|---|---|
| **Cloud Architects** | Azure security architecture | Annually | Certification |
| **DevOps Engineers** | Secure DevOps practices | Bi-annually | Assessment |
| **Security Analysts** | Cloud security monitoring | Quarterly | Hands-on testing |
| **Compliance Officers** | Regulatory requirements | Annually | Audit review |

### Competency Framework
| Level | Description | Requirements | Responsibilities |
|---|---|---|---|
| **Foundation** | Basic cloud security understanding | Azure Fundamentals | Documentation review |
| **Intermediate** | Service-specific security knowledge | Role-based certification | Configuration management |
| **Advanced** | Architecture and design expertise | Expert certification | Architecture decisions |
| **Expert** | Strategic security leadership | Multiple certifications | Strategic planning |

## Exception Management Process

### Exception Categories
| Category | Risk Level | Approval Required | Documentation | Review Frequency |
|---|---|---|---|---|
| **Temporary** | Low-Medium | Security Manager | Risk assessment | Monthly |
| **Business Critical** | Medium-High | CISO | Business justification | Quarterly |
| **Regulatory** | High | Chief Compliance Officer | Legal review | Monthly |
| **Technical Debt** | Medium | Architecture Board | Remediation plan | Quarterly |

### Exception Lifecycle
1. **Request**: Submit via governance portal with business justification
2. **Assessment**: Security and risk team evaluation
3. **Approval**: Appropriate authority approval based on risk level  
4. **Implementation**: Controlled deployment with monitoring
5. **Review**: Regular review and renewal process
6. **Remediation**: Planning and execution of permanent solution

## Change Management Integration

### Change Types
| Change Type | Responsibility Matrix Impact | Approval Process | Documentation Update |
|---|---|---|---|
| **Service Addition** | Matrix extension required | Architecture review | Service-specific section |
| **Service Modification** | Responsibility review | Security assessment | Affected service update |
| **Policy Update** | Compliance mapping review | Policy committee | Control mapping update |
| **Vendor Change** | Third-party section update | Vendor assessment | Integration section |

### Update Procedures
1. **Impact Analysis**: Assess changes to responsibility assignments
2. **Stakeholder Review**: Engage affected teams and business units
3. **Documentation Update**: Revise matrix and supporting materials
4. **Communication**: Notify all stakeholders of changes
5. **Training Update**: Modify training materials as needed
6. **Validation**: Test updated procedures and responsibilities

## Conclusion

This comprehensive shared responsibility matrix provides the foundation for secure, compliant, and well-governed Azure cloud operations. Regular review, continuous improvement, and stakeholder engagement are essential for maintaining its effectiveness and ensuring alignment with evolving business requirements, regulatory changes, and threat landscapes.

For questions or updates to this matrix, contact the Cloud Security Architecture team or submit a change request through the IT Service Management portal.
