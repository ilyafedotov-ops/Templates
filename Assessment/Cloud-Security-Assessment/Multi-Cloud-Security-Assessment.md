# Multi-Cloud Security Assessment

## Assessment Overview

This template provides a comprehensive framework for conducting security assessments across multi-cloud and hybrid cloud environments, focusing on consistent security posture across Azure, AWS, Google Cloud Platform, and on-premises infrastructure.

### Assessment Scope
- **Target Environment**: Multi-cloud infrastructure (Azure, AWS, GCP)
- **Hybrid Connectivity**: ExpressRoute, VPN Gateway, AWS Direct Connect, Cloud Interconnect
- **Framework Alignment**: CSA Cloud Controls Matrix (CCM), NIST Cybersecurity Framework
- **Assessment Duration**: 3-6 weeks depending on environment complexity
- **Required Access**: Cross-cloud security reader permissions

### Key Assessment Areas
1. Multi-Cloud Identity Federation and SSO
2. Cross-Cloud Network Security and Connectivity
3. Data Protection Across Cloud Boundaries
4. Unified Security Monitoring and SIEM
5. Multi-Cloud Compliance and Governance
6. Workload Portability Security
7. Cloud-Native Service Integration Security
8. Incident Response Across Cloud Providers

## Pre-Assessment Planning

### Multi-Cloud Environment Discovery

#### Azure Environment Discovery
```bash
# Azure subscription and tenant inventory
az account list --all --query '[].{Name:name, Id:id, TenantId:tenantId, State:state}' -o table

# Management group hierarchy
az account management-group list --query '[].{Name:displayName, Id:id, Parent:details.parent.displayName}' -o table

# Cross-tenant B2B relationships
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identity/identityProviders" --headers "Content-Type=application/json"
```

#### AWS Environment Discovery
```bash
# AWS account inventory (assumes AWS CLI configured)
aws organizations list-accounts --query 'Accounts[].{AccountId:Id, Name:Name, Status:Status}' --output table 2>/dev/null || echo "AWS Organizations not configured"

# Cross-account roles and trust relationships
aws iam list-roles --query 'Roles[?contains(AssumeRolePolicyDocument, `arn:aws:iam::`) && RoleName!=`OrganizationAccountAccessRole`].{RoleName:RoleName, AssumeRolePolicyDocument:AssumeRolePolicyDocument}' --output table

# Identity providers for federation
aws iam list-saml-providers --output table
aws iam list-open-id-connect-providers --output table
```

#### GCP Environment Discovery
```bash
# GCP project inventory (assumes gcloud CLI configured)
gcloud projects list --format="table(projectId,name,lifecycleState)" 2>/dev/null || echo "GCP CLI not configured"

# Organization policy constraints
gcloud resource-manager org-policies list --organization=$(gcloud organizations list --format="value(name)" 2>/dev/null) --format="table(constraint,displayName)" 2>/dev/null || echo "GCP organization not accessible"

# Identity providers
gcloud iam workforce-pools list --location=global --format="table(name,displayName,state)" 2>/dev/null || echo "GCP Workforce Identity Federation not accessible"
```

### Hybrid Connectivity Assessment
```bash
# Azure hybrid connectivity
az network express-route list --query '[].{Name:name, ResourceGroup:resourceGroup, ServiceProviderProvisioningState:serviceProviderProvisioningState, CircuitProvisioningState:circuitProvisioningState}' -o table

az network vnet-gateway list --query '[].{Name:name, ResourceGroup:resourceGroup, VpnType:vpnType, GatewayType:gatewayType}' -o table

# On-premises domain controllers and hybrid identity
az ad connect show 2>/dev/null || echo "Azure AD Connect not configured or not accessible"
```

## Cloud Security Alliance (CSA) Controls Assessment

### CCM Control Domain: Identity & Access Management (IAM)

#### IAM-01: Identity and Access Management Policy and Procedures
**Multi-Cloud Assessment**:
```bash
# Azure: Identity governance and lifecycle management
az ad user list --query '[?accountEnabled==`false`]' --query '[].{DisplayName:displayName, UserPrincipalName:userPrincipalName, LastSignInDateTime:signInActivity.lastSignInDateTime}' -o table

# AWS: IAM policy and user analysis
aws iam get-credential-report --output text | base64 -d > /tmp/aws-credential-report.csv
cat /tmp/aws-credential-report.csv | head -5

# GCP: IAM policy bindings across projects
for project in $(gcloud projects list --format="value(projectId)" 2>/dev/null); do
  echo "=== Project: $project ==="
  gcloud projects get-iam-policy $project --format="table(bindings[].role, bindings[].members)" 2>/dev/null || echo "Access denied to project $project"
done
```

**Key Findings**:
- [ ] Consistent identity lifecycle management across clouds
- [ ] Federated identity with centralized IdP (Azure AD, Okta, etc.)
- [ ] Multi-cloud privilege escalation prevention
- [ ] Cross-cloud service account management
- [ ] Unified access reviews and certification

#### IAM-02: Multi-Factor Authentication
```bash
# Azure: MFA status across all users
az rest --method GET --uri "https://graph.microsoft.com/beta/reports/authenticationMethods/userRegistrationDetails" --headers "Content-Type=application/json" | jq '.value[].isMfaRegistered' | sort | uniq -c

# AWS: MFA status for IAM users
aws iam get-credential-report --output text | base64 -d | cut -d, -f1,4 | grep -v "^user" | while IFS=, read user mfa_active; do
  echo "User: $user, MFA: $mfa_active"
done

# GCP: 2-Step Verification status (requires Admin SDK)
echo "GCP MFA status requires Google Workspace Admin SDK access"
```

**Key Findings**:
- [ ] MFA enforced across all cloud platforms
- [ ] Consistent MFA policies (FIDO2, authenticator apps)
- [ ] Break-glass account procedures standardized
- [ ] MFA bypass controls for automation accounts
- [ ] Risk-based authentication implemented

### CCM Control Domain: Data Security & Encryption (DSI)

#### DSI-01: Data Classification and Labeling
**Multi-Cloud Data Discovery**:
```bash
# Azure: Microsoft Purview data classification
az purview account list --query '[].{Name:name, ResourceGroup:resourceGroup, Status:provisioningState}' -o table

# AWS: Amazon Macie data classification findings
aws macie2 get-findings --finding-ids $(aws macie2 list-findings --query 'findingIds[0:5]' --output text) --query 'findings[].{Type:type, Severity:severity.description, Title:title}' --output table 2>/dev/null || echo "Macie not enabled"

# GCP: Cloud DLP inspection results
gcloud dlp jobs list --filter="state:DONE" --format="table(name,inspectDetails.requestedOptions.jobConfig.storageConfig.cloudStorageOptions.fileSet.url)" --limit=10 2>/dev/null || echo "Cloud DLP not configured"
```

#### DSI-02: Data Encryption at Rest
```bash
# Azure: Storage and database encryption status
az storage account list --query '[].{Name:name, Encryption:encryption.keySource, CustomerManagedKeys:encryption.keyVaultProperties.keyName}' -o table

az sql server list --query '[].{Name:name, ResourceGroup:resourceGroup}' -o tsv | while read name rg; do
  echo "SQL Server: $name"
  az sql server tde-key show --server $name --resource-group $rg --query '{KeyType:serverKeyType, Uri:uri}' -o table 2>/dev/null || echo "  No TDE configuration"
done

# AWS: EBS, S3, RDS encryption status
aws ec2 describe-volumes --query 'Volumes[].{VolumeId:VolumeId, Encrypted:Encrypted, KmsKeyId:KmsKeyId}' --output table

aws s3api list-buckets --query 'Buckets[].Name' --output text | xargs -I {} aws s3api get-bucket-encryption --bucket {} --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault' --output table 2>/dev/null || echo "Bucket encryption check failed"

# GCP: Compute and storage encryption
gcloud compute disks list --format="table(name,sizeGb,zone,status,type,sourceImage.basename(),diskEncryptionKey.kmsKeyName)" --filter="diskEncryptionKey.kmsKeyName:*" 2>/dev/null || echo "No CMEK encrypted disks found"
```

**Key Findings**:
- [ ] Customer-managed keys (CMK) used for sensitive data
- [ ] Key rotation policies consistent across clouds
- [ ] Cross-cloud key management strategy
- [ ] Encryption in transit for inter-cloud communication
- [ ] Database-level encryption (TDE, CLE) implemented

### CCM Control Domain: Network Security (IVS)

#### IVS-01: Network Architecture and Security
**Multi-Cloud Network Topology Assessment**:
```bash
# Azure: Virtual network peering and connectivity
az network vnet list --query '[].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes, Peerings:virtualNetworkPeerings[].remoteVirtualNetwork.id}' -o table

az network vnet-gateway list --query '[].{Name:name, ResourceGroup:resourceGroup, VpnType:vpnType, Connections:connections}' -o table

# AWS: VPC peering and Transit Gateway
aws ec2 describe-vpcs --query 'Vpcs[].{VpcId:VpcId, CidrBlock:CidrBlock, State:State}' --output table

aws ec2 describe-vpc-peering-connections --query 'VpcPeeringConnections[].{ConnectionId:VpcPeeringConnectionId, Status:Status.Code, RequesterVpc:RequesterVpcInfo.VpcId, AccepterVpc:AccepterVpcInfo.VpcId}' --output table

aws ec2 describe-transit-gateways --query 'TransitGateways[].{TgwId:TransitGatewayId, State:State, RouteTableId:Options.DefaultRouteTableId}' --output table 2>/dev/null || echo "No Transit Gateways found"

# GCP: VPC networks and peering
gcloud compute networks list --format="table(name,routingMode,subnet.selfLink.scope(regions).segment(0):label=SUBNETS)" 2>/dev/null || echo "GCP access not available"

gcloud compute networks peerings list --format="table(name,network.basename(),peerNetwork.basename(),state)" 2>/dev/null || echo "No VPC peerings found"
```

#### IVS-02: Network Segmentation and Traffic Control
```bash
# Azure: Network Security Group analysis
az network nsg list --query '[].name' -o tsv | while read nsg; do
  echo "=== NSG: $nsg ==="
  dangerous_rules=$(az network nsg rule list --nsg-name $nsg --query '[?access==`Allow` && direction==`Inbound` && sourceAddressPrefix==`*` && destinationPortRange!=`null`]' -o tsv 2>/dev/null | wc -l)
  if [ $dangerous_rules -gt 0 ]; then
    echo "⚠️  $dangerous_rules potentially dangerous inbound rules"
    az network nsg rule list --nsg-name $nsg --query '[?access==`Allow` && direction==`Inbound` && sourceAddressPrefix==`*`].{Priority:priority, Port:destinationPortRange, Protocol:protocol}' -o table
  fi
done

# AWS: Security Group analysis
aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]]' --query 'SecurityGroups[].{GroupId:GroupId, GroupName:GroupName, VpcId:VpcId}' --output table

# GCP: Firewall rules analysis
gcloud compute firewall-rules list --filter="direction:INGRESS AND sourceRanges:0.0.0.0/0" --format="table(name,direction,priority,sourceRanges,allowed[].map().firewall_rule().list():label=ALLOWED,targetTags)" 2>/dev/null || echo "GCP access not available"
```

**Key Findings**:
- [ ] Network segmentation consistent across cloud providers
- [ ] Least privilege network access implemented
- [ ] Inter-cloud communication secured (VPN, private connectivity)
- [ ] Micro-segmentation for cloud-native workloads
- [ ] Network monitoring and traffic analysis deployed

### CCM Control Domain: Security Incident Management (SEF)

#### SEF-01: Incident Response and Forensics
**Multi-Cloud SIEM Integration Assessment**:
```bash
# Azure: Sentinel workspace and data connectors
az sentinel workspace list --query '[].{Name:name, ResourceGroup:resourceGroup, WorkspaceId:workspaceId}' -o table

az monitor log-analytics workspace list --query '[].{Name:name, ResourceGroup:resourceGroup, DataSources:dataSources}' -o table

# Check for multi-cloud log ingestion
az monitor diagnostic-settings list --resource-type "Microsoft.Resources/subscriptions" | jq '.value[].properties.logs[]'

# AWS: Security Hub and GuardDuty integration
aws securityhub get-enabled-standards --query 'StandardsSubscriptions[].{StandardsArn:StandardsArn, StandardsStatus:StandardsStatus}' --output table 2>/dev/null || echo "Security Hub not enabled"

aws guardduty list-detectors --query 'DetectorIds' --output text | xargs -I {} aws guardduty get-detector --detector-id {} --query '{DetectorId:DetectorId, Status:Status, ServiceRole:ServiceRole}' --output table 2>/dev/null || echo "GuardDuty not enabled"

# GCP: Security Command Center integration
gcloud scc sources list --organization=$(gcloud organizations list --format="value(name)" 2>/dev/null) --format="table(name,displayName)" 2>/dev/null || echo "GCP SCC not accessible"
```

**Key Findings**:
- [ ] Unified SIEM solution deployed (Azure Sentinel, Splunk, etc.)
- [ ] Cross-cloud log aggregation and correlation
- [ ] Incident response playbooks cover multi-cloud scenarios
- [ ] Forensic capabilities across all cloud platforms
- [ ] Automated threat hunting across cloud boundaries

## Hybrid Identity Security Assessment

### Active Directory Federation Assessment
```bash
# Azure AD Connect health and sync status
az ad connect show --query '{Status:provisioningStatus, LastSync:lastSyncDateTime, Health:health}' -o table 2>/dev/null || echo "Azure AD Connect not configured"

# Federation configuration
az ad signed-in-user show --query '{UserPrincipalName:userPrincipalName, TenantId:tenantId}' -o table

# Cross-forest trusts and domain relationships
echo "Forest trusts require on-premises AD DS PowerShell access"
```

### Multi-Cloud Service Principal Security
```bash
# Azure: Service principal cross-tenant access
az ad sp list --all --query '[?length(appOwnerTenantId) > `0` && appOwnerTenantId != tenantId]' --query '[].{DisplayName:displayName, AppId:appId, OwnerTenant:appOwnerTenantId}' -o table

# AWS: Cross-account role assumptions
aws iam list-roles --query 'Roles[?contains(AssumeRolePolicyDocument, `sts:ExternalId`) || contains(AssumeRolePolicyDocument, `saml:`) || contains(AssumeRolePolicyDocument, `oidc:`)]' --query '[].{RoleName:RoleName, TrustPolicy:AssumeRolePolicyDocument}' --output table

# GCP: Workload Identity Federation
gcloud iam workforce-pools list --location=global --format="table(name,displayName,state)" 2>/dev/null || echo "Workforce Identity Federation pools not found"
```

## Multi-Cloud Compliance Assessment

### Data Residency and Sovereignty
```bash
# Azure: Resource locations and data residency
az group list --query '[].{Name:name, Location:location}' -o table | sort -k2

# Storage account geo-replication settings
az storage account list --query '[].{Name:name, Location:primaryLocation, SecondaryLocation:secondaryLocation, ReplicationType:sku.name}' -o table

# AWS: Resource distribution across regions
aws ec2 describe-regions --query 'Regions[].RegionName' --output text | xargs -I {} sh -c 'echo "Region: {}"; aws ec2 describe-instances --region {} --query "length(Reservations[].Instances[])" --output text 2>/dev/null || echo "  Access denied or no resources"'

# GCP: Resource locations
gcloud compute regions list --format="table(name,status)" 2>/dev/null || echo "GCP access not available"
```

### Cross-Cloud Governance Policies
```bash
# Azure: Policy assignments across management groups
az policy assignment list --query '[].{Name:displayName, PolicyDefinitionId:policyDefinitionId, Scope:scope}' -o table | head -10

# AWS: Service Control Policies (SCPs)
aws organizations list-policies --filter="SERVICE_CONTROL_POLICY" --query 'Policies[].{PolicyName:Name, PolicyId:Id}' --output table 2>/dev/null || echo "AWS Organizations SCPs not accessible"

# GCP: Organization Policy constraints
gcloud resource-manager org-policies list --organization=$(gcloud organizations list --format="value(name)" 2>/dev/null) --format="table(constraint,displayName)" 2>/dev/null || echo "GCP organization policies not accessible"
```

## Network Security Deep Dive

### Inter-Cloud Connectivity Security
```bash
# Azure ExpressRoute security assessment
az network express-route list --query '[].{Name:name, ResourceGroup:resourceGroup, BandwidthInMbps:serviceProviderProperties.bandwidthInMbps, PeeringType:peerings[0].peeringType}' -o table

# VPN Gateway security configuration
az network vnet-gateway list --query '[].{Name:name, VpnType:vpnType, Generation:vpnGatewayGeneration, SKU:sku.name}' -o table

# AWS Direct Connect and VPN security
aws directconnect describe-connections --query 'connections[].{ConnectionId:connectionId, ConnectionState:connectionState, Bandwidth:bandwidth, Location:location}' --output table 2>/dev/null || echo "No Direct Connect connections"

aws ec2 describe-vpn-connections --query 'VpnConnections[].{VpnConnectionId:VpnConnectionId, State:State, Type:Type, CustomerGatewayConfiguration:CustomerGatewayConfiguration}' --output table 2>/dev/null || echo "No VPN connections"

# GCP Cloud Interconnect security
gcloud compute interconnects list --format="table(name,linkType,location,state)" 2>/dev/null || echo "No Cloud Interconnects found"
```

### Private Connectivity Assessment
```bash
# Azure: Private endpoints and private DNS zones
az network private-endpoint list --query '[].{Name:name, ResourceGroup:resourceGroup, Subnet:subnet.id, PrivateIp:networkInterfaces[0].ipConfigurations[0].privateIpAddress}' -o table

az network private-dns zone list --query '[].{Name:name, ResourceGroup:resourceGroup, NumberOfRecordSets:numberOfRecordSets}' -o table

# AWS: VPC endpoints and PrivateLink services
aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[].{VpcEndpointId:VpcEndpointId, ServiceName:ServiceName, State:State, VpcId:VpcId}' --output table

# GCP: Private Service Connect endpoints
gcloud compute forwarding-rules list --filter="target~'.*serviceAttachments.*'" --format="table(name,region,target.basename(),loadBalancingScheme)" 2>/dev/null || echo "No Private Service Connect endpoints found"
```

## Cloud-Native Security Assessment

### Container Security Across Clouds
```bash
# Azure: AKS cluster security configuration
az aks list --query '[].{Name:name, ResourceGroup:resourceGroup, KubernetesVersion:kubernetesVersion, EnableRbac:enableRbac, NetworkProfile:networkProfile.networkPlugin}' -o table

# Container registry security
az acr list --query '[].{Name:name, ResourceGroup:resourceGroup, AdminUserEnabled:adminUserEnabled, PublicNetworkAccess:publicNetworkAccess}' -o table

# AWS: EKS cluster security
aws eks list-clusters --query 'clusters' --output text | xargs -I {} aws eks describe-cluster --name {} --query 'cluster.{Name:name, Version:version, Status:status, EndpointConfig:resourcesVpcConfig.endpointConfigResponse.publicAccess}' --output table 2>/dev/null || echo "No EKS clusters found"

# ECR security configuration
aws ecr describe-repositories --query 'repositories[].{RepositoryName:repositoryName, ImageScanningConfiguration:imageScanningConfiguration.scanOnPush, EncryptionConfiguration:encryptionConfiguration.encryptionType}' --output table 2>/dev/null || echo "No ECR repositories found"

# GCP: GKE cluster security
gcloud container clusters list --format="table(name,location,status,currentMasterVersion,network)" 2>/dev/null || echo "No GKE clusters found"

# Container Analysis API for vulnerability scanning
gcloud container images list --repository=gcr.io/PROJECT_ID --format="table(name,tags)" 2>/dev/null || echo "No container images found in GCR"
```

### Serverless Security Assessment
```bash
# Azure Functions security configuration
az functionapp list --query '[].{Name:name, ResourceGroup:resourceGroup, RuntimeVersion:siteConfig.linuxFxVersion, HttpsOnly:httpsOnly}' -o table

# AWS Lambda security
aws lambda list-functions --query 'Functions[].{FunctionName:FunctionName, Runtime:Runtime, VpcConfig:VpcConfig.VpcId, ReservedConcurrencyExecutions:ReservedConcurrencyExecutions}' --output table

# GCP Cloud Functions security
gcloud functions list --format="table(name,status,runtime,httpsTrigger.url)" 2>/dev/null || echo "No Cloud Functions found"
```

## Multi-Cloud Monitoring and Alerting

### Security Operations Center (SOC) Integration
```python
# Python script for multi-cloud security event correlation
import json
import requests
from datetime import datetime, timedelta

def get_azure_security_alerts(subscription_id, access_token):
    """Retrieve Azure Security Center alerts"""
    headers = {'Authorization': f'Bearer {access_token}'}
    url = f"https://management.azure.com/subscriptions/{subscription_id}/providers/Microsoft.Security/alerts"
    
    try:
        response = requests.get(url, headers=headers)
        return response.json().get('value', [])
    except Exception as e:
        print(f"Error fetching Azure alerts: {e}")
        return []

def correlate_multi_cloud_events(azure_alerts, aws_findings, gcp_findings):
    """Correlate security events across cloud platforms"""
    correlated_events = []
    
    # Common indicators for correlation
    for azure_alert in azure_alerts:
        azure_ip = extract_ip_from_alert(azure_alert)
        azure_time = parse_alert_time(azure_alert)
        
        # Look for related events in other clouds within time window
        time_window = timedelta(minutes=30)
        
        related_aws = [
            finding for finding in aws_findings 
            if time_within_window(finding['time'], azure_time, time_window)
            and has_common_indicators(azure_alert, finding)
        ]
        
        related_gcp = [
            finding for finding in gcp_findings
            if time_within_window(finding['time'], azure_time, time_window)
            and has_common_indicators(azure_alert, finding)
        ]
        
        if related_aws or related_gcp:
            correlated_events.append({
                'primary_event': azure_alert,
                'related_aws': related_aws,
                'related_gcp': related_gcp,
                'correlation_confidence': calculate_confidence(azure_alert, related_aws, related_gcp)
            })
    
    return correlated_events

# Example usage for SOC dashboard integration
def generate_multi_cloud_security_dashboard():
    """Generate unified security dashboard data"""
    dashboard_data = {
        'cloud_security_posture': {
            'azure': calculate_azure_security_score(),
            'aws': calculate_aws_security_score(), 
            'gcp': calculate_gcp_security_score()
        },
        'active_threats': get_active_threats_all_clouds(),
        'compliance_status': get_compliance_status_all_clouds(),
        'incident_trends': get_incident_trends_all_clouds()
    }
    
    return dashboard_data
```

### Cross-Cloud Threat Hunting
```bash
# Multi-cloud threat hunting script
#!/bin/bash

echo "=== Multi-Cloud Threat Hunting Report ==="
echo "Generated: $(date)"
echo

# Azure: Suspicious sign-in activities
echo "=== Azure Threat Indicators ==="
echo "Checking for suspicious sign-in activities..."
az rest --method POST \
    --uri "https://graph.microsoft.com/v1.0/auditLogs/signIns" \
    --body '{
        "filter": "createdDateTime ge '$(date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%SZ)' and riskLevelDuringSignIn eq '"'"'high'"'"'"
    }' \
    --headers "Content-Type=application/json" | jq '.value[].{userPrincipalName, createdDateTime, riskLevelDuringSignIn, ipAddress}'

# AWS: CloudTrail analysis for anomalous activities
echo "=== AWS Threat Indicators ==="
aws logs filter-log-events \
    --log-group-name "CloudTrail/SecurityEvents" \
    --start-time $(date -d "7 days ago" +%s)000 \
    --filter-pattern "{ $.errorCode = \"*Unauthorized*\" || $.errorCode = \"*Forbidden*\" }" \
    --query 'events[].{Time:eventTime, User:userIdentity.type, Event:eventName, Source:sourceIPAddress}' \
    --output table 2>/dev/null || echo "CloudTrail logs not accessible"

# GCP: Audit log analysis
echo "=== GCP Threat Indicators ==="
gcloud logging read 'protoPayload.serviceName="compute.googleapis.com" AND protoPayload.methodName="compute.instances.start" AND timestamp >= "'$(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)'"' \
    --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.resourceName)" \
    --limit=10 2>/dev/null || echo "GCP audit logs not accessible"

# Cross-cloud IP correlation
echo "=== Cross-Cloud IP Analysis ==="
echo "Analyzing common source IPs across cloud platforms..."
# This would require custom correlation logic based on collected logs

echo "=== Threat Hunting Complete ==="
```

## Risk Assessment Framework

### Multi-Cloud Risk Scoring Matrix
| Risk Factor | Azure Weight | AWS Weight | GCP Weight | Hybrid Weight |
|-------------|--------------|------------|------------|---------------|
| Identity Federation Gaps | 2.0 | 2.0 | 2.0 | 3.0 |
| Network Segmentation | 1.5 | 1.5 | 1.5 | 2.0 |
| Data Encryption Inconsistency | 2.5 | 2.5 | 2.5 | 1.5 |
| Monitoring Blind Spots | 2.0 | 2.0 | 2.0 | 3.0 |
| Compliance Violations | 3.0 | 3.0 | 3.0 | 2.0 |

### Business Impact Assessment
```python
def calculate_multi_cloud_business_impact(finding, cloud_distribution):
    """Calculate business impact of security findings across clouds"""
    
    base_impact = {
        'critical': 10,
        'high': 7,
        'medium': 4,
        'low': 2
    }.get(finding.severity.lower(), 1)
    
    # Cloud distribution impact multiplier
    cloud_count = len(cloud_distribution)
    if cloud_count > 2:  # Multi-cloud complexity
        complexity_multiplier = 1.3
    elif cloud_count == 2:  # Hybrid cloud
        complexity_multiplier = 1.1
    else:  # Single cloud
        complexity_multiplier = 1.0
    
    # Data sensitivity across clouds
    cross_cloud_data = any(
        dist.get('contains_sensitive_data') 
        for dist in cloud_distribution.values()
    )
    
    sensitivity_multiplier = 1.5 if cross_cloud_data else 1.0
    
    # Regulatory impact (GDPR, HIPAA, etc.)
    regulatory_regions = sum(
        1 for dist in cloud_distribution.values()
        if dist.get('regulatory_requirements')
    )
    
    regulatory_multiplier = 1.0 + (regulatory_regions * 0.2)
    
    final_impact = min(
        base_impact * complexity_multiplier * sensitivity_multiplier * regulatory_multiplier,
        10
    )
    
    return round(final_impact, 1)
```

## Compliance Reporting

### Multi-Cloud Compliance Dashboard
```bash
# Generate compliance report across all cloud platforms
#!/bin/bash

REPORT_DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="./multi-cloud-compliance-report-$REPORT_DATE"
mkdir -p "$OUTPUT_DIR"

echo "Generating Multi-Cloud Compliance Report: $REPORT_DATE"

# Azure compliance export
echo "Extracting Azure compliance data..."
az policy state summarize --top 20 --query 'value[].{PolicyDefinition:policyDefinitionId, NonCompliantResources:results.nonCompliantResources, CompliantResources:results.compliantResources}' -o json > "$OUTPUT_DIR/azure-compliance.json"

# AWS Config compliance (if available)
echo "Extracting AWS compliance data..."
aws configservice get-compliance-summary-by-config-rule --query '{CompliantRules:ComplianceSummary.CompliantResourceCount.CappedCount, NonCompliantRules:ComplianceSummary.NonCompliantResourceCount.CappedCount}' --output json > "$OUTPUT_DIR/aws-compliance.json" 2>/dev/null || echo '{"error": "AWS Config not available"}' > "$OUTPUT_DIR/aws-compliance.json"

# GCP Security Command Center compliance
echo "Extracting GCP compliance data..."
gcloud scc findings list --organization=$(gcloud organizations list --format="value(name)" 2>/dev/null) --filter='state="ACTIVE"' --format="json" > "$OUTPUT_DIR/gcp-compliance.json" 2>/dev/null || echo '{"error": "GCP SCC not available"}' > "$OUTPUT_DIR/gcp-compliance.json"

# Generate consolidated report
python3 -c "
import json
import os

def load_json_file(filepath):
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except:
        return {'error': 'File not found or invalid JSON'}

output_dir = '$OUTPUT_DIR'
azure_data = load_json_file(f'{output_dir}/azure-compliance.json')
aws_data = load_json_file(f'{output_dir}/aws-compliance.json')
gcp_data = load_json_file(f'{output_dir}/gcp-compliance.json')

consolidated_report = {
    'report_date': '$REPORT_DATE',
    'azure': azure_data,
    'aws': aws_data,
    'gcp': gcp_data,
    'summary': {
        'clouds_assessed': len([d for d in [azure_data, aws_data, gcp_data] if 'error' not in d]),
        'total_findings': 'TBD - requires parsing of individual cloud findings'
    }
}

with open(f'{output_dir}/consolidated-compliance-report.json', 'w') as f:
    json.dump(consolidated_report, f, indent=2)

print(f'Compliance report generated in {output_dir}')
"

echo "Multi-cloud compliance report generated in: $OUTPUT_DIR"
```

## Remediation Strategies

### Identity Federation Remediation
```bash
# Establish Azure AD as the central identity provider
# Configure AWS IAM Identity Center (successor to SSO)
aws sso-admin create-instance-access-control-attribute-configuration \
    --instance-arn "arn:aws:sso:::instance/ssoins-example" \
    --instance-access-control-attribute-configuration '{
        "AccessControlAttributes": [
            {
                "Key": "Department",
                "Value": {
                    "Source": ["${path:enterprise.department}"]
                }
            }
        ]
    }' 2>/dev/null || echo "AWS SSO configuration requires manual setup"

# Configure GCP Workforce Identity Federation
gcloud iam workforce-pools create workforce-pool-azure-ad \
    --location=global \
    --display-name="Azure AD Workforce Pool" \
    --description="Workforce pool for Azure AD federation" 2>/dev/null || echo "GCP Workforce Identity requires manual configuration"
```

### Network Security Harmonization
```bash
# Deploy consistent network security policies
# Azure: Create standardized NSG rules
az network nsg rule create \
    --name "DenyInternetInbound" \
    --nsg-name "StandardSecurityGroup" \
    --resource-group "NetworkSecurity-RG" \
    --priority 4000 \
    --source-address-prefixes "Internet" \
    --access "Deny" \
    --protocol "*" \
    --direction "Inbound"

# AWS: Create VPC security group with similar rules
aws ec2 create-security-group \
    --group-name "StandardSecurityGroup" \
    --description "Standard security group with restrictive inbound rules" \
    --vpc-id "vpc-12345678" 2>/dev/null || echo "VPC ID required for AWS security group creation"

# GCP: Create firewall rule
gcloud compute firewall-rules create deny-internet-inbound \
    --direction=INGRESS \
    --priority=1000 \
    --source-ranges=0.0.0.0/0 \
    --action=DENY \
    --rules=all \
    --description="Deny all inbound traffic from internet" 2>/dev/null || echo "GCP firewall rule creation requires project access"
```

### Unified Monitoring Setup
```bash
# Deploy Azure Sentinel with multi-cloud connectors
az sentinel data-connector create \
    --workspace-name "MultiCloudSentinel" \
    --resource-group "Security-RG" \
    --connector-id "AmazonWebServicesCloudTrail" \
    --content '{
        "kind": "AmazonWebServicesCloudTrail",
        "properties": {
            "awsRoleArn": "arn:aws:iam::123456789012:role/SentinelRole",
            "logs": ["CloudTrail"]
        }
    }' 2>/dev/null || echo "Sentinel data connector requires manual configuration"

# Configure log forwarding from AWS CloudTrail
aws logs create-log-stream \
    --log-group-name "MultiCloudSecurity" \
    --log-stream-name "AWSCloudTrailToSentinel" 2>/dev/null || echo "CloudTrail log forwarding requires manual setup"

# Configure GCP log sink to external SIEM
gcloud logging sinks create sentinel-sink \
    bigquery.googleapis.com/projects/PROJECT_ID/datasets/security_logs \
    --log-filter='protoPayload.serviceName=("compute.googleapis.com" OR "iam.googleapis.com" OR "cloudresourcemanager.googleapis.com")' 2>/dev/null || echo "GCP log sink requires manual configuration"
```

## Assessment Report Template

### Executive Summary
**Multi-Cloud Security Assessment Summary**
- **Assessment Period**: [Start Date] - [End Date]
- **Environments Assessed**: Azure ([X] subscriptions), AWS ([Y] accounts), GCP ([Z] projects)
- **Overall Risk Rating**: [Rating]/10
- **Critical Cross-Cloud Risks**: [Count]

**Key Risk Areas**:
1. **Identity Federation Gaps**: Inconsistent identity policies across cloud platforms
2. **Network Segmentation**: Lack of unified network security controls
3. **Data Protection**: Inconsistent encryption and data classification
4. **Monitoring Blind Spots**: Limited cross-cloud security visibility

**Immediate Actions Required**:
- Establish centralized identity federation with Azure AD
- Deploy unified SIEM solution (Azure Sentinel) with multi-cloud connectors
- Implement consistent network security policies across all clouds
- Establish cross-cloud incident response procedures

### Detailed Findings by Cloud Platform

#### Azure Environment
- **Security Score**: [X]/100 (Microsoft Secure Score)
- **Critical Issues**: [Count]
- **Compliance Status**: 
  - ISO 27001: [X]% compliant
  - SOC 2: [Y]% compliant
  - GDPR: [Z]% compliant

#### AWS Environment  
- **Security Score**: [X]/100 (AWS Security Hub Score)
- **Critical Issues**: [Count]
- **Compliance Status**:
  - CIS AWS Foundations: [X]% compliant
  - AWS Well-Architected Security: [Y]% compliant

#### GCP Environment
- **Security Score**: [X]/100 (Security Command Center Score)
- **Critical Issues**: [Count]
- **Compliance Status**:
  - CIS GCP Foundations: [X]% compliant
  - Google Cloud Security Best Practices: [Y]% compliant

### Cross-Cloud Risk Matrix
| Risk Category | Azure Impact | AWS Impact | GCP Impact | Hybrid Impact | Overall Risk |
|---------------|--------------|------------|------------|---------------|--------------|
| Identity & Access | High | Medium | Low | Critical | High |
| Network Security | Medium | High | Medium | High | High |
| Data Protection | Low | Medium | High | Medium | Medium |
| Monitoring | High | High | High | Critical | Critical |

### Remediation Roadmap

#### Phase 1: Foundation (0-3 months)
- [ ] Deploy centralized identity federation
- [ ] Establish unified monitoring and SIEM
- [ ] Implement basic network segmentation
- [ ] Create incident response procedures

#### Phase 2: Hardening (3-6 months)
- [ ] Deploy advanced threat protection across clouds
- [ ] Implement data classification and protection
- [ ] Establish automated compliance monitoring
- [ ] Deploy security automation and orchestration

#### Phase 3: Optimization (6-12 months)
- [ ] Implement advanced threat hunting capabilities
- [ ] Deploy cloud security posture management (CSPM)
- [ ] Establish continuous compliance validation
- [ ] Optimize security operations and costs

### Cost-Benefit Analysis
**Security Investment Required**: $[X] over 12 months
- Identity federation platform: $[Y]
- SIEM/SOAR solution: $[Z]
- Security tooling and licenses: $[A]
- Professional services: $[B]

**Risk Reduction Value**: $[X] in avoided breach costs
**Compliance Value**: $[Y] in audit preparation savings
**Operational Efficiency**: $[Z] in reduced manual security tasks

**ROI**: [X]% within 18 months

This comprehensive assessment provides the foundation for establishing a robust, unified security posture across your multi-cloud environment while maintaining operational efficiency and regulatory compliance.