# Secure CI Templates

Example pipelines for GitHub Actions and Azure DevOps that implement SAST, IaC scanning, container scanning, SBOM generation, and artifact signing. Tailor tools and thresholds to your tech stack.

Contents:
- `github-actions/secure-ci.yml`
- `azure-devops/azure-pipelines.yml`

## GHCR Push and Signature Verification
- `secure-ci.yml` builds, scans, signs, and pushes images to GHCR when a `Dockerfile` exists.
- Requires `GITHUB_TOKEN` permissions (default) for GHCR push.
- Signature verification is in `deploy-verify.yml` (manual trigger) using Cosign keyless.

## Policy Gate
- `policy-gate.yml` checks Azure Policy compliance at a scope and fails if noncompliance exceeds a threshold.
- Configure repository secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` for OIDC.

## Enforcement Gates (SARIF)
- GitHub and Azure DevOps pipelines parse SARIF outputs and fail if findings exist (override with `ALLOW_HIGH_VULNS=true`).
