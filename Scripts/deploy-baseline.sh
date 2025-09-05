#!/usr/bin/env bash
set -euo pipefail

# Deploy security baseline: custom policy definitions, initiative (with optional built-ins), assignment,
# and Sentinel content (analytics rules and playbooks).

usage() {
  cat <<'USAGE'
Usage:
  deploy-baseline.sh \
    --scope <mgmt-group-or-subscription-resource-id> \
    --resource-group <rg-for-sentinel> \
    --workspace <log-analytics-workspace-name> \
    [--location <azure-region>] \
    [--include-builtins true|false] \
    [--teams-webhook <url>] \
    [--azdo-url <api-url>] [--azdo-auth <auth-header>]

Notes:
  - Requires: az CLI, jq.
  - Creates/updates custom policy definitions and an initiative.
  - If --include-builtins=true and a resolved initiative exists, it will be used.
  - Deploys Sentinel analytics rules and optionally playbooks (Teams notify, ADO work item, Disable AAD user).
USAGE
}

SCOPE=""
RG=""
WS=""
LOCATION=""
INCLUDE_BUILTINS="true"
TEAMS_WEBHOOK=""
AZDO_URL=""
AZDO_AUTH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2 ;;
    --resource-group) RG="$2"; shift 2 ;;
    --workspace) WS="$2"; shift 2 ;;
    --location) LOCATION="$2"; shift 2 ;;
    --include-builtins) INCLUDE_BUILTINS="$2"; shift 2 ;;
    --teams-webhook) TEAMS_WEBHOOK="$2"; shift 2 ;;
    --azdo-url) AZDO_URL="$2"; shift 2 ;;
    --azdo-auth) AZDO_AUTH="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$SCOPE" || -z "$RG" || -z "$WS" ]]; then
  echo "ERROR: --scope, --resource-group, and --workspace are required" >&2
  usage
  exit 2
fi

command -v az >/dev/null || { echo "az CLI not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found" >&2; exit 1; }

echo "Checking Azure login..." >&2
az account show >/dev/null || { echo "Please run 'az login' first." >&2; exit 1; }

# Create/update custom policy definitions (subscription-scoped by default)
SUB_ID=$(az account show --query id -o tsv)

create_def() {
  local name="$1" file="$2"
  echo "Upserting policy definition: $name from $file" >&2
  az policy definition create \
    --name "$name" \
    --display-name "$name" \
    --rules "$file" \
    --mode All \
    --subscription "$SUB_ID" \
    >/dev/null 2>&1 || az policy definition update \
      --name "$name" \
      --rules "$file" \
      --subscription "$SUB_ID" >/dev/null
}

BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
DEF_DIR="$BASE_DIR/Policies/definitions"

create_def diag-audit-custom "$DEF_DIR/policy-diagnostic-settings.json"
create_def allowed-locations-custom "$DEF_DIR/policy-allowed-locations.json"
create_def require-tags-custom "$DEF_DIR/policy-require-tags.json"
create_def storage-public-network-deny-custom "$DEF_DIR/policy-storage-public-network-access.json"
create_def storage-private-endpoint-audit-custom "$DEF_DIR/policy-require-private-endpoint-storage.json"
create_def appservice-min-tls-custom "$DEF_DIR/policy-appservice-min-tls.json"
create_def storage-secure-transfer-custom "$DEF_DIR/policy-storage-secure-transfer.json"

# Collect definition IDs
declare -A CUSTOM_IDS
for n in diag-audit-custom allowed-locations-custom require-tags-custom storage-public-network-deny-custom storage-private-endpoint-audit-custom appservice-min-tls-custom storage-secure-transfer-custom; do
  id=$(az policy definition show --name "$n" --subscription "$SUB_ID" --query id -o tsv)
  CUSTOM_IDS[$n]="$id"
done

# Optionally resolve built-ins dynamically (fallback to custom-only)
declare -A BUILTIN
if [[ "$INCLUDE_BUILTINS" == "true" ]]; then
  echo "Resolving built-in policy IDs..." >&2
  BUILTIN[diag_to_la]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'diagnostic settings')].id | [0]" -o tsv)
  BUILTIN[storage_secure]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'secure transfer required')].id | [0]" -o tsv)
  BUILTIN[storage_network]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'restrict network access')].id | [0]" -o tsv)
  BUILTIN[kv_firewall]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'Key Vault') && contains(properties.displayName, 'firewall')].id | [0]" -o tsv)
  BUILTIN[https_only]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'HTTPS only')].id | [0]" -o tsv)
  BUILTIN[aks_policy]=$(az policy definition list --query "[?policyType=='BuiltIn' && contains(properties.displayName, 'Azure Policy Add-on enabled')].id | [0]" -o tsv)
fi

# Build initiative policyDefinitions payload
TMP=$(mktemp)
cat > "$TMP" <<JSON
{
  "properties": {
    "displayName": "Azure Security Baseline (Deployed)",
    "description": "Guardrails combining custom and built-in policies.",
    "policyType": "Custom",
    "policyDefinitions": [
      {"policyDefinitionReferenceId": "diag-audit", "policyDefinitionId": "${CUSTOM_IDS[diag-audit-custom]}"},
      {"policyDefinitionReferenceId": "allowed-locations", "policyDefinitionId": "${CUSTOM_IDS[allowed-locations-custom]}"},
      {"policyDefinitionReferenceId": "require-tags", "policyDefinitionId": "${CUSTOM_IDS[require-tags-custom]}"},
      {"policyDefinitionReferenceId": "storage-public-network-deny", "policyDefinitionId": "${CUSTOM_IDS[storage-public-network-deny-custom]}"},
      {"policyDefinitionReferenceId": "storage-private-endpoint-audit", "policyDefinitionId": "${CUSTOM_IDS[storage-private-endpoint-audit-custom]}"},
      {"policyDefinitionReferenceId": "appservice-min-tls", "policyDefinitionId": "${CUSTOM_IDS[appservice-min-tls-custom]}"},
      {"policyDefinitionReferenceId": "storage-secure-transfer", "policyDefinitionId": "${CUSTOM_IDS[storage-secure-transfer-custom]}"}
JSON

if [[ "$INCLUDE_BUILTINS" == "true" ]]; then
  for k in diag_to_la storage_secure storage_network kv_firewall https_only aks_policy; do
    id="${BUILTIN[$k]:-}"
    if [[ -n "$id" ]]; then
      echo ", {\"policyDefinitionReferenceId\": \"builtin-$k\", \"policyDefinitionId\": \"$id\"}" >> "$TMP"
    fi
  done
fi

echo "]}}" >> "$TMP"

INIT_NAME="azure-security-baseline-deployed"
echo "Upserting initiative: $INIT_NAME" >&2
az policy set-definition create --name "$INIT_NAME" --definitions @"$TMP" --subscription "$SUB_ID" >/dev/null 2>&1 || \
az policy set-definition update --name "$INIT_NAME" --definitions @"$TMP" --subscription "$SUB_ID" >/dev/null

INIT_ID=$(az policy set-definition show --name "$INIT_NAME" --subscription "$SUB_ID" --query id -o tsv)

echo "Assigning initiative at scope: $SCOPE" >&2
az policy assignment create --name security-baseline --scope "$SCOPE" --policy-set-definition "$INIT_ID" >/dev/null 2>&1 || \
az policy assignment update --name security-baseline --scope "$SCOPE" --policy-set-definition "$INIT_ID" >/dev/null

# Deploy Sentinel analytics rules and playbooks
WS_NAME="$WS"
RG_NAME="$RG"

deploy_group() {
  local file="$1"; shift
  echo "Deploying: $file" >&2
  az deployment group create -g "$RG_NAME" -f "$file" -p workspaceName="$WS_NAME" "$@" >/dev/null
}

ANALYTICS_DIR="$BASE_DIR/Sentinel/analytics-rules"
for f in "$ANALYTICS_DIR"/*.json; do
  deploy_group "$f"
done

PLAYBOOK_DIR="$BASE_DIR/Sentinel/playbooks"
if [[ -n "$TEAMS_WEBHOOK" ]]; then
  az deployment group create -g "$RG_NAME" -f "$PLAYBOOK_DIR/playbook-incident-notify.json" -p teamsWebhookUrl="$TEAMS_WEBHOOK" >/dev/null
fi

if [[ -n "$AZDO_URL" && -n "$AZDO_AUTH" ]]; then
  az deployment group create -g "$RG_NAME" -f "$PLAYBOOK_DIR/playbook-create-azdo-workitem.json" -p azdoWorkItemUrl="$AZDO_URL" azdoAuthHeader="$AZDO_AUTH" >/dev/null
fi

# Always deploy disable user playbook (requires MSI permissions post-deploy)
az deployment group create -g "$RG_NAME" -f "$PLAYBOOK_DIR/playbook-disable-aad-user.json" >/dev/null

echo "Baseline deployment completed. Ensure Logic App permissions and Sentinel automation rules are configured to trigger playbooks." >&2

