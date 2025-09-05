# CLAUDE.md

This file provides comprehensive guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an enterprise-grade Azure Security Assessment Templates repository that provides comprehensive templates, checklists, and automation for conducting security assessments aligned to ISO/IEC 27001:2022, SOC 2 Type II, and Azure security best practices. The repository serves as a complete framework for DevOps engineers and Azure architects to implement, validate, and maintain security controls in Azure environments.

## Prerequisites & Environment Setup

### Required Tools
- **Azure CLI**: Version >= 2.50.0 (for policy and resource deployment)
- **jq**: Latest version (for JSON processing in scripts)
- **GitHub CLI**: Version >= 2.0 (for PR creation and workflow management)
- **Docker**: Version >= 20.10 (for container scanning and signing)
- **Terraform**: Version >= 1.5.0 (optional, for IaC deployments)
- **PowerShell**: Version >= 7.0 (for Azure-specific scripts)

### Azure Prerequisites
- Azure subscription with Owner or Contributor+User Access Administrator roles
- Azure Log Analytics workspace (for Sentinel deployment)
- Azure Key Vault (for secrets management)
- Azure Container Registry (for container image storage)
- Management Group structure (for policy assignments at scale)

### Environment Variables
```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"
export LOG_ANALYTICS_WORKSPACE_ID="/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/..."
export KEY_VAULT_NAME="kv-security-001"
export ACR_NAME="acrsecurity001"
```

## Key Commands & Operations

### Deployment Scripts
- **Full Security Baseline Deployment**:
  ```bash
  ./Scripts/deploy-baseline.sh \
    --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
    --resource-group "rg-security-assessment" \
    --workspace "law-security-001" \
    --location "eastus2" \
    --include-builtins true
  ```
  - Deploys: Custom policies, initiatives, assignments, Sentinel analytics, playbooks
  - Duration: ~15-20 minutes
  - Prerequisites: az login, appropriate RBAC permissions

- **Policy-Only Deployment**:
  ```bash
  ./Scripts/deploy-policies.sh \
    --definition-path "./Policies/definitions" \
    --initiative-path "./Policies/initiatives" \
    --assignment-scope "/providers/Microsoft.Management/managementGroups/mg-root"
  ```

- **Sentinel Configuration**:
  ```bash
  ./Scripts/deploy-sentinel.sh \
    --workspace-id "${LOG_ANALYTICS_WORKSPACE_ID}" \
    --resource-group "rg-security-ops" \
    --analytics-rules "./Sentinel/analytics/*.json" \
    --playbooks "./Sentinel/playbooks/*.json"
  ```

### CI/CD Pipelines
- **GitHub Actions**: Located in `.github/workflows/`
  - `secure-ci.yml` - Main CI pipeline with security scanning
    - Triggers: Push to main, PR creation
    - Security tools: Checkov, Trivy, Gitleaks, CodeQL
    - Gates: Fails on HIGH/CRITICAL vulnerabilities
  - `deploy-gated.yml` - Production deployment with approval gates
  - `deploy-verify.yml` - Post-deployment validation
  - `policy-gate.yml` - Policy compliance validation

- **Azure DevOps**: Located in `Pipelines/azure-devops/`
  - `azure-pipelines.yml` - Main pipeline with security gates
  - `templates/security-scan.yml` - Reusable security scanning template
  - `templates/deploy-infrastructure.yml` - Infrastructure deployment template

## Architecture & Structure

### Assessment Components
- **Assessment Planning** (`Assessment/`)
  - `Assessment-Plan.md`: Comprehensive assessment planning template
  - `Questionnaire.md`: Stakeholder questionnaire for discovery
  - `Context-and-Scope.md`: Boundary and scope definition
  - `Executive-Summary.md`: High-level findings summary
  - `Methodology.md`: Assessment methodology documentation
  - `Architecture-Review-Checklist.md`: Technical architecture review
  - `Control-Test-Procedures.md`: Detailed control testing procedures
  - `Scoring-Model.md`: Risk and compliance scoring methodology
  - `Best-Practices-Checklist.md`: Azure security best practices validation

- **Compliance Mapping** (`Compliance/`)
  - **ISO27001/**: ISO 27001:2022 Annex A control mappings
    - `Annex-A-Controls.xlsx`: Full control matrix with Azure implementations
    - `SoA-Template.md`: Statement of Applicability template
    - `ISMS-Scope-Template.md`: ISMS boundary definition
  - **SOC2/**: SOC 2 Trust Services Criteria mappings
    - `TSC-Control-Mapping.xlsx`: Complete TSC control matrix
    - `Evidence-Request-List.md`: Structured evidence collection
    - `Test-Procedures.md`: SOC 2 control testing procedures

- **Role-Specific Resources** (`Roles/`)
  - `DevOps.md`: DevOps engineer security checklist
  - `Azure-Architect.md`: Azure architect design review checklist
  - `RACI-Matrix.md`: Responsibility assignment matrix

- **Security Artifacts** (`Artifacts/`)
  - `Risk-Register.csv`: Risk tracking and management
  - `Threat-Model.md`: Application threat modeling template
  - `Remediation-Plan.md`: Finding remediation tracking
  - `Shared-Responsibility-Matrix.md`: Cloud responsibility model
  - `Sampling-Plan.md`: Control testing sampling methodology

### Security Implementation

- **Policy Definitions** (`Policies/definitions/`)
  Custom Azure Policy JSON definitions:
  - `audit-diagnostic-settings.json`: Ensure diagnostic logging
  - `deny-location.json`: Restrict resource locations
  - `require-tags.json`: Enforce tagging standards
  - `storage-disable-public-access.json`: Prevent public blob access
  - `storage-require-private-endpoints.json`: Enforce private connectivity
  - `storage-require-secure-transfer.json`: Mandate HTTPS
  - `app-service-minimum-tls.json`: Enforce TLS 1.2+
  - `sql-auditing-enabled.json`: SQL audit logging
  - `key-vault-purge-protection.json`: Prevent key deletion
  - `network-watcher-enabled.json`: Network monitoring

- **Policy Initiatives** (`Policies/initiatives/`)
  - `security-baseline.json`: Bundled security controls
  - `compliance-iso27001.json`: ISO 27001 aligned policies
  - `compliance-soc2.json`: SOC 2 aligned policies

- **Sentinel Security** (`Sentinel/`)
  - **Analytics Rules** (`analytics/`): 10+ threat detection rules
    - Brute force detection
    - Privilege escalation monitoring
    - Anomalous resource access
    - Data exfiltration patterns
  - **Playbooks** (`playbooks/`): Automated response workflows
    - Teams notification on high-severity incidents
    - Azure DevOps work item creation
    - AD user account disable on compromise
    - Automated evidence collection
  - **Workbooks** (`workbooks/`): Security dashboards
    - Security posture overview
    - Compliance status tracking
    - Incident metrics and trends

### Operational Components

- **Runbooks** (`Runbooks/`)
  - `Incident-Response-Playbook.md`: Step-by-step IR procedures
  - `Vulnerability-Management-Procedure.md`: Vuln lifecycle management
  - `Key-Management-Procedure.md`: Cryptographic key handling
  - `Access-Review-Procedure.md`: Periodic access validation
  - `Change-Management-Procedure.md`: Change control process

- **Standards** (`Standards/`)
  - `DevSecOps-Standards.md`: Secure development practices
  - `Data-Protection-Standards.md`: Data classification and handling
  - `Logging-Monitoring-Standards.md`: Observability requirements

- **Checklists** (`Checklists/`)
  - `IaC-Review.md`: Infrastructure as Code security review
  - `AKS-Hardening-Checklist.md`: Kubernetes security hardening

## Security Scanning Tools

### Integrated Security Toolchain
| Tool | Purpose | Configuration | Threshold |
|------|---------|---------------|-----------|
| **Checkov** | IaC scanning | `.checkov.yml` | Fails on HIGH/CRITICAL |
| **Trivy** | Vulnerability scanning | `.trivyignore` | Fails on CRITICAL (configurable) |
| **Gitleaks** | Secret detection | `.gitleaks.toml` | Zero tolerance |
| **CodeQL** | Code analysis | `.github/codeql-config.yml` | Security queries only |
| **Syft** | SBOM generation | Auto-configured | CycloneDX format |
| **Cosign** | Container signing | Keyless mode | All images signed |
| **OWASP ZAP** | DAST scanning | `.zap/rules.conf` | Medium+ findings |

### Security Gates Configuration
```yaml
# Pipeline environment variables
ALLOW_HIGH_VULNS: false  # Set to true to allow HIGH vulnerabilities
SECURITY_SCAN_TIMEOUT: 30  # Minutes before scan timeout
SBOM_OUTPUT_FORMAT: cyclonedx-json
CONTAINER_REGISTRY: acrsecurity001.azurecr.io
```

## Key Security Features

### 1. Policy-as-Code Implementation
- **Custom Policies**: 15+ Azure Policy definitions
- **Built-in Integration**: 50+ built-in policies referenced
- **Deployment Modes**: Audit, Deny, DeployIfNotExists, Modify
- **Scope Flexibility**: Subscription, Management Group, Resource Group
- **Exemption Management**: Structured exemption tracking

### 2. Security Gates & Controls
- **Pre-commit Hooks**: Local security validation
- **PR Validation**: Automated security checks on pull requests
- **Deployment Gates**: Manual approval for production
- **Compliance Validation**: Policy compliance before merge
- **Rollback Capability**: Automated rollback on failures

### 3. Supply Chain Security
- **SBOM Generation**: Every build produces software bill of materials
- **Container Signing**: Cryptographic signatures for all images
- **Dependency Scanning**: Vulnerable dependency detection
- **License Compliance**: Open source license validation
- **Artifact Attestation**: Provenance tracking

### 4. Automated Response Capabilities
- **Incident Creation**: Auto-create incidents in ITSM
- **User Remediation**: Disable compromised accounts
- **Network Isolation**: Quarantine suspicious resources
- **Evidence Collection**: Automated forensics gathering
- **Stakeholder Notification**: Multi-channel alerting

### 5. Compliance Alignment
- **ISO 27001:2022**: Full Annex A control coverage
- **SOC 2 Type II**: All TSC criteria mapped
- **MCSB**: Microsoft Cloud Security Benchmark alignment
- **CIS Azure**: CIS Azure Foundations Benchmark
- **PCI DSS**: Payment card security considerations

## Assessment Workflow

### Phase 1: Planning & Preparation
1. **Scope Definition**: Document in `Assessment/Context-and-Scope.md`
2. **Team Assembly**: Complete `Roles/RACI-Matrix.md`
3. **Framework Selection**: Choose ISO 27001, SOC 2, or hybrid
4. **Timeline Planning**: Define milestones in `Assessment/Assessment-Plan.md`
5. **Tool Preparation**: Deploy baseline security controls

### Phase 2: Discovery & Analysis
1. **Stakeholder Interviews**: Use `Assessment/Questionnaire.md`
2. **Architecture Review**: Apply `Assessment/Architecture-Review-Checklist.md`
3. **Technical Assessment**: Execute role-specific checklists
4. **Policy Analysis**: Review existing policies against templates
5. **Risk Identification**: Initial population of `Artifacts/Risk-Register.csv`

### Phase 3: Implementation & Testing
1. **Deploy Security Baseline**:
   ```bash
   ./Scripts/deploy-baseline.sh --scope "/subscriptions/${SUBSCRIPTION_ID}"
   ```
2. **Configure Monitoring**: Deploy Sentinel rules and workbooks
3. **Enable CI/CD Security**: Implement pipeline gates
4. **Control Testing**: Execute `Assessment/Control-Test-Procedures.md`
5. **Evidence Collection**: Gather per `Compliance/SOC2/Evidence-Request-List.md`

### Phase 4: Validation & Verification
1. **Control Effectiveness**: Validate control implementation
2. **Risk Assessment**: Complete risk scoring and heat mapping
3. **Compliance Gaps**: Identify control deficiencies
4. **Remediation Planning**: Develop action plans
5. **Stakeholder Review**: Present preliminary findings

### Phase 5: Reporting & Closure
1. **Finding Documentation**: Use `Report/Findings-Template.md`
2. **Remediation Plan**: Complete `Artifacts/Remediation-Plan.md`
3. **Executive Summary**: Prepare `Assessment/Executive-Summary.md`
4. **Final Report**: Generate `Report/Final-Report.md`
5. **Knowledge Transfer**: Document lessons learned

## Common Operations

### Adding New Policy Definitions
1. Create policy JSON in `Policies/definitions/`
2. Add to initiative in `Policies/initiatives/`
3. Update deployment script parameters
4. Test in non-production environment
5. Document in policy README

### Customizing Sentinel Rules
1. Modify rule JSON in `Sentinel/analytics/`
2. Adjust severity and frequency as needed
3. Update playbook associations
4. Test detection logic
5. Document changes

### Extending Compliance Mappings
1. Add controls to appropriate Excel matrix
2. Update evidence request templates
3. Create test procedures
4. Link to implementation artifacts
5. Update compliance README

## Troubleshooting Guide

### Common Issues & Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Policy deployment fails | "PolicyAssignmentNotFound" | Ensure management group hierarchy exists |
| Sentinel rules not triggering | No incidents created | Check Log Analytics data ingestion |
| Pipeline security scan timeout | Build fails after 30 min | Increase SECURITY_SCAN_TIMEOUT |
| Container signing fails | "Keyless signing error" | Verify OIDC token availability |
| Compliance score incorrect | Metrics don't match | Refresh policy compliance data |

### Debug Commands
```bash
# Check policy compliance state
az policy state list --resource-group "rg-security"

# Validate Sentinel rule syntax
az sentinel alert-rule validate --resource-group "rg-ops" --workspace-name "law-001"

# Test pipeline locally
act -j security-scan --secret-file .env

# Verify container signatures
cosign verify --certificate-identity-regexp ".*" "${ACR_NAME}.azurecr.io/app:latest"
```

## Best Practices & Recommendations

### Security Implementation
1. Start with audit mode for policies before enforcing
2. Implement controls incrementally, not all at once
3. Test in non-production before production deployment
4. Maintain exemption documentation for compliance
5. Regular control effectiveness reviews (quarterly)

### Assessment Execution
1. Engage stakeholders early and often
2. Document assumptions and limitations clearly
3. Prioritize high-risk findings for remediation
4. Provide actionable recommendations
5. Include positive findings, not just gaps

### Maintenance & Operations
1. Update templates quarterly for new threats
2. Review and refresh compliance mappings annually
3. Automate evidence collection where possible
4. Maintain runbook currency through exercises
5. Track metrics for continuous improvement

## Important Notes

- Templates require customization for each organization
- Not all controls may apply to every environment
- Compliance is a shared responsibility in cloud
- Regular updates needed for evolving threats
- Professional services recommended for initial setup