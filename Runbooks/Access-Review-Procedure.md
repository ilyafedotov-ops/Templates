# Azure Access Review Operational Runbook

## Overview

This operational runbook provides comprehensive procedures for conducting periodic access reviews in Azure environments to ensure compliance with ISO 27001:2022 controls (A.9.2.5, A.9.2.6) and SOC 2 Type II logical access controls (CC6.1-CC6.3). The runbook emphasizes automation, observability, and repeatable processes aligned with SRE principles.

**Runbook Version**: 2.1  
**Last Updated**: 2024-12-01  
**Review Cycle**: Quarterly  
**Approval Authority**: CISO, IT Operations Manager  

## Scope and Applicability

### In-Scope Access Types
- **Azure AD/Entra ID Privileged Roles**: Global Administrator, Security Administrator, Cloud Application Administrator
- **Azure RBAC Privileged Assignments**: Owner, Contributor, User Access Administrator at subscription/management group level
- **Privileged Identity Management (PIM)**: All eligible and active role assignments
- **Application Registrations**: Service principals with high-privilege permissions
- **Custom RBAC Roles**: All custom roles with write/delete permissions
- **Resource-Specific Access**: Key Vault, Storage Account, Database admin roles
- **Guest User Access**: External users with resource access
- **Service Accounts**: Managed identities and service principals
- **Conditional Access Exclusions**: Users exempt from security policies

### Out-of-Scope Items
- Standard user mailbox permissions (covered by separate Exchange review)
- Azure DevOps project permissions (covered by DevOps access review)
- On-premises Active Directory (separate domain controller review)

## Regulatory and Compliance Requirements

### ISO 27001:2022 Control Mapping
- **A.9.2.5 Review of user access rights**: Periodic review of access rights
- **A.9.2.6 Removal or adjustment of access rights**: Process for access modification/removal

### SOC 2 Type II Control Mapping
- **CC6.1**: Logical and physical access controls
- **CC6.2**: Prior authorization for system access
- **CC6.3**: User access modification and termination

### Compliance Evidence Requirements
- Review completion certificates
- Exception approvals and justifications
- Remediation tracking and closure evidence
- Management attestation of review effectiveness

## Review Schedule and Frequency

| Access Type | Review Frequency | Lead Time | Completion SLA |
|-------------|-----------------|-----------|----------------|
| Global Admin/Security Admin | Monthly | 5 business days | 10 business days |
| PIM Eligible Roles | Quarterly | 10 business days | 15 business days |
| Azure RBAC Privileged | Quarterly | 10 business days | 15 business days |
| Service Principals (High-Privilege) | Quarterly | 7 business days | 12 business days |
| Custom RBAC Roles | Semi-annually | 10 business days | 20 business days |
| Guest Users | Semi-annually | 7 business days | 15 business days |
| Resource-Specific Admin | Semi-annually | 7 business days | 15 business days |

### Review Calendar
- **Q1**: January 15-31 (PIM, RBAC, Service Principals)
- **Q2**: April 15-30 (PIM, RBAC, Service Principals)  
- **Q3**: July 15-31 (PIM, RBAC, Service Principals, Custom Roles, Guests, Resources)
- **Q4**: October 15-31 (PIM, RBAC, Service Principals)
- **Monthly**: 15th of each month (Global/Security Admins)

## Roles and Responsibilities

### RACI Matrix
| Activity | Security Team | Identity Team | Business Owner | Resource Owner | ITSM | Auditors |
|----------|---------------|---------------|----------------|----------------|------|----------|
| Review Planning | R | A | I | C | I | I |
| Data Collection | R | C | I | I | I | I |
| Review Execution | C | R | A | A | I | I |
| Exception Handling | A | R | C | C | C | I |
| Remediation | C | C | A | A | R | I |
| Evidence Collection | R | C | I | I | I | A |
| Reporting | R | C | I | I | I | C |

**Legend**: R-Responsible, A-Accountable, C-Consulted, I-Informed

## Pre-Review Preparation

### Environment Validation
Execute the following validation steps 5 business days before review start:

```powershell
# 1. Validate Azure AD Connect Health
Connect-AzureAD
$ConnectHealth = Get-AzureADConnectHealthSyncService
if ($ConnectHealth.State -ne "Active") {
    Write-Warning "Azure AD Connect sync issues detected"
    # Escalate to Identity Team
}

# 2. Verify PIM service status  
$PIMStatus = Get-AzureADMSPrivilegedRoleDefinition -ProviderId "aadRoles" -ResourceId $TenantId
if (!$PIMStatus) {
    Write-Error "PIM service unavailable - defer review"
    exit 1
}

# 3. Check Log Analytics workspace connectivity
$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-security-ops"
if ($Workspace.ProvisioningState -ne "Succeeded") {
    Write-Warning "Log Analytics connectivity issues"
}

# 4. Validate PowerBI workspace for reporting
Test-PowerBIWorkspace -WorkspaceName "Security-Governance-Reports"
```

### Stakeholder Notification
Send automated notifications 10 business days before review:

```bash
# Automated stakeholder notification
az account show --query tenantId -o tsv > tenant_id.txt
TENANT_ID=$(cat tenant_id.txt)

# Generate stakeholder list from Azure AD groups
az ad group member list \
    --group "Security-Review-Stakeholders" \
    --query "[].mail" -o tsv > stakeholders.txt

# Send calendar invites with review assignments
python3 Scripts/send-review-notifications.py \
    --stakeholders stakeholders.txt \
    --review-type "quarterly-access-review" \
    --start-date "2024-01-15" \
    --duration-days 15
```

## Data Collection and Extraction

### 1. Azure AD Privileged Role Assignments

```powershell
# Extract privileged role assignments
$PrivilegedRoles = @(
    "62e90394-69f5-4237-9190-012177145e10",  # Global Administrator
    "194ae4cb-b126-40b2-bd5b-6091b380977d",  # Security Administrator  
    "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3",  # Application Administrator
    "c4e39bd9-1100-46d3-8c65-fb160da0071f",  # Authentication Administrator
    "729827e3-9c14-49f7-bb1b-9608f156bbb8",  # Helpdesk Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1"   # User Administrator
)

$ReviewData = @()
foreach ($RoleId in $PrivilegedRoles) {
    $RoleMembers = Get-AzureADDirectoryRoleMember -ObjectId $RoleId
    foreach ($Member in $RoleMembers) {
        $ReviewData += [PSCustomObject]@{
            Role = (Get-AzureADDirectoryRole -ObjectId $RoleId).DisplayName
            UserPrincipalName = $Member.UserPrincipalName
            DisplayName = $Member.DisplayName
            ObjectId = $Member.ObjectId
            AccountEnabled = $Member.AccountEnabled
            LastSignIn = (Get-AzureADAuditSignInLogs -Filter "userId eq '$($Member.ObjectId)'" -Top 1).CreatedDateTime
            AssignmentType = "Permanent"
            ReviewDate = Get-Date -Format "yyyy-MM-dd"
            BusinessJustification = ""
            ReviewStatus = "Pending"
            ManagerEmail = (Get-AzureADUserManager -ObjectId $Member.ObjectId).Mail
        }
    }
}

# Export to CSV for review
$ReviewData | Export-Csv -Path "Reviews/AzureAD-PrivilegedRoles-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
```

### 2. PIM Eligible and Active Assignments

```powershell
# Extract PIM assignments using Microsoft Graph PowerShell
Import-Module Microsoft.Graph.Identity.Governance

# Get eligible role assignments
$EligibleAssignments = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -All
$EligibleReviewData = @()

foreach ($Assignment in $EligibleAssignments) {
    $Principal = Get-MgDirectoryObject -DirectoryObjectId $Assignment.PrincipalId
    $RoleDefinition = Get-MgRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $Assignment.RoleDefinitionId
    
    $EligibleReviewData += [PSCustomObject]@{
        Role = $RoleDefinition.DisplayName
        PrincipalName = $Principal.DisplayName
        PrincipalType = $Principal.AdditionalProperties["@odata.type"]
        AssignmentType = "Eligible"
        StartDateTime = $Assignment.StartDateTime
        EndDateTime = $Assignment.EndDateTime
        AssignmentState = $Assignment.AssignmentType
        Justification = $Assignment.DirectoryScope
        ReviewStatus = "Pending"
    }
}

$EligibleReviewData | Export-Csv -Path "Reviews/PIM-EligibleAssignments-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
```

### 3. Azure RBAC Role Assignments

```bash
#!/bin/bash
# Extract Azure RBAC assignments at subscription level

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
REVIEW_DATE=$(date +%Y-%m-%d)

# Get high-privilege RBAC assignments
az role assignment list \
    --subscription $SUBSCRIPTION_ID \
    --query "[?contains(roleDefinitionName, 'Owner') || contains(roleDefinitionName, 'Contributor') || contains(roleDefinitionName, 'User Access Administrator')].{
        Role: roleDefinitionName,
        PrincipalName: principalName,
        PrincipalType: principalType,
        Scope: scope,
        PrincipalId: principalId
    }" \
    --output json > "Reviews/RBAC-Assignments-${REVIEW_DATE}.json"

# Convert to CSV format for review
jq -r '["Role","PrincipalName","PrincipalType","Scope","PrincipalId","ReviewStatus","BusinessJustification"], 
       (.[] | [.Role, .PrincipalName, .PrincipalType, .Scope, .PrincipalId, "Pending", ""]) | @csv' \
       "Reviews/RBAC-Assignments-${REVIEW_DATE}.json" > "Reviews/RBAC-Assignments-${REVIEW_DATE}.csv"
```

### 4. Service Principal High-Privilege Permissions

```powershell
# Extract service principals with high-privilege permissions
$ServicePrincipals = Get-AzureADServicePrincipal -All $true
$SPReviewData = @()

foreach ($SP in $ServicePrincipals) {
    # Check for high-privilege app roles
    $AppRoles = Get-AzureADServicePrincipalAppRoleAssignment -ObjectId $SP.ObjectId
    
    foreach ($Role in $AppRoles) {
        $ResourceSP = Get-AzureADServicePrincipal -ObjectId $Role.ResourceId
        $AppRoleDefinition = $ResourceSP.AppRoles | Where-Object {$_.Id -eq $Role.Id}
        
        # Filter for high-privilege permissions
        if ($AppRoleDefinition.Value -match "(Admin|Write|Full|Directory)" -or 
            $AppRoleDefinition.DisplayName -match "(Admin|Write|Full|Directory)") {
            
            $SPReviewData += [PSCustomObject]@{
                ServicePrincipalName = $SP.DisplayName
                ServicePrincipalId = $SP.ObjectId
                ApplicationId = $SP.AppId
                Permission = $AppRoleDefinition.DisplayName
                PermissionValue = $AppRoleDefinition.Value
                ResourceName = $ResourceSP.DisplayName
                CreatedDateTime = $Role.CreationTimestamp
                ReviewStatus = "Pending"
                BusinessOwner = ""
                Justification = ""
            }
        }
    }
}

$SPReviewData | Export-Csv -Path "Reviews/ServicePrincipal-Permissions-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
```

### 5. Guest User Access Review

```bash
#!/bin/bash
# Extract guest users with resource access

az ad user list \
    --filter "userType eq 'Guest'" \
    --query "[].{
        UserPrincipalName: userPrincipalName,
        DisplayName: displayName,
        CreatedDateTime: createdDateTime,
        LastSignInDateTime: signInActivity.lastSignInDateTime,
        ObjectId: objectId,
        AccountEnabled: accountEnabled
    }" \
    --output json > "Reviews/GuestUsers-$(date +%Y-%m-%d).json"

# Check guest user group memberships
az ad user list --filter "userType eq 'Guest'" --query "[].objectId" -o tsv | \
while read GUEST_ID; do
    echo "Checking groups for guest: $GUEST_ID"
    az ad user get-member-groups --id $GUEST_ID --query "[].displayName" -o tsv >> "Reviews/GuestUser-Groups-$(date +%Y-%m-%d).txt"
done
```

## Automated Review Workflows

### 1. Azure AD Access Review Configuration

```powershell
# Create automated access reviews using Graph API
$AccessReviewDefinition = @{
    displayName = "Quarterly Privileged Role Review - Q1 2024"
    descriptionForAdmins = "Review of all privileged role assignments"
    descriptionForReviewers = "Please review and confirm business need for privileged access"
    scope = @{
        "@odata.type" = "#microsoft.graph.accessReviewQueryScope"
        query = "/groups/transitive/members"
        queryType = "MicrosoftGraph"
        queryRoot = "groups/8b510e5e-7f55-4c40-9bdc-e3c4c8b0b5e0" # Privileged roles group
    }
    reviewers = @(
        @{
            query = "./manager"
            queryType = "MicrosoftGraph"
        }
    )
    settings = @{
        mailNotificationsEnabled = $true
        reminderNotificationsEnabled = $true
        defaultDecision = "None"
        defaultDecisionEnabled = $false
        instanceDurationInDays = 15
        recommendationsEnabled = $true
        autoApplyDecisionsEnabled = $false
        recurrence = @{
            pattern = @{
                type = "absoluteMonthly"
                interval = 3
                dayOfMonth = 15
            }
            range = @{
                type = "noEnd"
                startDate = "2024-01-15"
            }
        }
    }
}

# Create the access review using Graph API
Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions" `
    -Method POST -Body ($AccessReviewDefinition | ConvertTo-Json -Depth 10) -ContentType "application/json"
```

### 2. PIM Access Review Automation

```powershell
# Automate PIM access review creation
$PIMReviewConfig = @{
    reviewName = "PIM Eligible Assignments Review"
    reviewDescription = "Quarterly review of PIM eligible role assignments"
    reviewers = @("manager", "resourceOwner")
    duration = 15
    recurrence = "quarterly"
    emailNotification = $true
    recommendationEnabled = $true
}

# Create PIM access review
New-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId "aadRoles" `
    -ResourceId $TenantId `
    -RoleDefinitionId $RoleId `
    -SubjectId $UserId `
    -Type "AdminUpdate" `
    -Reason "Access Review Remediation" `
    -Schedule @{
        StartDateTime = (Get-Date).AddDays(1)
        EndDateTime = (Get-Date).AddDays(16)
        Type = "Once"
    }
```

### 3. ITSM Integration Workflow

```python
#!/usr/bin/env python3
"""
Azure Access Review ITSM Integration
Automatically creates ServiceNow tickets for review assignments
"""

import requests
import json
import os
from datetime import datetime, timedelta

class ServiceNowIntegration:
    def __init__(self):
        self.instance = os.getenv('SERVICENOW_INSTANCE')
        self.username = os.getenv('SERVICENOW_USERNAME') 
        self.password = os.getenv('SERVICENOW_PASSWORD')
        self.base_url = f"https://{self.instance}.service-now.com"
        
    def create_review_ticket(self, review_data):
        """Create ServiceNow ticket for access review"""
        
        ticket_data = {
            'short_description': f"Access Review Required: {review_data['review_type']}",
            'description': f"""
                Access Review Assignment:
                - Review Type: {review_data['review_type']}
                - Assigned To: {review_data['reviewer']}
                - Due Date: {review_data['due_date']}
                - Items Count: {review_data['item_count']}
                - Priority: {review_data['priority']}
                
                Instructions:
                1. Review assigned access items in Azure portal
                2. Approve/Deny each item with justification
                3. Update ticket with completion status
                4. Attach review evidence
            """,
            'category': 'Security',
            'subcategory': 'Access Review',
            'priority': '2' if review_data['priority'] == 'High' else '3',
            'assigned_to': review_data['reviewer'],
            'due_date': review_data['due_date'],
            'caller_id': 'azure.accessreview@company.com',
            'state': '2'  # In Progress
        }
        
        response = requests.post(
            f"{self.base_url}/api/now/table/incident",
            auth=(self.username, self.password),
            headers={'Content-Type': 'application/json'},
            data=json.dumps(ticket_data)
        )
        
        if response.status_code == 201:
            ticket = response.json()['result']
            return ticket['number'], ticket['sys_id']
        else:
            raise Exception(f"Failed to create ticket: {response.text}")

    def update_ticket_completion(self, sys_id, completion_data):
        """Update ticket when review is completed"""
        
        update_data = {
            'work_notes': f"""
                Access Review Completed:
                - Completion Date: {completion_data['completion_date']}
                - Items Reviewed: {completion_data['items_reviewed']}
                - Items Approved: {completion_data['items_approved']}
                - Items Denied: {completion_data['items_denied']}
                - Exceptions: {completion_data['exceptions']}
            """,
            'state': '6',  # Resolved
            'resolution_code': 'Completed',
            'close_notes': 'Access review completed successfully'
        }
        
        response = requests.patch(
            f"{self.base_url}/api/now/table/incident/{sys_id}",
            auth=(self.username, self.password),
            headers={'Content-Type': 'application/json'},
            data=json.dumps(update_data)
        )
        
        return response.status_code == 200

# Usage example
if __name__ == "__main__":
    servicenow = ServiceNowIntegration()
    
    # Create review tickets from CSV data
    review_assignments = [
        {
            'review_type': 'Azure AD Privileged Roles',
            'reviewer': 'john.smith@company.com',
            'due_date': '2024-01-30',
            'item_count': 25,
            'priority': 'High'
        }
    ]
    
    for assignment in review_assignments:
        ticket_number, sys_id = servicenow.create_review_ticket(assignment)
        print(f"Created ticket {ticket_number} with sys_id {sys_id}")
```

## Review Execution Process

### Phase 1: Manager Review (Days 1-5)
1. **Automated Assignment Distribution**
   ```bash
   # Send review assignments to managers
   python3 Scripts/distribute-reviews.py \
       --review-type "privileged-roles" \
       --input-file "Reviews/AzureAD-PrivilegedRoles-2024-01-15.csv" \
       --notification-template "manager-review-notification.html"
   ```

2. **Manager Review Portal Access**
   - Access via Azure portal: https://portal.azure.com/#blade/Microsoft_AAD_ERM/DashboardBlade
   - Review assigned users under their management
   - Provide business justification for continued access
   - Escalate exceptions to security team

3. **Daily Progress Monitoring**
   ```powershell
   # Monitor review progress
   $ProgressQuery = @"
   IdentityGovernanceLogs
   | where TimeGenerated > ago(24h)
   | where Category == "AccessReviewDecision"
   | summarize 
       TotalDecisions = count(),
       ApprovedCount = countif(Decision == "Approve"),
       DeniedCount = countif(Decision == "Deny"),
       PendingCount = countif(Decision == "NotReviewed")
   | extend CompletionPercentage = (TotalDecisions - PendingCount) * 100 / TotalDecisions
   "@

   Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $ProgressQuery
   ```

### Phase 2: Security Team Validation (Days 6-10)
1. **Risk-Based Review Prioritization**
   ```powershell
   # Identify high-risk assignments for priority review
   $HighRiskCriteria = @"
   AuditLogs
   | where TimeGenerated > ago(30d)
   | where Category == "RoleManagement"
   | where OperationName contains "Add member to role"
   | join kind=inner (
       SigninLogs
       | where TimeGenerated > ago(7d)
       | where RiskLevelDuringSignIn == "High"
   ) on UserId
   | project UserId, UserPrincipalName, RoleName, RiskLevel, TimeGenerated
   "@
   ```

2. **Anomaly Detection Analysis**
   ```bash
   # Run anomaly detection on access patterns
   az monitor log-analytics query \
       --workspace $LOG_ANALYTICS_WORKSPACE_ID \
       --analytics-query "
       SigninLogs
       | where TimeGenerated > ago(90d)
       | where ResultType == 0
       | summarize 
           SigninCount = count(),
           UniqueApps = dcount(AppDisplayName),
           UniqueIPs = dcount(IPAddress),
           Countries = make_set(LocationDetails.countryOrRegion)
       by UserPrincipalName
       | where SigninCount < 5 or UniqueIPs > 10
       | project UserPrincipalName, SigninCount, UniqueIPs, Countries
       " --output table
   ```

### Phase 3: Business Owner Confirmation (Days 8-12)
1. **Business Impact Assessment**
   - Resource owners confirm business need
   - Alternative access methods evaluation
   - Temporary vs. permanent access determination

2. **Exception Processing**
   ```python
   # Process access review exceptions
   def process_exception(exception_data):
       required_fields = [
           'user_principal_name',
           'role_name', 
           'business_justification',
           'expiration_date',
           'approver_email',
           'risk_assessment'
       ]
       
       # Validate exception request
       for field in required_fields:
           if not exception_data.get(field):
               raise ValueError(f"Missing required field: {field}")
       
       # Auto-approve low-risk exceptions
       if exception_data['risk_assessment'].lower() == 'low':
           return auto_approve_exception(exception_data)
       else:
           return escalate_to_security_team(exception_data)
   ```

### Phase 4: Remediation and Cleanup (Days 13-15)
1. **Automated Removal Process**
   ```powershell
   # Process approved removals
   $RemovalList = Import-Csv "Reviews/Approved-Removals-2024-01-15.csv"
   
   foreach ($Removal in $RemovalList) {
       try {
           if ($Removal.AssignmentType -eq "AzureAD") {
               Remove-AzureADDirectoryRoleMember -ObjectId $Removal.RoleId -MemberId $Removal.UserId
               Write-Log "Removed $($Removal.UserPrincipalName) from $($Removal.RoleName)"
           }
           elseif ($Removal.AssignmentType -eq "PIM") {
               Remove-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -Id $Removal.AssignmentId
               Write-Log "Removed PIM assignment for $($Removal.UserPrincipalName)"
           }
           elseif ($Removal.AssignmentType -eq "RBAC") {
               Remove-AzRoleAssignment -SignInName $Removal.UserPrincipalName -RoleDefinitionName $Removal.RoleName -Scope $Removal.Scope
               Write-Log "Removed RBAC assignment for $($Removal.UserPrincipalName)"
           }
           
           # Update tracking spreadsheet
           Update-RemovalTracking -UserId $Removal.UserId -Status "Completed" -CompletionDate (Get-Date)
           
       } catch {
           Write-Error "Failed to remove access for $($Removal.UserPrincipalName): $($_.Exception.Message)"
           Update-RemovalTracking -UserId $Removal.UserId -Status "Failed" -ErrorMessage $_.Exception.Message
       }
   }
   ```

2. **Verification and Confirmation**
   ```bash
   # Verify removals were successful
   python3 Scripts/verify-removals.py \
       --removal-file "Reviews/Approved-Removals-2024-01-15.csv" \
       --verification-output "Reviews/Removal-Verification-2024-01-30.csv"
   ```

## Exception Handling and Escalation

### Exception Categories
1. **Technical Exceptions**
   - Service account access required for automation
   - Break-glass access for emergency procedures
   - System integration dependencies

2. **Business Exceptions**  
   - Temporary project access extensions
   - Regulatory compliance requirements
   - Audit or investigation access needs

3. **Risk-Based Exceptions**
   - High-value employee access
   - M&A integration access
   - Third-party vendor access

### Exception Approval Matrix

| Exception Type | Risk Level | Approval Required | Max Duration |
|----------------|------------|------------------|--------------|
| Service Account | Low | IT Operations Manager | 12 months |
| Break-glass | Medium | Security Manager + CISO | 6 months |
| Temporary Project | Low-Medium | Business Owner + Security | 3 months |
| Regulatory Compliance | Medium-High | Legal + CISO | 12 months |
| Emergency Access | High | CISO + CTO | 30 days |
| Vendor Access | Medium-High | Business Owner + Security Manager | 6 months |

### Exception Workflow
```yaml
# Exception approval workflow (Azure Logic App)
exception_workflow:
  trigger:
    type: "manual"
    inputs:
      schema:
        user_principal_name: "string"
        role_name: "string"
        justification: "string"
        risk_level: "string"
        duration_days: "integer"
        
  actions:
    1_validate_request:
      type: "condition"
      expression: "@and(not(empty(triggerBody()['justification'])), greater(length(triggerBody()['justification']), 50))"
      
    2_risk_assessment:
      type: "switch"
      expression: "@triggerBody()['risk_level']"
      cases:
        low:
          actions:
            - send_approval_email:
                to: "@triggerBody()['business_owner']"
                subject: "Access Exception Approval Required - Low Risk"
        medium:
          actions:
            - send_approval_email:
                to: ["@triggerBody()['business_owner']", "security-team@company.com"]
                subject: "Access Exception Approval Required - Medium Risk"
        high:
          actions:
            - send_approval_email:
                to: ["@triggerBody()['business_owner']", "security-team@company.com", "ciso@company.com"]
                subject: "Access Exception Approval Required - High Risk"
                
    3_track_exception:
      type: "compose"
      inputs:
        exception_id: "@guid()"
        user_principal_name: "@triggerBody()['user_principal_name']"
        role_name: "@triggerBody()['role_name']"
        approval_status: "pending"
        created_date: "@utcNow()"
        expiration_date: "@addDays(utcNow(), triggerBody()['duration_days'])"
```

## Evidence Collection and Audit Trail

### Compliance Evidence Requirements
1. **Review Completion Documentation**
   ```powershell
   # Generate compliance evidence package
   $EvidencePackage = @{
       ReviewPeriod = "Q1-2024"
       ReviewType = "Quarterly Access Review"
       TotalUsers = $ReviewData.Count
       ReviewedUsers = ($ReviewData | Where-Object {$_.ReviewStatus -eq "Completed"}).Count
       ApprovedAccess = ($ReviewData | Where-Object {$_.Decision -eq "Approved"}).Count
       RemovedAccess = ($ReviewData | Where-Object {$_.Decision -eq "Denied"}).Count
       Exceptions = ($ReviewData | Where-Object {$_.ReviewStatus -eq "Exception"}).Count
       CompletionRate = [math]::Round((($ReviewData | Where-Object {$_.ReviewStatus -eq "Completed"}).Count / $ReviewData.Count) * 100, 2)
       ReviewStartDate = "2024-01-15"
       ReviewEndDate = "2024-01-30"
       EvidenceGeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   }
   
   $EvidencePackage | ConvertTo-Json | Out-File "Evidence/Access-Review-Summary-Q1-2024.json"
   ```

2. **Audit Log Extraction**
   ```bash
   # Extract relevant audit logs for compliance
   REVIEW_START="2024-01-15"
   REVIEW_END="2024-01-30"
   
   # Azure AD audit logs
   az ad signed-in-user list-owned-objects --query "[?createdDateTime >= '$REVIEW_START' && createdDateTime <= '$REVIEW_END']" > "Evidence/AzureAD-AuditLogs-$REVIEW_START-$REVIEW_END.json"
   
   # Azure Activity logs  
   az monitor activity-log list \
       --start-time $REVIEW_START \
       --end-time $REVIEW_END \
       --caller "AccessReviewService" \
       --output json > "Evidence/Azure-ActivityLogs-$REVIEW_START-$REVIEW_END.json"
   ```

3. **Evidence Retention and Storage**
   ```python
   import os
   import shutil
   import hashlib
   from datetime import datetime
   
   def archive_evidence(review_period, evidence_files):
       """Archive evidence files with integrity checks"""
       
       archive_path = f"Evidence/Archive/{review_period}"
       os.makedirs(archive_path, exist_ok=True)
       
       integrity_log = []
       
       for file_path in evidence_files:
           if os.path.exists(file_path):
               # Calculate file hash for integrity
               with open(file_path, 'rb') as f:
                   file_hash = hashlib.sha256(f.read()).hexdigest()
               
               # Copy to archive
               archive_file = os.path.join(archive_path, os.path.basename(file_path))
               shutil.copy2(file_path, archive_file)
               
               integrity_log.append({
                   'file': os.path.basename(file_path),
                   'original_path': file_path,
                   'archive_path': archive_file,
                   'sha256_hash': file_hash,
                   'archive_date': datetime.now().isoformat()
               })
       
       # Save integrity log
       with open(f"{archive_path}/integrity-log.json", 'w') as f:
           json.dump(integrity_log, f, indent=2)
       
       return integrity_log
   ```

### Evidence Package Structure
```
Evidence/
├── Q1-2024/
│   ├── Access-Review-Summary-Q1-2024.json
│   ├── AzureAD-PrivilegedRoles-2024-01-15.csv
│   ├── PIM-EligibleAssignments-2024-01-15.csv
│   ├── RBAC-Assignments-2024-01-15.csv
│   ├── ServicePrincipal-Permissions-2024-01-15.csv
│   ├── GuestUsers-2024-01-15.json
│   ├── Review-Decisions-Export.csv
│   ├── Exception-Approvals.pdf
│   ├── Remediation-Tracking.csv
│   ├── Manager-Attestations.zip
│   └── Audit-Logs/
│       ├── AzureAD-AuditLogs-2024-01-15-2024-01-30.json
│       ├── Azure-ActivityLogs-2024-01-15-2024-01-30.json
│       └── PIM-AuditLogs-2024-01-15-2024-01-30.json
```

## Metrics, KPIs, and Reporting

### Key Performance Indicators
1. **Effectiveness Metrics**
   - Review completion rate: Target >95%
   - On-time completion rate: Target >90%
   - Exception rate: Target <5%
   - Remediation completion rate: Target >98%

2. **Efficiency Metrics**
   - Average review time per user: Target <2 hours
   - Automated vs. manual review ratio: Target 80:20
   - First-time resolution rate: Target >85%
   - False positive rate: Target <10%

3. **Risk Metrics**
   - Privileged access growth rate: Monitor <5% quarterly
   - Dormant account detection rate: Target >95%
   - High-risk access identification: Track trends
   - Compliance gap closure rate: Target >95%

### Automated Reporting Dashboard
```python
# PowerBI Dashboard Data Refresh
import requests
import json
import os

class PowerBIReporting:
    def __init__(self):
        self.tenant_id = os.getenv('AZURE_TENANT_ID')
        self.client_id = os.getenv('POWERBI_CLIENT_ID')
        self.client_secret = os.getenv('POWERBI_CLIENT_SECRET')
        self.workspace_id = os.getenv('POWERBI_WORKSPACE_ID')
        self.dataset_id = os.getenv('ACCESS_REVIEW_DATASET_ID')
        
    def refresh_dataset(self):
        """Trigger PowerBI dataset refresh"""
        
        # Get access token
        token_url = f"https://login.microsoftonline.com/{self.tenant_id}/oauth2/v2.0/token"
        token_data = {
            'grant_type': 'client_credentials',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'scope': 'https://analysis.windows.net/powerbi/api/.default'
        }
        
        token_response = requests.post(token_url, data=token_data)
        access_token = token_response.json()['access_token']
        
        # Trigger dataset refresh
        refresh_url = f"https://api.powerbi.com/v1.0/myorg/groups/{self.workspace_id}/datasets/{self.dataset_id}/refreshes"
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        
        refresh_response = requests.post(refresh_url, headers=headers)
        return refresh_response.status_code == 202

    def get_dashboard_metrics(self):
        """Retrieve key metrics for dashboard"""
        
        metrics = {
            'current_quarter': {
                'review_completion_rate': self.calculate_completion_rate(),
                'on_time_completion_rate': self.calculate_on_time_rate(),
                'exception_rate': self.calculate_exception_rate(),
                'remediation_completion_rate': self.calculate_remediation_rate()
            },
            'trending': {
                'privileged_user_count': self.get_privileged_user_trend(),
                'risk_score_trend': self.get_risk_score_trend(),
                'compliance_score': self.get_compliance_score()
            }
        }
        
        return metrics
```

### Executive Summary Report Template
```markdown
# Access Review Executive Summary - Q1 2024

## Overview
- **Review Period**: January 15-30, 2024
- **Review Type**: Quarterly Privileged Access Review
- **Total Accounts Reviewed**: 1,247
- **Completion Rate**: 97.2%
- **Compliance Status**: COMPLIANT

## Key Findings
### Access Removals
- **Total Removals**: 89 (7.1% of reviewed accounts)
- **Privileged Role Removals**: 23
- **Service Account Cleanup**: 31
- **Guest User Removals**: 35

### Risk Mitigation
- **High-Risk Access Identified**: 12 accounts
- **Dormant Accounts Removed**: 45
- **Excessive Privileges Reduced**: 67 accounts
- **Emergency Access Validated**: 8 accounts

### Compliance Metrics
- **ISO 27001 A.9.2.5 Compliance**: 100%
- **SOC 2 CC6.1-CC6.3 Compliance**: 98.5%
- **Exception Approval Rate**: 3.2%
- **Audit Evidence Completeness**: 100%

## Recommendations
1. Implement additional automation for service account reviews
2. Enhance manager training on access review procedures  
3. Deploy risk-based access scoring for future reviews
4. Increase frequency of guest user access validation

## Next Review
- **Scheduled Date**: April 15, 2024
- **Scope**: PIM + RBAC + Service Principals
- **Process Improvements**: Implement automated risk scoring
```

## Troubleshooting and Incident Response

### Common Issues and Resolutions

| Issue | Symptoms | Root Cause | Resolution | Prevention |
|-------|----------|------------|------------|------------|
| Review Assignment Failure | Users not receiving notifications | SMTP configuration issue | Verify mail flow settings | Monitor mail queue health |
| PIM Review Creation Error | API timeout errors | Microsoft Graph throttling | Implement retry logic with backoff | Rate limit API calls |
| Data Export Incomplete | Missing users in reports | Insufficient permissions | Grant Directory.Read.All | Verify service principal permissions |
| Manager Approval Timeout | Reviews not completed on time | Manager unavailable | Escalate to alternate approver | Maintain backup approver list |
| Remediation Script Failure | Access not removed | Role assignment conflicts | Manual remediation required | Pre-validate removal dependencies |

### Incident Response Procedures

#### Severity 1: Critical Access Review Failure
```bash
#!/bin/bash
# Critical incident response runbook

echo "=== CRITICAL: Access Review System Failure ==="
echo "Incident Start Time: $(date)"

# 1. Immediate Assessment
echo "Step 1: Assessing system status..."
az ad signed-in-user show --query "userPrincipalName" || echo "ERROR: Azure AD connection failed"
curl -s "https://graph.microsoft.com/v1.0/me" -H "Authorization: Bearer $ACCESS_TOKEN" || echo "ERROR: Graph API unavailable"

# 2. Emergency Communications
echo "Step 2: Notifying stakeholders..."
python3 Scripts/emergency-notification.py \
    --incident-type "access-review-failure" \
    --severity "critical" \
    --stakeholders "security-team@company.com,ciso@company.com"

# 3. Alternative Review Process
echo "Step 3: Activating manual review process..."
# Generate manual review spreadsheets
az ad user list --filter "assignedLicenses/any(x:x/skuId eq b05e124f-c7cc-45a0-a6aa-8cf78c946968)" \
    --query "[].{UPN:userPrincipalName,DisplayName:displayName,Enabled:accountEnabled}" \
    --output table > "Emergency-Review-$(date +%Y%m%d).csv"

# 4. Incident Tracking
INCIDENT_ID="INC-$(date +%Y%m%d)-$(date +%H%M%S)"
echo "Incident ID: $INCIDENT_ID" > "Incidents/$INCIDENT_ID.log"
echo "Critical access review system failure at $(date)" >> "Incidents/$INCIDENT_ID.log"
```

#### Severity 2: Review Completion Delay
```powershell
# Review completion monitoring and escalation
$ReviewStatus = Get-AccessReviewStatus
$CompletionRate = ($ReviewStatus.Completed / $ReviewStatus.Total) * 100

if ($CompletionRate -lt 80 -and (Get-Date) -gt $ReviewDeadline.AddDays(-2)) {
    # Escalate to management
    Send-EscalationEmail -Recipients @("security-manager@company.com") -Subject "Access Review Completion Alert"
    
    # Send reminder notifications
    $PendingReviews = Get-PendingReviews
    foreach ($Review in $PendingReviews) {
        Send-ReminderNotification -Reviewer $Review.AssignedTo -DueDate $ReviewDeadline
    }
    
    # Enable extended hours support
    Enable-ExtendedSupport -ReviewPeriod "Q1-2024"
}
```

### Health Monitoring and Alerting
```yaml
# Azure Monitor alert rules for access review monitoring
access_review_alerts:
  - alert_name: "Access Review Completion Rate Low"
    description: "Review completion rate below 85%"
    query: |
      IdentityGovernanceLogs
      | where Category == "AccessReviewDecision" 
      | where TimeGenerated > ago(7d)
      | summarize 
          Total = count(),
          Completed = countif(Decision != "NotReviewed")
      | extend CompletionRate = (Completed * 100) / Total
      | where CompletionRate < 85
    severity: "Warning"
    frequency: "1h"
    
  - alert_name: "High Risk Access Not Reviewed"
    description: "High-risk access assignments pending review"
    query: |
      IdentityGovernanceLogs
      | where Category == "AccessReviewDecision"
      | where Properties contains "HighRisk"
      | where Decision == "NotReviewed"
      | where TimeGenerated > ago(24h)
    severity: "High"
    frequency: "15m"
    
  - alert_name: "Review System API Failures"
    description: "Microsoft Graph API failures affecting reviews"
    query: |
      AppServiceHTTPLogs
      | where TimeGenerated > ago(1h)
      | where RequestUri contains "graph.microsoft.com"
      | where ScStatus >= 400
      | summarize FailureCount = count() by bin(TimeGenerated, 5m)
      | where FailureCount > 10
    severity: "Critical"
    frequency: "5m"
```

## Process Improvement and Optimization

### Continuous Improvement Framework
1. **Quarterly Process Review**
   - Review KPI performance against targets
   - Analyze stakeholder feedback
   - Identify automation opportunities
   - Update procedures based on lessons learned

2. **Annual Maturity Assessment**
   ```python
   def assess_access_review_maturity():
       """Assess access review process maturity"""
       
       maturity_criteria = {
           'automation_level': {
               'manual_only': 1,
               'semi_automated': 2,
               'mostly_automated': 3,
               'fully_automated': 4
           },
           'coverage_scope': {
               'ad_hoc': 1,
               'privileged_only': 2,
               'comprehensive': 3,
               'continuous': 4
           },
           'risk_integration': {
               'none': 1,
               'basic_risk_flags': 2,
               'risk_based_prioritization': 3,
               'predictive_analytics': 4
           },
           'compliance_alignment': {
               'non_compliant': 1,
               'partially_compliant': 2,
               'compliant': 3,
               'exceeds_requirements': 4
           }
       }
       
       current_scores = {
           'automation_level': 3,  # Mostly automated
           'coverage_scope': 3,    # Comprehensive 
           'risk_integration': 2,  # Basic risk flags
           'compliance_alignment': 3  # Compliant
       }
       
       overall_maturity = sum(current_scores.values()) / len(current_scores)
       
       return {
           'overall_score': overall_maturity,
           'maturity_level': get_maturity_level(overall_maturity),
           'recommendations': generate_improvement_recommendations(current_scores)
       }
   ```

### Future Enhancements Roadmap
1. **Q2 2024**: Implement machine learning-based risk scoring
2. **Q3 2024**: Deploy continuous access monitoring
3. **Q4 2024**: Integrate with zero-trust architecture
4. **Q1 2025**: Implement predictive access analytics

## Appendices

### Appendix A: Command Reference
```bash
# Quick reference commands for access review operations

# Extract privileged users
az ad user list --filter "assignedLicenses/any(x:x/skuId eq b05e124f-c7cc-45a0-a6aa-8cf78c946968)" --output table

# Get PIM assignments  
Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId (Get-AzureADTenantDetail).ObjectId

# Check review status
az rest --method GET --uri "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions"

# Export audit logs
az monitor activity-log list --start-time 2024-01-15 --end-time 2024-01-30 --query "[?authorization.action=='Microsoft.Authorization/roleAssignments/write']"
```

### Appendix B: Contact Information
- **Security Team**: security-team@company.com
- **Identity Team**: identity-team@company.com  
- **Emergency Escalation**: +1-555-SECURITY
- **ITSM Portal**: https://company.service-now.com

### Appendix C: Document History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2023-12-01 | Security Team | Initial version |
| 2.0 | 2024-01-15 | Security Team | Added automation workflows |
| 2.1 | 2024-01-20 | Security Team | Enhanced PIM integration |

---
**Document Classification**: Internal Use  
**Review Date**: 2024-04-15  
**Approved By**: CISO, IT Operations Manager
