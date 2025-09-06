#Requires -Version 7.0
#Requires -Modules Az.Accounts, Az.Resources, Az.OperationalInsights, Az.SecurityInsights

<#
.SYNOPSIS
    Deploy Microsoft Sentinel workspace and data connectors to Azure.

.DESCRIPTION
    This script automates the deployment of Microsoft Sentinel including:
    - Log Analytics workspace creation
    - Microsoft Sentinel onboarding
    - Data connector configuration
    - Basic health monitoring setup
    - Optional storage account for long-term retention

.PARAMETER ResourceGroupName
    Name of the resource group to create or use for Sentinel resources.

.PARAMETER WorkspaceName
    Name of the Log Analytics workspace for Microsoft Sentinel.

.PARAMETER Location
    Azure region for the deployment. Defaults to 'East US 2'.

.PARAMETER SubscriptionId
    Azure subscription ID. If not provided, uses current context.

.PARAMETER RetentionInDays
    Number of days to retain data in the workspace (30-730). Defaults to 90.

.PARAMETER DailyQuotaGb
    Daily ingestion limit in GB. Set to -1 for unlimited. Defaults to -1.

.PARAMETER EnableAzureActivity
    Enable Azure Activity Log data connector. Defaults to $true.

.PARAMETER EnableAzureAD
    Enable Azure Active Directory data connector. Defaults to $true.

.PARAMETER EnableSecurityCenter
    Enable Microsoft Defender for Cloud data connector. Defaults to $true.

.PARAMETER EnableOffice365
    Enable Office 365 data connector. Defaults to $true.

.PARAMETER EnableIdentityProtection
    Enable Azure AD Identity Protection data connector. Requires P2 license. Defaults to $false.

.PARAMETER EnableLongTermStorage
    Create storage account for long-term log retention. Defaults to $false.

.PARAMETER Tags
    Hashtable of tags to apply to resources.

.PARAMETER WhatIf
    Show what would be created without actually creating resources.

.EXAMPLE
    .\Deploy-Sentinel.ps1 -ResourceGroupName "rg-sentinel-prod" -WorkspaceName "law-sentinel-001" -Location "East US 2"

.EXAMPLE
    .\Deploy-Sentinel.ps1 -ResourceGroupName "rg-sentinel-dev" -WorkspaceName "law-sentinel-dev" -EnableLongTermStorage -RetentionInDays 180 -WhatIf

.NOTES
    Author: Security Team
    Version: 2.0
    Requires: PowerShell 7.0+, Az PowerShell modules
    
    Prerequisites:
    - Azure PowerShell modules installed
    - Authenticated to Azure (Connect-AzAccount)
    - Appropriate RBAC permissions (Contributor + Security Admin)
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateLength(1, 90)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$')]
    [string]$WorkspaceName,

    [Parameter()]
    [ValidateSet('East US', 'East US 2', 'West US', 'West US 2', 'West US 3', 'Central US', 
                 'North Central US', 'South Central US', 'West Central US', 'Canada Central', 
                 'Canada East', 'North Europe', 'West Europe', 'UK South', 'UK West', 
                 'France Central', 'Germany West Central', 'Norway East', 'Switzerland North', 
                 'Japan East', 'Japan West', 'Korea Central', 'Australia East', 
                 'Australia Southeast', 'Southeast Asia', 'East Asia', 'Central India', 
                 'South India', 'Brazil South', 'South Africa North')]
    [string]$Location = 'East US 2',

    [Parameter()]
    [ValidateScript({
        if ($_ -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
            $true
        } else {
            throw "SubscriptionId must be a valid GUID"
        }
    })]
    [string]$SubscriptionId,

    [Parameter()]
    [ValidateRange(30, 730)]
    [int]$RetentionInDays = 90,

    [Parameter()]
    [ValidateScript({
        $_ -eq -1 -or $_ -ge 1
    })]
    [int]$DailyQuotaGb = -1,

    [Parameter()]
    [bool]$EnableAzureActivity = $true,

    [Parameter()]
    [bool]$EnableAzureAD = $true,

    [Parameter()]
    [bool]$EnableSecurityCenter = $true,

    [Parameter()]
    [bool]$EnableOffice365 = $true,

    [Parameter()]
    [bool]$EnableIdentityProtection = $false,

    [Parameter()]
    [bool]$EnableLongTermStorage = $false,

    [Parameter()]
    [hashtable]$Tags = @{
        Environment = 'Production'
        Purpose     = 'SecurityMonitoring'
        Owner       = 'SecurityTeam'
        Project     = 'Sentinel'
    }
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Import required modules
$RequiredModules = @(
    'Az.Accounts',
    'Az.Resources', 
    'Az.OperationalInsights',
    'Az.SecurityInsights',
    'Az.Storage'
)

Write-Host "Checking required PowerShell modules..." -ForegroundColor Cyan
foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Warning "Module $Module is not installed. Installing..."
        Install-Module -Name $Module -Force -AllowClobber -Scope CurrentUser
    }
    Import-Module -Name $Module -Force
}

# Function to write colored output
function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )
    
    $Colors = @{
        Info    = 'White'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
    }
    
    $Prefix = @{
        Info    = '[INFO]'
        Success = '[SUCCESS]'
        Warning = '[WARNING]'
        Error   = '[ERROR]'
    }
    
    Write-Host "$($Prefix[$Type]) $Message" -ForegroundColor $Colors[$Type]
}

# Function to test Azure connectivity and permissions
function Test-AzureConnection {
    try {
        Write-Status "Testing Azure connection..." -Type Info
        $Context = Get-AzContext
        
        if (-not $Context) {
            Write-Status "Not connected to Azure. Please run Connect-AzAccount first." -Type Error
            return $false
        }
        
        if ($SubscriptionId -and $Context.Subscription.Id -ne $SubscriptionId) {
            Write-Status "Switching to subscription: $SubscriptionId" -Type Info
            Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        }
        
        Write-Status "Connected to Azure subscription: $((Get-AzContext).Subscription.Name)" -Type Success
        return $true
    }
    catch {
        Write-Status "Failed to connect to Azure: $($_.Exception.Message)" -Type Error
        return $false
    }
}

# Function to create or update resource group
function New-SentinelResourceGroup {
    param(
        [string]$Name,
        [string]$Location,
        [hashtable]$Tags
    )
    
    try {
        Write-Status "Checking resource group: $Name" -Type Info
        $ResourceGroup = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
        
        if (-not $ResourceGroup) {
            if ($PSCmdlet.ShouldProcess($Name, "Create Resource Group")) {
                Write-Status "Creating resource group: $Name in $Location" -Type Info
                $ResourceGroup = New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags
                Write-Status "Resource group created successfully" -Type Success
            }
        } else {
            Write-Status "Resource group already exists" -Type Info
            if ($ResourceGroup.Location -ne $Location) {
                Write-Status "Warning: Existing resource group location ($($ResourceGroup.Location)) differs from specified location ($Location)" -Type Warning
            }
        }
        
        return $ResourceGroup
    }
    catch {
        Write-Status "Failed to create resource group: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Function to create Log Analytics workspace
function New-SentinelWorkspace {
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName,
        [string]$Location,
        [int]$RetentionInDays,
        [int]$DailyQuotaGb,
        [hashtable]$Tags
    )
    
    try {
        Write-Status "Checking Log Analytics workspace: $WorkspaceName" -Type Info
        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
        
        if (-not $Workspace) {
            if ($PSCmdlet.ShouldProcess($WorkspaceName, "Create Log Analytics Workspace")) {
                Write-Status "Creating Log Analytics workspace: $WorkspaceName" -Type Info
                
                $WorkspaceParams = @{
                    ResourceGroupName = $ResourceGroupName
                    Name              = $WorkspaceName
                    Location          = $Location
                    Sku               = 'PerGB2018'
                    RetentionInDays   = $RetentionInDays
                    Tag               = $Tags
                }
                
                if ($DailyQuotaGb -ne -1) {
                    $WorkspaceParams['DailyQuotaGb'] = $DailyQuotaGb
                }
                
                $Workspace = New-AzOperationalInsightsWorkspace @WorkspaceParams
                Write-Status "Log Analytics workspace created successfully" -Type Success
            }
        } else {
            Write-Status "Log Analytics workspace already exists" -Type Info
        }
        
        return $Workspace
    }
    catch {
        Write-Status "Failed to create Log Analytics workspace: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Function to enable Microsoft Sentinel
function Enable-MicrosoftSentinel {
    param(
        [string]$WorkspaceResourceId
    )
    
    try {
        Write-Status "Checking Microsoft Sentinel status..." -Type Info
        
        # Check if Sentinel is already enabled
        $SentinelEnabled = Get-AzSentinelOnboardingState -ResourceId $WorkspaceResourceId -ErrorAction SilentlyContinue
        
        if (-not $SentinelEnabled) {
            if ($PSCmdlet.ShouldProcess($WorkspaceResourceId, "Enable Microsoft Sentinel")) {
                Write-Status "Enabling Microsoft Sentinel on workspace..." -Type Info
                $null = New-AzSentinelOnboardingState -ResourceId $WorkspaceResourceId -Name 'default'
                Write-Status "Microsoft Sentinel enabled successfully" -Type Success
            }
        } else {
            Write-Status "Microsoft Sentinel is already enabled" -Type Info
        }
        
        return $true
    }
    catch {
        Write-Status "Failed to enable Microsoft Sentinel: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Function to configure data connectors
function Set-SentinelDataConnectors {
    param(
        [string]$WorkspaceResourceId,
        [bool]$EnableAzureActivity,
        [bool]$EnableAzureAD,
        [bool]$EnableSecurityCenter,
        [bool]$EnableOffice365,
        [bool]$EnableIdentityProtection
    )
    
    try {
        Write-Status "Configuring data connectors..." -Type Info
        $TenantId = (Get-AzContext).Tenant.Id
        $SubscriptionId = (Get-AzContext).Subscription.Id
        
        # Azure Activity Log Connector
        if ($EnableAzureActivity) {
            if ($PSCmdlet.ShouldProcess("Azure Activity", "Enable Data Connector")) {
                Write-Status "Enabling Azure Activity Log connector..." -Type Info
                try {
                    $ActivityConnector = @{
                        ResourceId = $WorkspaceResourceId
                        Kind = 'AzureActivityLog'
                        SubscriptionId = $SubscriptionId
                        TenantId = $TenantId
                    }
                    New-AzSentinelDataConnector @ActivityConnector | Out-Null
                    Write-Status "Azure Activity Log connector enabled" -Type Success
                }
                catch {
                    if ($_.Exception.Message -notmatch "already exists") {
                        throw
                    }
                    Write-Status "Azure Activity Log connector already exists" -Type Info
                }
            }
        }
        
        # Azure AD Connector
        if ($EnableAzureAD) {
            if ($PSCmdlet.ShouldProcess("Azure AD", "Enable Data Connector")) {
                Write-Status "Enabling Azure Active Directory connector..." -Type Info
                try {
                    $AADConnector = @{
                        ResourceId = $WorkspaceResourceId
                        Kind = 'AzureActiveDirectory'
                        TenantId = $TenantId
                    }
                    New-AzSentinelDataConnector @AADConnector | Out-Null
                    Write-Status "Azure Active Directory connector enabled" -Type Success
                }
                catch {
                    if ($_.Exception.Message -notmatch "already exists") {
                        throw
                    }
                    Write-Status "Azure Active Directory connector already exists" -Type Info
                }
            }
        }
        
        # Security Center Connector
        if ($EnableSecurityCenter) {
            if ($PSCmdlet.ShouldProcess("Security Center", "Enable Data Connector")) {
                Write-Status "Enabling Microsoft Defender for Cloud connector..." -Type Info
                try {
                    $SecurityCenterConnector = @{
                        ResourceId = $WorkspaceResourceId
                        Kind = 'AzureSecurityCenter'
                        SubscriptionId = $SubscriptionId
                    }
                    New-AzSentinelDataConnector @SecurityCenterConnector | Out-Null
                    Write-Status "Microsoft Defender for Cloud connector enabled" -Type Success
                }
                catch {
                    if ($_.Exception.Message -notmatch "already exists") {
                        throw
                    }
                    Write-Status "Microsoft Defender for Cloud connector already exists" -Type Info
                }
            }
        }
        
        # Office 365 Connector
        if ($EnableOffice365) {
            if ($PSCmdlet.ShouldProcess("Office 365", "Enable Data Connector")) {
                Write-Status "Enabling Office 365 connector..." -Type Info
                try {
                    $Office365Connector = @{
                        ResourceId = $WorkspaceResourceId
                        Kind = 'Office365'
                        TenantId = $TenantId
                    }
                    New-AzSentinelDataConnector @Office365Connector | Out-Null
                    Write-Status "Office 365 connector enabled" -Type Success
                }
                catch {
                    if ($_.Exception.Message -notmatch "already exists") {
                        throw
                    }
                    Write-Status "Office 365 connector already exists" -Type Info
                }
            }
        }
        
        # Identity Protection Connector
        if ($EnableIdentityProtection) {
            if ($PSCmdlet.ShouldProcess("Identity Protection", "Enable Data Connector")) {
                Write-Status "Enabling Azure AD Identity Protection connector..." -Type Info
                try {
                    $IdentityProtectionConnector = @{
                        ResourceId = $WorkspaceResourceId
                        Kind = 'AzureActiveDirectoryIdentityProtection'
                        TenantId = $TenantId
                    }
                    New-AzSentinelDataConnector @IdentityProtectionConnector | Out-Null
                    Write-Status "Azure AD Identity Protection connector enabled" -Type Success
                }
                catch {
                    if ($_.Exception.Message -notmatch "already exists") {
                        throw
                    }
                    Write-Status "Azure AD Identity Protection connector already exists" -Type Info
                }
            }
        }
        
        return $true
    }
    catch {
        Write-Status "Failed to configure data connectors: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Function to create storage account for long-term retention
function New-SentinelStorageAccount {
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName,
        [string]$Location,
        [hashtable]$Tags
    )
    
    try {
        $StorageAccountName = ("st" + $WorkspaceName.Replace("-", "").ToLower() + "logs").Substring(0, [Math]::Min(24, ("st" + $WorkspaceName.Replace("-", "").ToLower() + "logs").Length))
        
        Write-Status "Creating storage account for long-term retention: $StorageAccountName" -Type Info
        
        $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
        
        if (-not $StorageAccount) {
            if ($PSCmdlet.ShouldProcess($StorageAccountName, "Create Storage Account")) {
                $StorageAccountParams = @{
                    ResourceGroupName = $ResourceGroupName
                    Name              = $StorageAccountName
                    Location          = $Location
                    SkuName           = 'Standard_LRS'
                    Kind              = 'StorageV2'
                    AccessTier        = 'Hot'
                    Tag               = $Tags
                }
                
                $StorageAccount = New-AzStorageAccount @StorageAccountParams
                Write-Status "Storage account created successfully" -Type Success
            }
        } else {
            Write-Status "Storage account already exists" -Type Info
        }
        
        return $StorageAccount
    }
    catch {
        Write-Status "Failed to create storage account: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Function to create health monitoring saved searches
function New-SentinelHealthChecks {
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    try {
        Write-Status "Creating health monitoring saved searches..." -Type Info
        
        if ($PSCmdlet.ShouldProcess("Health Checks", "Create Saved Searches")) {
            # Health Check Query
            $HealthCheckQuery = @{
                ResourceGroupName = $ResourceGroupName
                WorkspaceName     = $WorkspaceName
                SavedSearchId     = 'SentinelHealthCheck'
                DisplayName       = 'Sentinel Health Check'
                Category          = 'Sentinel Health'
                Query             = @"
union withsource=TableName *
| where TimeGenerated > ago(24h)
| summarize Count = count() by TableName
| where Count > 0
| order by Count desc
"@
                Tag               = @{ Group = 'Sentinel' }
            }
            
            New-AzOperationalInsightsSavedSearch @HealthCheckQuery | Out-Null
            
            # Connector Health Query
            $ConnectorHealthQuery = @{
                ResourceGroupName = $ResourceGroupName
                WorkspaceName     = $WorkspaceName
                SavedSearchId     = 'DataConnectorHealth'
                DisplayName       = 'Data Connector Health Check'
                Category          = 'Sentinel Health'
                Query             = @"
union 
(AzureActivity | where TimeGenerated > ago(1h) | extend Connector = 'AzureActivity'),
(SigninLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'),
(AuditLogs | where TimeGenerated > ago(1h) | extend Connector = 'AzureActiveDirectory'),
(SecurityAlert | where TimeGenerated > ago(1h) | extend Connector = 'SecurityCenter'),
(OfficeActivity | where TimeGenerated > ago(1h) | extend Connector = 'Office365'),
(CommonSecurityLog | where TimeGenerated > ago(1h) | extend Connector = 'CommonEventFormat'),
(Syslog | where TimeGenerated > ago(1h) | extend Connector = 'Syslog')
| summarize LastReceived = max(TimeGenerated), Count = count() by Connector
| extend Status = case(Count > 0, 'Healthy', 'No Data')
"@
                Tag               = @{ Group = 'Sentinel' }
            }
            
            New-AzOperationalInsightsSavedSearch @ConnectorHealthQuery | Out-Null
            Write-Status "Health monitoring saved searches created successfully" -Type Success
        }
    }
    catch {
        Write-Status "Failed to create health monitoring queries: $($_.Exception.Message)" -Type Error
        # Don't throw here as this is not critical
    }
}

# Main execution
try {
    Write-Host "`n=== Microsoft Sentinel Deployment Script ===" -ForegroundColor Cyan
    Write-Host "Version: 2.0" -ForegroundColor Cyan
    Write-Host "Author: Security Team`n" -ForegroundColor Cyan
    
    # Test Azure connection
    if (-not (Test-AzureConnection)) {
        exit 1
    }
    
    # Create or verify resource group
    $ResourceGroup = New-SentinelResourceGroup -Name $ResourceGroupName -Location $Location -Tags $Tags
    
    # Create Log Analytics workspace
    $Workspace = New-SentinelWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Location $Location -RetentionInDays $RetentionInDays -DailyQuotaGb $DailyQuotaGb -Tags $Tags
    
    # Enable Microsoft Sentinel
    Enable-MicrosoftSentinel -WorkspaceResourceId $Workspace.ResourceId
    
    # Configure data connectors
    Set-SentinelDataConnectors -WorkspaceResourceId $Workspace.ResourceId -EnableAzureActivity $EnableAzureActivity -EnableAzureAD $EnableAzureAD -EnableSecurityCenter $EnableSecurityCenter -EnableOffice365 $EnableOffice365 -EnableIdentityProtection $EnableIdentityProtection
    
    # Create storage account if requested
    if ($EnableLongTermStorage) {
        $StorageAccount = New-SentinelStorageAccount -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Location $Location -Tags $Tags
    }
    
    # Create health monitoring queries
    New-SentinelHealthChecks -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
    
    # Wait for workspace to be fully provisioned
    Write-Status "Waiting for workspace provisioning to complete..." -Type Info
    Start-Sleep -Seconds 30
    
    # Output deployment summary
    Write-Host "`n=== Deployment Summary ===" -ForegroundColor Green
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "Workspace Name: $WorkspaceName" -ForegroundColor White
    Write-Host "Location: $Location" -ForegroundColor White
    Write-Host "Workspace ID: $($Workspace.CustomerId)" -ForegroundColor White
    Write-Host "Portal URL: https://portal.azure.com/#@$((Get-AzContext).Tenant.Id)/resource$($Workspace.ResourceId)/Overview" -ForegroundColor White
    
    $EnabledConnectors = @()
    if ($EnableAzureActivity) { $EnabledConnectors += "Azure Activity" }
    if ($EnableAzureAD) { $EnabledConnectors += "Azure AD" }
    if ($EnableSecurityCenter) { $EnabledConnectors += "Security Center" }
    if ($EnableOffice365) { $EnabledConnectors += "Office 365" }
    if ($EnableIdentityProtection) { $EnabledConnectors += "Identity Protection" }
    
    Write-Host "Enabled Connectors: $($EnabledConnectors -join ', ')" -ForegroundColor White
    
    if ($EnableLongTermStorage) {
        Write-Host "Storage Account: $($StorageAccount.StorageAccountName)" -ForegroundColor White
    }
    
    Write-Status "`nMicrosoft Sentinel deployment completed successfully!" -Type Success
    Write-Status "It may take up to 30 minutes for data connectors to start ingesting data." -Type Info
    
}
catch {
    Write-Status "Deployment failed: $($_.Exception.Message)" -Type Error
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}