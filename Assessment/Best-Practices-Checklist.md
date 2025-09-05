# Azure Security Best Practices Checklist

Mark each item: [ ] Planned [ ] In Progress [ ] Implemented [ ] N/A

## Identity & Access
- [ ] MFA enforced for all users; phishing-resistant for privileged roles
- [ ] Conditional Access baselines (block legacy, device/platform/location)
- [ ] PIM for privileged roles; JIT with approval and logging
- [ ] Use Managed Identity over secrets; Key Vault with RBAC
- [ ] Least privilege RBAC; periodic access reviews

## Governance & Policy
- [ ] Management groups with policy-driven guardrails (CAF landing zone)
- [ ] Azure Policy/AuditDeny for baseline (tagging, regions, diagnostics)
- [ ] Defender for Cloud plans enabled with governance assignments
- [ ] Resource locks for critical assets; subscription spending caps/budgets

## Network Security
- [ ] Hub-spoke with Azure Firewall/Firewall Premium and/or NVA as needed
- [ ] Ingress via WAF (AppGW/Front Door) with TLS 1.2+, cert automation
- [ ] Private endpoints for PaaS; disable public network access
- [ ] NSGs/ASGs with deny by default; DDoS Standard for internet-facing

## Data Protection
- [ ] Encryption at rest with platform keys or CMK (Key Vault/HSM)
- [ ] TLS enforced; Private Link for data plane where supported
- [ ] Backup/restore with tested RPO/RTO; immutable backups where possible
- [ ] Data classification and lifecycle; purge/soft delete enabled

## Monitoring & Response
- [ ] Centralized diagnostic settings to Log Analytics/Storage/Event Hub
- [ ] Sentinel deployed with core detections; use-case tuning and SOAR
- [ ] Alert routing with on-call; tested runbooks (IR/BCDR)
- [ ] Threat intelligence and UEBA enabled where applicable

## DevSecOps
- [ ] Signed commits/PR policies; CODEOWNERS and branch protections
- [ ] SAST/DAST/Secrets/IaC scanning with quality gates
- [ ] Policy-as-code (OPA/Conftest) and Azure Policy checks in CI
- [ ] SBOM generation and artifact signing (e.g., Sigstore Cosign)
- [ ] ACR content trust and scan on push/pull; base image governance

## Platform & Workloads
- [ ] AKS: Azure CNI, network policies, pod identity/Workload Identity, secrets
- [ ] VMs: Azure Arc/Update Manager, endpoint protection, disk encryption
- [ ] App Services/Functions: VNet integration, private endpoints, managed identities
- [ ] Storage/Databases: firewall, private endpoints, soft delete, versioning

## Compliance & Operations
- [ ] Evidence mapped to controls with owners and review cadence
- [ ] Exception/waiver process with expiration and risk acceptance
- [ ] Automation for drift detection and remediation (Azure Automation/Functions)

