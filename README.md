# Azure Security Assessment Templates

A comprehensive repository of templates, tools, and automation for conducting enterprise-grade Azure security assessments aligned with ISO/IEC 27001, SOC 2, and Azure security best practices.

## 🎯 Purpose & Benefits

This repository provides a complete framework for:
- **Security Assessments**: Structured approach to evaluate Azure cloud security posture
- **Compliance Alignment**: Pre-mapped controls for ISO 27001, SOC 2, and MCSB
- **Automated Security**: Deploy Azure Policy, Sentinel rules, and security baselines
- **Risk Management**: Identify, track, and remediate security risks systematically
- **Evidence Collection**: Streamlined process for audit evidence and documentation

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

### Assessment Components
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Assessment/` | Planning and execution templates | Assessment-Plan.md, Questionnaire.md, Methodology.md |
| `Roles/` | Role-specific checklists | DevOps.md, Azure-Architect.md, RACI-Matrix.md |
| `Artifacts/` | Risk and remediation artifacts | Risk-Register.csv, Threat-Model.md, Remediation-Plan.md |
| `Report/` | Assessment reporting templates | Final-Report.md, Findings-Template.md |

### Compliance & Standards
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Compliance/ISO27001/` | ISO 27001 control mapping | Annex-A-Controls.xlsx, SoA-Template.md |
| `Compliance/SOC2/` | SOC 2 TSC mapping | TSC-Control-Mapping.xlsx, Evidence-Request-List.md |
| `BestPractices/` | MCSB alignment | MCSB-Mapping.md |
| `Standards/` | Security standards documentation | DevSecOps-Standards.md, Data-Protection-Standards.md |

### Security Implementation
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Policies/` | Azure Policy definitions | definitions/*.json, initiatives/*.json |
| `Sentinel/` | Security monitoring | analytics/*.json, playbooks/*.json, workbooks/*.json |
| `Checklists/` | Technical review checklists | IaC-Review.md, AKS-Hardening-Checklist.md |
| `Runbooks/` | Operational procedures | Incident-Response-Playbook.md, Key-Management-Procedure.md |

### Automation & CI/CD
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Scripts/` | Deployment automation | deploy-baseline.sh, validate-policies.sh |
| `Pipelines/` | Azure DevOps pipelines | azure-pipelines.yml |
| `.github/workflows/` | GitHub Actions | secure-ci.yml, deploy-gated.yml |

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

### Security Monitoring (Sentinel)
- **Analytics Rules**: 10+ detection rules for threats
- **Automated Playbooks**: Teams notification, ADO work items, AD user disable
- **Security Workbooks**: Visual dashboards for monitoring
- **Incident Response**: Integrated IR procedures

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

### Integration Capabilities
- **Azure DevOps**: Work item creation, pipeline integration
- **Microsoft Teams**: Security alerts and notifications
- **GitHub**: Actions workflows, security scanning
- **Azure Monitor**: Log Analytics queries, alerts

### Compliance Reporting
- Automated compliance score calculation
- Control effectiveness metrics
- Risk heat maps and dashboards
- Audit-ready documentation

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Scripts/README.md](Scripts/README.md) | Deployment script documentation |
| [Pipelines/README.md](Pipelines/README.md) | CI/CD pipeline configuration |
| [Compliance/README.md](Compliance/README.md) | Compliance framework guidance |

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
