# Azure Architect Security Checklist

## Landing Zone & Governance
- [ ] Management groups aligned to CAF; subscription design by workload/zone
- [ ] Policy-driven guardrails; deny/modify effects for critical controls
- [ ] Role design and segregation of duties; PIM for elevated roles

## Identity
- [ ] Entra ID Conditional Access baselines and hardened break-glass accounts
- [ ] B2B/B2C design where applicable; external access governance
- [ ] Privileged access workstation strategy for admins

## Network & Connectivity
- [ ] Hub-spoke or vWAN architecture documented; egress control through firewall
- [ ] Private Link strategy for PaaS; disable public network access by default
- [ ] DDoS Standard for internet-facing; WAF in front of apps

## Data & Keys
- [ ] Encryption strategy (PMK/CMK); Key Vault/HSM design; rotation policies
- [ ] Data classification and lifecycle enforcement; soft delete/immutability

## Monitoring & IR
- [ ] Diagnostic settings baseline; Log Analytics architecture; cost controls
- [ ] Sentinel SIEM with prioritized detections and SOAR playbooks
- [ ] Incident response plan and tabletop exercises

## Platform Services
- [ ] AKS baseline (networking, identity, upgrade/patch, add-ons)
- [ ] App Services/Functions with private endpoints and MSI
- [ ] Storage/Databases with firewalls, encryption, backups, replication

## Compliance by Design
- [ ] Control mappings (ISO 27001, SOC 2, MCSB) documented with owners
- [ ] Evidence capture automated where feasible (workbooks, exports, APIs)
