# Quick Start Guide - Azure Security Assessment

Get up and running with Azure Security Assessment Templates in 15 minutes.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Azure subscription with Owner or Contributor access
- [ ] Azure CLI installed (version 2.50.0+)
- [ ] jq installed for JSON processing
- [ ] GitHub account (for CI/CD pipelines)
- [ ] Log Analytics workspace created

## Step 1: Initial Setup (2 minutes)

```bash
# Clone the repository
git clone https://github.com/your-org/azure-security-assessment-templates.git
cd azure-security-assessment-templates

# Login to Azure
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

# Set environment variables
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export RESOURCE_GROUP="rg-security-assessment"
export LOCATION="eastus2"
export WORKSPACE_NAME="law-security-$(date +%Y%m%d)"
```

## Step 2: Create Required Azure Resources (3 minutes)

```bash
# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --location $LOCATION
```

## Step 3: Deploy Security Baseline (5 minutes)

```bash
# Deploy the security baseline
./Scripts/deploy-baseline.sh \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
  --resource-group $RESOURCE_GROUP \
  --workspace $WORKSPACE_NAME \
  --location $LOCATION \
  --include-builtins true

# Verify deployment
az policy assignment list \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
  --query "[?contains(displayName, 'Security')].{Name:displayName, State:enforcementMode}" \
  -o table
```

## Step 4: Quick Assessment (3 minutes)

### Option A: ISO 27001 Assessment
```bash
# Review ISO 27001 controls
cat Compliance/ISO27001/quick-assessment-checklist.txt

# Generate control matrix
./Scripts/generate-iso27001-report.sh \
  --output "assessment-iso27001-$(date +%Y%m%d).xlsx"
```

### Option B: SOC 2 Assessment
```bash
# Review SOC 2 criteria
cat Compliance/SOC2/quick-assessment-checklist.txt

# Generate TSC matrix
./Scripts/generate-soc2-report.sh \
  --output "assessment-soc2-$(date +%Y%m%d).xlsx"
```

## Step 5: Enable Monitoring (2 minutes)

```bash
# Deploy Sentinel analytics rules
az sentinel alert-rule create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $WORKSPACE_NAME \
  --rule-file Sentinel/analytics/high-risk-signin.json

# Enable workbook
az monitor workbook create \
  --resource-group $RESOURCE_GROUP \
  --name "SecurityPosture" \
  --category "security" \
  --display-name "Security Posture Dashboard" \
  --source-id "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.OperationalInsights/workspaces/${WORKSPACE_NAME}" \
  --serialized-data @Sentinel/workbooks/security-posture.json
```

## What's Next?

### Immediate Actions

1. **Review Deployed Policies**
   ```bash
   # List all deployed policies
   az policy assignment list --query "[].{Name:name, DisplayName:displayName}" -o table
   
   # Check compliance status
   az policy state summarize --resource-group $RESOURCE_GROUP
   ```

2. **Customize for Your Environment**
   - Edit `Assessment/Context-and-Scope.md` with your organization details
   - Update `Roles/RACI-Matrix.md` with team members
   - Modify policy parameters in `Policies/parameters/`

3. **Schedule Assessment Activities**
   - Week 1: Discovery and questionnaires
   - Week 2: Technical assessment and testing
   - Week 3: Evidence collection
   - Week 4: Reporting and remediation planning

### Essential Commands

```bash
# Check deployment status
./Scripts/check-deployment-status.sh

# Generate compliance report
./Scripts/generate-compliance-report.sh --format pdf

# Export findings
./Scripts/export-findings.sh --output findings.csv

# Validate security controls
./Scripts/validate-controls.sh --framework iso27001
```

## Verification Checklist

Confirm successful setup:

- [ ] Policies deployed and active
- [ ] Sentinel rules configured
- [ ] Workbook accessible in Azure Portal
- [ ] Compliance data being collected
- [ ] No deployment errors

## Quick Wins

### 1. Enable MFA Enforcement (1 minute)
```bash
az policy assignment create \
  --name "require-mfa" \
  --policy "06a78e20-9358-41c9-923c-fb736d382a12" \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}"
```

### 2. Enable Storage Encryption (1 minute)
```bash
az policy assignment create \
  --name "storage-encryption" \
  --policy "6fac406b-40ca-413b-bf8e-0bf6b50e4c2a" \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}"
```

### 3. Restrict Public IPs (1 minute)
```bash
az policy assignment create \
  --name "deny-public-ip" \
  --policy "83a86a26-fd1f-447c-b59d-e51f3038b5fd" \
  --scope "/subscriptions/${AZURE_SUBSCRIPTION_ID}"
```

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| "Subscription not found" | Run `az account set --subscription <ID>` |
| "Insufficient permissions" | Ensure you have Owner/Contributor role |
| "Workspace not found" | Wait 2-3 minutes after creation |
| "Policy assignment failed" | Check management group hierarchy |
| "Script permission denied" | Run `chmod +x Scripts/*.sh` |

### Getting Help

- Check [FAQ.md](FAQ.md) for common questions
- Review [Scripts/README.md](Scripts/README.md) for detailed script documentation
- Open an issue on [GitHub](https://github.com/your-org/azure-security-assessment-templates/issues)

## 5-Minute Demo Script

For a quick demonstration to stakeholders:

```bash
# 1. Show current security posture (30 seconds)
az policy state summarize --query "results[0].policyAssignments[0:5]" -o table

# 2. Deploy a security control (60 seconds)
./Scripts/deploy-single-policy.sh --policy "storage-https-only"

# 3. Run compliance check (60 seconds)
./Scripts/quick-compliance-check.sh

# 4. Generate executive summary (90 seconds)
./Scripts/generate-executive-summary.sh --output "exec-summary.pdf"

# 5. Show security dashboard (60 seconds)
echo "Navigate to: https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/workbooks"

# 6. Export findings (30 seconds)
./Scripts/export-findings.sh --format json --severity high
```

## Next Steps by Role

### For DevOps Engineers
1. Review [Roles/DevOps.md](Roles/DevOps.md)
2. Implement CI/CD security gates
3. Configure container scanning
4. Set up infrastructure monitoring

### For Azure Architects
1. Review [Roles/Azure-Architect.md](Roles/Azure-Architect.md)
2. Assess architecture against best practices
3. Design secure network topology
4. Plan identity and access management

### For Security Assessors
1. Complete [Assessment/Assessment-Plan.md](Assessment/Assessment-Plan.md)
2. Distribute questionnaires to stakeholders
3. Schedule control testing sessions
4. Prepare evidence collection

## Success Metrics

After completing the quick start, you should have:

✅ 15+ Azure Policies deployed  
✅ 5+ Sentinel analytics rules active  
✅ 1 Security dashboard configured  
✅ Compliance baseline established  
✅ Assessment framework ready  

---

**Time to Production-Ready: 15 minutes**

For comprehensive deployment and customization, continue to the [full documentation](README.md).