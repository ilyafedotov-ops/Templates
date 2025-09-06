# Azure Security Assessment Templates

A comprehensive enterprise-grade security assessment and monitoring platform with 186+ files providing templates, tools, and automation for Azure security assessments aligned with ISO/IEC 27001, SOC 2, and Azure security best practices.

## 🎯 Purpose & Benefits

This repository provides a complete framework for:
- **Security Assessments**: Structured approach to evaluate Azure cloud security posture
- **Compliance Alignment**: Pre-mapped controls for ISO 27001, SOC 2, and MCSB
- **Automated Security**: Deploy Azure Policy, Sentinel rules with ML-powered detection
- **Risk Management**: Identify, track, and remediate security risks systematically
- **Evidence Collection**: Streamlined process for audit evidence and documentation
- **Multi-Platform CI/CD**: Support for GitHub Actions, Azure DevOps, GitLab CI
- **Advanced Threat Detection**: 51+ Sentinel components with MITRE ATT&CK mapping

## 🚀 Quick Start

### Prerequisites
- Azure CLI (>= 2.50.0)
- jq (JSON processor)
- Azure subscription with Owner/Contributor access
- Log Analytics workspace (for Sentinel deployment)
- Git and GitHub CLI (for CI/CD pipelines)

### Basic Deployment
```bash
# Clone the repository
git clone https://github.com/your-org/azure-security-assessment-templates.git
cd azure-security-assessment-templates

# Deploy security baseline
./Scripts/deploy-baseline.sh \
  --resource-group "rg-security-assessment" \
  --workspace "law-security-001" \
  --location "eastus2"
```

For detailed deployment instructions, see [Scripts/README.md](Scripts/README.md).

## 📂 Repository Structure

### Core Documentation
| File | Purpose |
|------|---------|
| `README.md` | Main repository documentation |
| `ARCHITECTURE.md` | Solution architecture overview |
| `CLAUDE.md` | AI-assisted development guidelines |
| `FAQ.md` | Frequently asked questions |
| `QUICK-START.md` | Quick start guide for new users |

### Assessment Components
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Assessment/` (9 files) | Planning and execution templates | Assessment-Plan.md, Questionnaire.md, Methodology.md, Architecture-Review-Checklist.md, Scoring-Model.md |
| `Roles/` (3 files) | Role-specific checklists | DevOps.md, Azure-Architect.md, RACI-Matrix.md |
| `Artifacts/` (6 files) | Risk and remediation artifacts | Risk-Register.csv, Threat-Model.md, Remediation-Plan.md, Evidence-Log.csv, Sampling-Plan.md |
| `Report/` (2 files) | Assessment reporting templates | Final-Report.md, Findings-Template.md |

### Compliance & Standards
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Compliance/ISO27001/` (4 files) | ISO 27001 control mapping | AnnexA-Controls-Full.csv, AnnexA-Mapping.csv, SoA-Template.md, ISMS-Scope-Template.md |
| `Compliance/SOC2/` (5 files) | SOC 2 TSC mapping | TSC-Controls-Full.csv, TSC-Mapping.csv, Evidence-Request-List.md, Test-Procedures.md, Control-Narrative-Template.md |
| `BestPractices/` (1 file) | MCSB alignment | MCSB-Mapping.md |
| `Standards/` (3 files) | Security standards documentation | DevSecOps-Standard.md, Data-Protection-Standard.md, Logging-Monitoring-Standard.md |

### Security Implementation
| Directory | Purpose | Key Files/Subdirs |
|-----------|---------|-----------|
| `Policies/` (11 files) | Azure Policy definitions | definitions/ (7 policies), initiatives/ (3 initiatives), README.md |
| `Sentinel/` (51 files) | Advanced security monitoring | See detailed Sentinel structure below |
| `Checklists/` (2 files) | Technical review checklists | IaC-Review.md, AKS-Hardening-Checklist.md |
| `Runbooks/` (5 files) | Operational procedures | Incident-Response-Playbook.md, Key-Management-Procedure.md, Vulnerability-Management-Procedure.md, Access-Review-Procedure.md, Change-Management-Procedure.md |

### Sentinel Security Platform (51 files)
| Component | Purpose | Count |
|-----------|---------|-------|
| `analytics-rules/` | ML-powered threat detection rules | 7 files |
| `threat-scenarios/` | Scenario-based security monitoring | 8 files |
| `data-connectors/` | Azure, O365, AWS, GCP connectors | 12 files |
| `deployment/` | IaC with Terraform, ARM, PowerShell | 10 files |
| `playbooks/` | Automated incident response | 3 files |
| `automation-rules/` | Intelligent incident classification | 1 file |
| `monitoring/` | Health, cost, performance monitoring | 4 files |
| `investigation-workbooks/` | Security dashboards with ML insights | 1 file |
| `parsers/` | Custom log normalization | 1 file |
| `watchlists/` | Threat intelligence IOCs | 1 file |
| Documentation | README.md, SECURITY-MONITORING-FRAMEWORK.md | 2 files |

### Automation & CI/CD (74+ files)
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Scripts/` (3 files) | Deployment automation | deploy-baseline.sh, resolve-builtins.sh, README.md |
| `Pipelines/azure-devops/` (8 files) | Azure DevOps pipelines | Multiple specialized pipelines |
| `Pipelines/github-actions/` (46 files) | GitHub Actions workflows | Comprehensive security automation |
| `Pipelines/gitlab-ci/` (6 files) | GitLab CI pipelines | Enterprise CI/CD templates |
| `Pipelines/templates/` (10 files) | Reusable pipeline templates | Cross-platform components |
| `.github/workflows/` (4 files) | GitHub Actions | secure-ci.yml, deploy-gated.yml, deploy-verify.yml, policy-gate.yml |

### Additional Components
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Branding/` (2 files) | Branding configuration | branding.yaml, README.md |

## 🔧 Key Features

### Security Scanning & Validation
- **Infrastructure as Code (IaC) Scanning**: Checkov for Terraform/Bicep/ARM
- **Container Security**: Trivy vulnerability scanning & Cosign signing
- **Secret Detection**: Gitleaks integration
- **Code Analysis**: CodeQL multi-language support
- **SBOM Generation**: Syft with CycloneDX format

### Policy as Code
- **Custom Policies**: 15+ pre-built Azure Policy definitions
- **Policy Initiatives**: Bundled security controls
- **Compliance Scoring**: Built-in assessment scoring model
- **Automated Remediation**: Policy effects with remediation tasks

### Advanced Security Monitoring (Sentinel - 51 files)
- **ML-Powered Analytics**: 7+ advanced detection rules with behavioral analysis
- **Threat Scenarios**: 8 scenario-based monitoring patterns (identity, data exfiltration, ransomware, insider threats)
- **Multi-Cloud Integration**: 12 data connectors for Azure, AWS, GCP, O365
- **Automated Response**: SOAR playbooks with intelligent incident classification
- **Deployment Automation**: Terraform, ARM templates, PowerShell scripts
- **Operational Excellence**: Health monitoring, cost optimization, performance baselines

## 📋 Assessment Workflow

### Phase 1: Planning
1. **Define Scope**: Use `Assessment/Assessment-Plan.md` to document assessment boundaries
2. **Identify Stakeholders**: Complete `Roles/RACI-Matrix.md` for clear responsibilities
3. **Select Framework**: Choose compliance requirements (ISO 27001, SOC 2, or both)

### Phase 2: Discovery
1. **Questionnaire**: Distribute `Assessment/Questionnaire.md` to stakeholders
2. **Architecture Review**: Use `Assessment/Architecture-Review-Checklist.md`
3. **Technical Assessment**: Apply role-specific checklists from `Roles/`

### Phase 3: Implementation
1. **Deploy Security Baseline**:
   ```bash
   ./Scripts/deploy-baseline.sh --scope "/subscriptions/{subscription-id}"
   ```
2. **Configure Monitoring**: Deploy Sentinel rules and workbooks
3. **Enable CI/CD Security**: Implement pipeline security gates

### Phase 4: Validation
1. **Control Testing**: Follow procedures in `Assessment/Control-Test-Procedures.md`
2. **Risk Assessment**: Document in `Artifacts/Risk-Register.csv`
3. **Evidence Collection**: Use `Compliance/SOC2/Evidence-Request-List.md`

### Phase 5: Reporting
1. **Document Findings**: Use `Report/Findings-Template.md`
2. **Create Remediation Plan**: Complete `Artifacts/Remediation-Plan.md`
3. **Executive Summary**: Prepare `Assessment/Executive-Summary.md`
4. **Final Report**: Generate using `Report/Final-Report.md`

## 🛡️ Security Controls Coverage

### ISO 27001:2022 Annex A
- ✅ 93 controls mapped with implementation guidance
- ✅ Statement of Applicability template
- ✅ ISMS scope definition template
- ✅ Evidence request procedures

### SOC 2 Trust Services Criteria
- ✅ All 5 TSC categories covered (CC, A, C, PI, P)
- ✅ 60+ detailed control activities
- ✅ Test procedures for each criterion
- ✅ Evidence collection templates

### Microsoft Cloud Security Benchmark (MCSB)
- ✅ 11 security domains mapped
- ✅ Azure-specific control implementations
- ✅ Automated compliance validation
- ✅ Continuous monitoring capabilities

## 🔐 Advanced Features

### Multi-Environment Support
- Development, staging, and production configurations
- Environment-specific policy parameters
- Role-based access control templates
- Network segmentation patterns

### Multi-Platform CI/CD Support
- **GitHub Actions**: 46+ workflow templates with security scanning
- **Azure DevOps**: 8 specialized pipelines with approval gates
- **GitLab CI**: 6 enterprise pipeline templates
- **Jenkins**: Template structure for Jenkins integration
- **Reusable Templates**: 10 cross-platform pipeline components

### Integration Capabilities
- **Azure DevOps**: Work item creation, pipeline integration
- **Microsoft Teams**: Security alerts and notifications
- **GitHub**: Actions workflows, security scanning
- **Azure Monitor**: Log Analytics queries, alerts
- **Multi-Cloud**: AWS CloudTrail, GCP Audit Log integration

### Compliance Reporting
- Automated compliance score calculation
- Control effectiveness metrics
- Risk heat maps and dashboards
- Audit-ready documentation

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Solution architecture and design patterns |
| [QUICK-START.md](QUICK-START.md) | Quick start guide for new users |
| [FAQ.md](FAQ.md) | Frequently asked questions and troubleshooting |
| [Scripts/README.md](Scripts/README.md) | Deployment script documentation |
| [Pipelines/README.md](Pipelines/README.md) | Multi-platform CI/CD pipeline configuration |
| [Compliance/README.md](Compliance/README.md) | Compliance framework guidance |
| [Policies/README.md](Policies/README.md) | Azure Policy implementation guide |
| [Sentinel/README.md](Sentinel/README.md) | Security monitoring platform documentation |
| [Sentinel/SECURITY-MONITORING-FRAMEWORK.md](Sentinel/SECURITY-MONITORING-FRAMEWORK.md) | Comprehensive security monitoring framework |
| [Branding/README.md](Branding/README.md) | Branding and customization guide |

## 🤝 Contributing

We welcome contributions! Please see our contribution guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/your-org/azure-security-assessment-templates/issues)
- **Documentation**: Check our [comprehensive docs](docs/)
- **Community**: Join discussions in [GitHub Discussions](https://github.com/your-org/azure-security-assessment-templates/discussions)

## 🏆 Acknowledgments

- Microsoft Cloud Security Benchmark team
- Azure Policy and Sentinel product teams
- Open-source security tool maintainers (Checkov, Trivy, Gitleaks)
- Community contributors and security practitioners

---

**Note**: This repository provides templates and automation for security assessments. Always customize implementations based on your specific organizational requirements and compliance obligations.
