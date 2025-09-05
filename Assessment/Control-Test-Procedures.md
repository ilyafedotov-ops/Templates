# Control Test Procedures

Use this as a starting point. Tailor sampling and tests to scope and risk.

## Identity & Access
- Conditional Access: Export policies; verify MFA for all users; test exclusions; sample 5 privileged roles.
- Privileged Access: Review PIM settings; check approval, JIT duration, notifications; sample 10 activations.
- Access Reviews: Verify quarterly reviews for groups and privileged roles; sample 5 reviews; check remediation evidence.
- Break-glass Accounts: Verify existence, monitoring, and vaulting; test sign-in alerts.

## Governance & Policy
- Management Groups: Confirm hierarchy matches landing zone design; check inherited policy.
- Azure Policy: Export compliance summary; sample 10 noncompliant resources and validate exceptions.
- Defender for Cloud: Verify plan enablement; review Secure Score; sample 10 high severity recommendations.

## Network Security
- Perimeter: Validate WAF in front of internet apps; test HTTPS only and TLS 1.2+.
- Segmentation: Review hub/spoke; NSGs/ASGs; sample 5 NSGs for least privilege rules.
- Private Access: Ensure Private Endpoints for PaaS; sample 5 storage/SQL instances.
- DDoS: Confirm DDoS Standard on critical vnets; review telemetry.

## Data Protection
- Encryption: Confirm at-rest encryption; CMK where required; sample 5 data stores.
- Key Management: Validate Key Vault design; soft delete, purge protection, RBAC; review key rotation policies.
- Backups: Review RPO/RTO; sample 3 restore tests; verify immutability/retention.

## Logging & Monitoring
- Diagnostic Settings: Confirm centralized logs; sample 10 critical resources for diagnostic settings.
- Sentinel: Verify connectors, rules enabled, incident handling; sample 3 incidents for end-to-end response.
- Alerts: Check routing and on-call schedules; test at least 1 alert end-to-end.

## DevSecOps
- SCM: Branch protections, signed commits, CODEOWNERS; sample 3 repos.
- CI: SAST/Secrets/IaC scans; gates configured; review SARIF history.
- Containers: Image scanning, provenance/signing, base image governance; sample 2 services.
- CD: Policy gates (Azure Policy, signature verification); manual approval for prod; rollback strategy.
