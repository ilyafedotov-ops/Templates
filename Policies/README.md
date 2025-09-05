# Azure Policy Guardrails

This folder contains reusable Azure Policy definitions and an initiative aligned to the assessment checklists. Assign the initiative at the management group or subscription level and customize parameters per environment.

## Contents
- `definitions/` – individual policy definitions (custom)
- `initiatives/` – policy set (initiative) bundling definitions with parameters

## Assignment (example)
- Create or select a management group or subscription scope.
- Import definitions, then the initiative, and assign with parameters.

CLI example:

`az policy definition create --name diag-audit --display-name "Audit Diagnostic Settings" --rules @definitions/policy-diagnostic-settings.json --mode All`

`az policy set-definition create --name security-baseline --definitions @initiatives/initiative-azure-security-baseline.json --display-name "Azure Security Baseline"`

`az policy assignment create --name baseline --scope <scopeId> --policy-set-definition security-baseline --params @initiatives/initiative-azure-security-baseline.parameters.json`

Replace `<scopeId>` with your management group or subscription resource ID.

## Built-in Policies (recommended)
- Use Azure built-in policies to cover diagnostics, encryption, network hardening, and identity baseline. Examples of friendly names to search:
  - "Deploy - Configure diagnostic settings to Log Analytics workspace"
  - "Storage accounts should restrict network access"
  - "Storage accounts should have secure transfer required"
  - "Key Vault should have firewall enabled and private endpoint configured"
  - "App Service apps should only be accessible over HTTPS"
  - "SQL managed instances should have TDE enabled"
  - "Kubernetes clusters should have Azure Policy Add-on enabled"

Discover GUIDs for built-ins via CLI:

`az policy definition list --query "[?contains(displayName, 'diagnostic settings')].{name:name,id:id,displayName:displayName}" -o table`

Then add built-in `policyDefinitionId` entries to the initiative (see `initiatives/initiative-azure-security-baseline-with-builtins.json`) replacing placeholder IDs.
