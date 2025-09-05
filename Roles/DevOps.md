# DevOps Security Checklist

Use across the SDLC. Mark: [ ] Planned [ ] In Progress [ ] Implemented [ ] N/A

## Plan & Code
- [ ] Repo protections: branch policies, required reviews, status checks
- [ ] Signed commits; CODEOWNERS; secret scanning in repos
- [ ] Dependency scanning; renovate/bot PRs; allowlist base images

## Build
- [ ] Build isolation and minimal permissions (OIDC to cloud; no long-lived secrets)
- [ ] SAST and license scans with blocking gates
- [ ] SBOM generated (CycloneDX) and attached to artifacts

## Test
- [ ] DAST on preview/staging; fuzzing for APIs where applicable
- [ ] IaC scanning (Bicep/Terraform/ARM) and drift checks
- [ ] Container scan (ACR/Trivy) with severity gates

## Release
- [ ] Artifact signing (Sigstore Cosign) and provenance attestations
- [ ] Environment promotion via pull requests; manual approval for prod
- [ ] Change tickets auto-linked; risk categorization in pipeline

## Deploy
- [ ] Identity: Managed Identity; avoid secrets; Key Vault references
- [ ] Policy-as-code checks (OPA/Conftest) and Azure Policy eval in CI
- [ ] Blue/green or canary patterns; rollback automation

## Operate
- [ ] Continuous compliance dashboards (Defender for Cloud, Policy)
- [ ] Runtime protection (Defender for Containers/Servers)
- [ ] Log shipping defaults; alerts to on-call; tested runbooks

## Access & Secrets
- [ ] PIM for pipeline/service principals; JIT; short tokens via OIDC
- [ ] Secret rotation and inventory; prevent secret sprawl

## AKS specifics
- [ ] Workload Identity; network policies; PSP successor (Pod Security Admission)
- [ ] Image pull from trusted ACR; admission control policies; no :latest
- [ ] Node OS hardening/patching; Azure Policy for AKS add-ons

