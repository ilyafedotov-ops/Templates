# Frequently Asked Questions (FAQ)

## Table of Contents
- [General Questions](#general-questions)
- [Getting Started](#getting-started)
- [Azure Policy Questions](#azure-policy-questions)
- [Sentinel & Monitoring](#sentinel--monitoring)
- [Compliance & Assessment](#compliance--assessment)
- [Deployment & Configuration](#deployment--configuration)
- [Troubleshooting](#troubleshooting)
- [Security & Best Practices](#security--best-practices)
- [Customization](#customization)
- [Support & Resources](#support--resources)

## General Questions

### Q: What is the Azure Security Assessment Templates repository?
**A:** It's a comprehensive framework for conducting enterprise-grade security assessments of Azure environments. It provides templates, automation scripts, and tools aligned with ISO 27001, SOC 2, and Azure security best practices.

### Q: Who should use these templates?
**A:** 
- DevOps Engineers implementing security controls
- Azure Architects designing secure solutions
- Security Assessors conducting audits
- Compliance Officers managing certifications
- Cloud Engineers maintaining Azure environments

### Q: What compliance frameworks are supported?
**A:** 
- ISO/IEC 27001:2022 (full Annex A coverage)
- SOC 2 Type II (all Trust Services Criteria)
- Microsoft Cloud Security Benchmark (MCSB)
- CIS Azure Foundations Benchmark
- PCI DSS (partial coverage for cloud controls)

### Q: Is this an official Microsoft product?
**A:** No, this is a community-driven repository of best practices and templates. While it aligns with Microsoft's security recommendations, it's not an official Microsoft product.

### Q: How often are the templates updated?
**A:** Templates are updated quarterly to reflect:
- New Azure security features
- Updated compliance requirements
- Community feedback and contributions
- Emerging threats and vulnerabilities

## Getting Started

### Q: What are the minimum requirements to use these templates?
**A:** 
- Azure subscription (any type)
- Azure CLI version 2.50.0 or higher
- jq (JSON processor)
- Owner or Contributor role on subscription
- Log Analytics workspace (for Sentinel features)

### Q: How long does the initial setup take?
**A:** 
- Quick start: 15 minutes
- Basic deployment: 30-45 minutes
- Full implementation: 2-4 hours
- Complete assessment: 2-4 weeks

### Q: Can I use these templates in Azure Government or other sovereign clouds?
**A:** Yes, with modifications:
```bash
# Set Azure Government environment
az cloud set --name AzureUSGovernment
az login

# Modify endpoints in scripts
export AZURE_ENVIRONMENT="AzureUSGovernment"
```

### Q: Do I need to deploy everything at once?
**A:** No, you can deploy components incrementally:
1. Start with policies in audit mode
2. Add Sentinel monitoring
3. Enable enforcement gradually
4. Implement advanced features

### Q: Can I use these templates with existing Azure deployments?
**A:** Yes, the templates are designed to work with existing environments. Start with audit mode to assess current compliance before enforcing policies.

## Azure Policy Questions

### Q: What's the difference between custom and built-in policies?
**A:** 
- **Built-in**: Microsoft-managed policies, automatically updated
- **Custom**: Organization-specific policies you create and maintain
- This repository provides both types for comprehensive coverage

### Q: How do I handle policy conflicts?
**A:** 
1. Use policy exemptions for specific resources
2. Adjust policy parameters
3. Use different enforcement modes (audit vs. deny)
4. Implement policy inheritance at management group level

### Q: Can policies break existing resources?
**A:** Policies in "Deny" mode only affect new resources or modifications. Use "Audit" mode first to assess impact, then switch to enforcement.

### Q: How do I exclude certain resources from policies?
**A:** Create policy exemptions:
```bash
az policy exemption create \
  --name "Legacy-App-Exception" \
  --policy-assignment "/subscriptions/{id}/providers/Microsoft.Authorization/policyAssignments/{name}" \
  --exemption-category "Waiver" \
  --description "Legacy application requires public access until migration"
```

### Q: What happens if a policy deployment fails?
**A:** 
1. Check error logs in `logs/policy-*.log`
2. Verify management group hierarchy
3. Ensure built-in policies are resolved
4. Validate JSON syntax
5. Check RBAC permissions

## Sentinel & Monitoring

### Q: Do I need Microsoft Sentinel for these templates?
**A:** Sentinel is optional but recommended for:
- Advanced threat detection
- Automated incident response
- Security orchestration
- Compliance reporting

Basic monitoring works with Azure Monitor alone.

### Q: How much does Sentinel cost?
**A:** Costs depend on data ingestion:
- Pay-as-you-go: ~$2.50/GB
- Commitment tiers: 100GB/day starting ~$120/day
- Use data retention policies to manage costs
- Enable only necessary data connectors

### Q: Can I use existing SIEM instead of Sentinel?
**A:** Yes, you can:
- Export logs to external SIEM via Event Hub
- Use Azure Monitor to send data to Splunk/QRadar
- Implement webhooks for alert forwarding
- Some features (playbooks) are Sentinel-specific

### Q: How do I customize Sentinel analytics rules?
**A:** 
1. Modify JSON files in `Sentinel/analytics/`
2. Adjust query logic and thresholds
3. Update severity levels
4. Test in non-production first
5. Deploy using `deploy-sentinel.sh`

### Q: What data sources should I connect?
**A:** Priority order:
1. Azure Activity logs (free)
2. Azure AD sign-in logs
3. Microsoft Defender for Cloud
4. Key Vault audit logs
5. Network Security Group flow logs

## Compliance & Assessment

### Q: How do I prove compliance to auditors?
**A:** The repository provides:
- Evidence collection templates
- Automated compliance reports
- Control test procedures
- Audit trail documentation
- Policy compliance dashboards

### Q: Can I customize compliance mappings?
**A:** Yes:
1. Edit Excel files in `Compliance/*/`
2. Add custom controls
3. Map to your policies
4. Update evidence requirements
5. Generate custom reports

### Q: How often should I run assessments?
**A:** 
- Continuous: Policy compliance monitoring
- Monthly: Security posture review
- Quarterly: Comprehensive assessment
- Annually: Full audit with evidence
- Ad-hoc: After major changes

### Q: What's the difference between ISO 27001 and SOC 2?
**A:** 
| Aspect | ISO 27001 | SOC 2 |
|--------|-----------|-------|
| Focus | Information Security Management System | Trust Service Criteria |
| Scope | Entire organization | Specific services |
| Certification | Yes | Attestation report |
| Duration | 3-year cycle | Annual |
| Best for | Global recognition | US service providers |

### Q: How do I handle multi-tenant scenarios?
**A:** 
1. Deploy at management group level
2. Use subscription-level exemptions
3. Implement tenant-specific parameters
4. Separate Sentinel workspaces per tenant
5. Use Azure Lighthouse for management

## Deployment & Configuration

### Q: Can I deploy to multiple subscriptions?
**A:** Yes, use management groups:
```bash
./Scripts/deploy-baseline.sh \
  --scope "/providers/Microsoft.Management/managementGroups/mg-organization" \
  --resource-group "rg-security-central" \
  --workspace "law-security-central"
```

### Q: How do I handle different environments (dev/test/prod)?
**A:** 
1. Use separate parameter files
2. Implement environment-specific exemptions
3. Different enforcement modes per environment
4. Separate resource groups and workspaces
5. Use CI/CD pipeline stages

### Q: Can I use Infrastructure as Code (Terraform/Bicep)?
**A:** Yes, convert templates:
```bash
# Convert to Terraform
json2hcl < Policies/definitions/policy.json > policy.tf

# Use with Bicep
az bicep decompile --file policy.json
```

### Q: How do I integrate with existing CI/CD?
**A:** 
- **GitHub Actions**: Use provided workflows in `.github/workflows/`
- **Azure DevOps**: Import pipelines from `Pipelines/azure-devops/`
- **Jenkins**: Call scripts in pipeline stages
- **GitLab**: Adapt GitHub workflows

### Q: What about ARM template deployments?
**A:** The JSON policies are ARM-compatible. Deploy using:
```bash
az deployment sub create \
  --location eastus \
  --template-file template.json \
  --parameters @parameters.json
```

## Troubleshooting

### Q: Deployment script fails with "command not found"
**A:** 
```bash
# Make scripts executable
chmod +x Scripts/*.sh

# Install missing dependencies
brew install jq     # macOS
apt-get install jq  # Ubuntu/Debian
```

### Q: "Insufficient permissions" error
**A:** Verify roles:
```bash
# Check current permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Grant required role
az role assignment create \
  --assignee <user-or-service-principal> \
  --role Owner \
  --scope /subscriptions/<subscription-id>
```

### Q: Policies show as "Non-compliant" immediately
**A:** This is normal. Compliance evaluation takes time:
- Initial scan: 15-30 minutes
- Full evaluation: 1-24 hours
- Use `az policy state trigger-scan` to force evaluation

### Q: Sentinel rules not generating incidents
**A:** Check:
1. Data ingestion in Log Analytics
2. Query syntax in analytics rules
3. Alert threshold settings
4. Time window configuration
5. Workspace data retention

### Q: How do I debug failed deployments?
**A:** 
```bash
# Enable debug logging
export LOG_LEVEL=DEBUG

# Check deployment history
az deployment sub list --query "[?properties.provisioningState=='Failed']"

# View detailed errors
az monitor activity-log list --correlation-id <deployment-correlation-id>
```

## Security & Best Practices

### Q: Are the default passwords/secrets secure?
**A:** No defaults are provided. You must:
1. Generate strong secrets
2. Store in Azure Key Vault
3. Use managed identities where possible
4. Rotate credentials regularly
5. Never commit secrets to repository

### Q: How do I secure the deployment process?
**A:** 
1. Use service principals for automation
2. Implement just-in-time access
3. Enable MFA for all accounts
4. Audit deployment activities
5. Use private endpoints for management

### Q: What about data residency and sovereignty?
**A:** 
- Deploy resources in specific regions
- Use policy to restrict locations
- Configure data retention policies
- Implement encryption at rest
- Consider Azure confidential computing

### Q: How do I implement zero-trust principles?
**A:** The templates support zero-trust through:
- Conditional access policies
- Network segmentation
- Private endpoints
- Managed identities
- Continuous verification

### Q: Can I use this for PCI DSS compliance?
**A:** Partially. The templates cover many PCI requirements but need additions:
- Network segmentation controls
- Card data discovery tools
- Specific logging requirements
- Vulnerability scanning
- Penetration testing procedures

## Customization

### Q: How do I add custom policies?
**A:** 
1. Create JSON in `Policies/definitions/`
2. Follow naming convention: `category-resource-control.json`
3. Add to initiative
4. Test in audit mode
5. Document in README

### Q: Can I modify assessment templates?
**A:** Yes, all templates are customizable:
- Edit Markdown files directly
- Modify Excel control mappings
- Adjust scoring models
- Add organization branding
- Customize report formats

### Q: How do I add new Sentinel playbooks?
**A:** 
1. Create Logic App in Azure Portal
2. Export as ARM template
3. Save to `Sentinel/playbooks/`
4. Add to deployment script
5. Test automation flow

### Q: Can I use different scoring models?
**A:** Yes, modify `Assessment/Scoring-Model.md`:
- Adjust risk weights
- Change severity scales
- Add custom metrics
- Implement CVSS scoring
- Use organization-specific models

### Q: How do I brand reports?
**A:** 
1. Add logos to `Branding/`
2. Update report templates
3. Modify color schemes
4. Add custom headers/footers
5. Include organization details

## Support & Resources

### Q: Where can I get help?
**A:** 
- GitHub Issues: Bug reports and features
- GitHub Discussions: Community help
- Stack Overflow: Tag with `azure-security`
- Microsoft Q&A: Azure-specific questions
- Professional services: For enterprise support

### Q: How can I contribute?
**A:** 
1. Fork the repository
2. Create feature branch
3. Make improvements
4. Add tests and documentation
5. Submit pull request

### Q: Are there training resources?
**A:** 
- [Microsoft Learn](https://learn.microsoft.com/azure/security/)
- [Azure Security Center documentation](https://docs.microsoft.com/azure/security-center/)
- [Cloud Security Alliance resources](https://cloudsecurityalliance.org)
- Video tutorials (coming soon)

### Q: What's the roadmap?
**A:** Planned features:
- Terraform/Bicep native support
- Additional compliance frameworks
- Container security templates
- Enhanced automation
- AI-powered recommendations

### Q: How do I report security issues?
**A:** For security vulnerabilities:
1. Do NOT create public issues
2. Email security@your-org.com
3. Include detailed description
4. Allow 90 days for fix
5. Coordinate disclosure

---

## Quick Reference

### Essential Commands
```bash
# Check deployment status
./Scripts/check-deployment-status.sh

# Generate compliance report
./Scripts/generate-compliance-report.sh --framework iso27001

# Quick security assessment
./Scripts/quick-compliance-check.sh

# Export findings
./Scripts/export-findings.sh --severity high
```

### Important Files
- `README.md` - Main documentation
- `QUICK-START.md` - 15-minute setup
- `CLAUDE.md` - Repository guidance
- `Scripts/README.md` - Script documentation
- `.env.example` - Configuration template

### Support Channels
- Issues: [GitHub Issues](https://github.com/your-org/azure-security-assessment-templates/issues)
- Discussions: [GitHub Discussions](https://github.com/your-org/azure-security-assessment-templates/discussions)
- Email: support@your-org.com

---

**Last Updated:** 2024-01-15  
**Version:** 2.0.0