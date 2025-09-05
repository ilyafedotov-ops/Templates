#!/usr/bin/env bash
set -euo pipefail

# Resolve Azure built-in policy IDs and replace placeholders in the initiative file.
# Requires: az CLI, jq

INIT_IN="Policies/initiatives/initiative-azure-security-baseline-with-builtins.json"
INIT_OUT="Policies/initiatives/initiative-azure-security-baseline-with-builtins.resolved.json"

KEYS=(
  "BUILTIN_ID_DIAGNOSTIC_TO_LA"
  "BUILTIN_ID_STORAGE_SECURE_TRANSFER"
  "BUILTIN_ID_STORAGE_RESTRICT_NETWORK"
  "BUILTIN_ID_KEYVAULT_FIREWALL"
  "BUILTIN_ID_APPSVC_HTTPS_ONLY"
  "BUILTIN_ID_AKS_POLICY_ADDON"
)
TERMS=(
  "Deploy - Configure diagnostic settings to Log Analytics workspace"
  "Storage accounts should have secure transfer required"
  "Storage accounts should restrict network access"
  "Key Vault should have firewall enabled"
  "App Service apps should only be accessible over HTTPS"
  "Kubernetes clusters should have Azure Policy Add-on enabled"
)

IDS_KEYS=()
IDS_VALS=()

echo "Fetching built-in policy definitions..." >&2
defs=$(az policy definition list --query "[?policyType=='BuiltIn']" -o json)

for i in "${!KEYS[@]}"; do
  key="${KEYS[$i]}"
  term="${TERMS[$i]}"
  id=$(echo "$defs" | jq -r --arg q "$term" '.[] | select(.properties.displayName | contains($q)) | .name + "|" + .id' | head -n1)
  if [[ -z "$id" ]]; then
    echo "WARN: No built-in found for $key ($term)" >&2
    continue
  fi
  name=${id%%|*}
  rid=${id#*|}
  echo "Resolved $key -> $name" >&2
  IDS_KEYS+=("$key"); IDS_VALS+=("$rid")
done

cp "$INIT_IN" "$INIT_OUT"
for i in "${!IDS_KEYS[@]}"; do
  key="${IDS_KEYS[$i]}"; value="${IDS_VALS[$i]}"
  # Replace the placeholder token with the full resource ID
  sed -i'' -e "s#<$key>#$value#g" "$INIT_OUT"
done

echo "Wrote resolved initiative to: $INIT_OUT" >&2
