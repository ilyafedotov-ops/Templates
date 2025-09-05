# Architecture Review Checklist

## Core
- Reference Architecture documented and current
- Diagrams: Context, Container, Component, Deployment, Data Flow
- Trust boundaries identified and labeled

## Identity
- Tenant strategy (single vs multi); guests; B2B/B2C
- Conditional Access baseline policies; break-glass controls
- Workload identities (Managed Identity, Workload Identity for AKS)

## Network
- Landing zone topology (hub/spoke or vWAN)
- Ingress/Egress control (WAF, Firewall, NAT, Private Link)
- Segmentation (NSGs/ASGs); DNS (Private DNS Zones)

## Data
- Classification; encryption strategy (PMK/CMK); key rotation
- Data lifecycle (retention, purge); backups and replication
- Egress control for data exfiltration

## Workloads
- AKS baseline (network policy, image governance, secrets, node pools)
- App Services/Functions (VNet integration, private endpoints)
- VM baseline (Arc/Update Manager, endpoint protection)

## Observability
- Diagnostic settings baseline; central Log Analytics
- Sentinel use cases; SOAR playbooks; alerts and on-call
- Cost/health dashboards; capacity planning

## Resilience
- RTO/RPO targets; geo-redundancy; failover patterns
- Chaos/DR exercises; runbooks; auto-healing

## Governance & Compliance
- Policy guardrails; exception process; evidence automation
- Role design and SoD; PIM; access reviews
