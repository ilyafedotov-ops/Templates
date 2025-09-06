@description('Environment name (dev, staging, production)')
@allowed(['dev', 'staging', 'production'])
param environment string = 'dev'

@description('Project name for resource naming')
param projectName string = 'myproject'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Owner tag for resources')
param owner string = 'DevOps Team'

@description('Cost center for billing')
param costCenter string = 'Engineering'

@description('Git commit hash for deployment tracking')
param gitCommit string = 'unknown'

@description('Virtual network address space')
param vnetAddressSpace string = '10.0.0.0/16'

@description('Subnet configurations')
param subnetConfigurations array = [
  {
    name: 'default'
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: [
      'Microsoft.Storage'
      'Microsoft.KeyVault'
    ]
  }
  {
    name: 'aks'
    addressPrefix: '10.0.2.0/23'
    serviceEndpoints: [
      'Microsoft.Storage'
      'Microsoft.KeyVault'
    ]
  }
  {
    name: 'private-endpoints'
    addressPrefix: '10.0.4.0/24'
    serviceEndpoints: []
  }
]

@description('Enable DDoS protection for VNet')
param enableDdosProtection bool = false

@description('Enable Network Security Group flow logs')
param enableNetworkFlowLogs bool = true

@description('Storage account configurations')
param storageAccounts array = [
  {
    name: 'primary'
    sku: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    enableVersioning: false
    enableSoftDelete: true
    softDeleteRetentionDays: 7
    containers: [
      {
        name: 'data'
        publicAccess: 'None'
      }
    ]
  }
]

@description('Enable private endpoints for storage accounts')
param enableStoragePrivateEndpoints bool = false

@description('Enable Advanced Threat Protection for storage')
param enableStorageThreatProtection bool = false

@description('Allowed IP ranges for network access')
param allowedIpRanges array = []

@description('Key Vault administrators object IDs')
param keyVaultAdminObjectIds array = []

@description('Enable RBAC authorization for Key Vault')
param keyVaultEnableRbac bool = true

@description('Log Analytics workspace configuration')
param logAnalytics object = {
  sku: 'PerGB2018'
  retentionInDays: 30
}

@description('Enable Application Insights')
param enableApplicationInsights bool = true

@description('Application Insights application type')
@allowed(['web', 'other'])
param applicationInsightsType string = 'web'

@description('Enable Azure Security Center')
param enableSecurityCenter bool = true

@description('Azure Security Center pricing tier')
@allowed(['Free', 'Standard'])
param securityCenterTier string = 'Free'

@description('Enable Azure Kubernetes Service')
param enableAks bool = false

@description('AKS configuration')
param aksConfiguration object = {
  kubernetesVersion: '1.28.3'
  nodePool: {
    name: 'default'
    count: 1
    vmSize: 'Standard_B2s'
    osDiskSizeGB: 64
    osDiskType: 'Standard_LRS'
    maxPods: 30
    enableAutoScaling: false
    minCount: 1
    maxCount: 2
  }
  networkProfile: {
    dnsServiceIP: '10.0.0.10'
    serviceCidr: '10.0.0.0/16'
    podCidr: '10.244.0.0/16'
  }
  enableRbac: true
  enableAzurePolicy: true
  enableOmsAgent: true
}

@description('Budget configurations')
param budgets array = []

// Variables
var resourcePrefix = '${projectName}-${environment}'
var locationShort = {
  'East US': 'eus'
  'East US 2': 'eus2'
  'West US': 'wus'
  'West US 2': 'wus2'
  'Central US': 'cus'
  'North Central US': 'ncus'
  'South Central US': 'scus'
  'West Central US': 'wcus'
}

var commonTags = {
  Environment: environment
  ManagedBy: 'Bicep'
  Owner: owner
  Project: projectName
  CostCenter: costCenter
  CreatedDate: utcNow('yyyy-MM-dd')
  GitCommit: gitCommit
}

// Existing resource group (deployment target)
var rgName = resourceGroup().name
var rgLocation = resourceGroup().location

//
// Virtual Network and Networking
//

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${resourcePrefix}-${locationShort[location]}'
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressSpace]
    }
    enableDdosProtection: enableDdosProtection
    subnets: [for subnet in subnetConfigurations: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: [for endpoint in subnet.serviceEndpoints: {
          service: endpoint
        }]
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    }]
  }
}

resource nsgDefault 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-${resourcePrefix}-default'
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPS'
        properties: {
          description: 'Allow HTTPS traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          description: 'Allow HTTP traffic'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
          sourceAddressPrefix: environment == 'production' ? 'VirtualNetwork' : '*'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Network Flow Logs (if enabled)
resource networkWatcher 'Microsoft.Network/networkWatchers@2023-05-01' existing = if (enableNetworkFlowLogs) {
  name: 'NetworkWatcher_${location}'
  scope: resourceGroup('NetworkWatcherRG')
}

//
// Storage Accounts
//

resource storageAccountsResource 'Microsoft.Storage/storageAccounts@2023-01-01' = [for (sa, index) in storageAccounts: {
  name: 'st${replace(resourcePrefix, '-', '')}${sa.name}${uniqueString(resourceGroup().id, string(index))}'
  location: location
  tags: commonTags
  sku: {
    name: sa.sku
  }
  kind: sa.kind
  properties: {
    accessTier: sa.accessTier
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      defaultAction: enableStoragePrivateEndpoints ? 'Deny' : 'Allow'
      ipRules: [for ip in allowedIpRanges: {
        value: ip
        action: 'Allow'
      }]
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/default'
          action: 'Allow'
        }
      ]
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
  }
}]

// Blob Services with versioning and soft delete
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = [for (sa, index) in storageAccounts: {
  parent: storageAccountsResource[index]
  name: 'default'
  properties: {
    isVersioningEnabled: sa.enableVersioning
    deleteRetentionPolicy: {
      enabled: sa.enableSoftDelete
      days: sa.softDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: sa.enableSoftDelete
      days: sa.softDeleteRetentionDays
    }
  }
}]

// Storage containers
resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for (sa, saIndex) in storageAccounts: [for (container, containerIndex) in sa.containers: {
  parent: blobServices[saIndex]
  name: container.name
  properties: {
    publicAccess: container.publicAccess
    metadata: {}
  }
}]]

// Advanced Threat Protection for Storage
resource storageAdvancedThreatProtection 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = [for (sa, index) in storageAccounts: if (enableStorageThreatProtection) {
  name: 'current'
  scope: storageAccountsResource[index]
  properties: {
    isEnabled: true
  }
}]

//
// Key Vault
//

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${resourcePrefix}-${uniqueString(resourceGroup().id)}'
  location: location
  tags: commonTags
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: keyVaultEnableRbac
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      defaultAction: enableStoragePrivateEndpoints ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
      ipRules: [for ip in allowedIpRanges: {
        value: ip
      }]
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/default'
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    accessPolicies: keyVaultEnableRbac ? [] : [for objectId in keyVaultAdminObjectIds: {
      tenantId: subscription().tenantId
      objectId: objectId
      permissions: {
        keys: ['all']
        secrets: ['all']
        certificates: ['all']
      }
    }]
  }
}

//
// Monitoring and Logging
//

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${resourcePrefix}'
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: logAnalytics.sku
    }
    retentionInDays: logAnalytics.retentionInDays
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights) {
  name: 'ai-${resourcePrefix}'
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: applicationInsightsType
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Diagnostic Settings for Key Vault
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${keyVault.name}'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Diagnostic Settings for Storage Accounts
resource storageAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (sa, index) in storageAccounts: {
  name: 'diag-${storageAccountsResource[index].name}'
  scope: storageAccountsResource[index]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}]

//
// Azure Kubernetes Service (Optional)
//

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = if (enableAks) {
  name: 'aks-${resourcePrefix}'
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: aksConfiguration.kubernetesVersion
    dnsPrefix: 'aks-${resourcePrefix}'
    enableRBAC: aksConfiguration.enableRbac
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: aksConfiguration.networkProfile.serviceCidr
      dnsServiceIP: aksConfiguration.networkProfile.dnsServiceIP
      podCidr: aksConfiguration.networkProfile.podCidr
    }
    agentPoolProfiles: [
      {
        name: aksConfiguration.nodePool.name
        count: aksConfiguration.nodePool.count
        vmSize: aksConfiguration.nodePool.vmSize
        osDiskSizeGB: aksConfiguration.nodePool.osDiskSizeGB
        osDiskType: aksConfiguration.nodePool.osDiskType
        maxPods: aksConfiguration.nodePool.maxPods
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: aksConfiguration.nodePool.enableAutoScaling
        minCount: aksConfiguration.nodePool.enableAutoScaling ? aksConfiguration.nodePool.minCount : null
        maxCount: aksConfiguration.nodePool.enableAutoScaling ? aksConfiguration.nodePool.maxCount : null
        vnetSubnetID: '${vnet.id}/subnets/aks'
        upgradeSettings: {
          maxSurge: '1'
        }
      }
    ]
    addonProfiles: {
      azurepolicy: {
        enabled: aksConfiguration.enableAzurePolicy
      }
      omsAgent: {
        enabled: aksConfiguration.enableOmsAgent
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
    }
    autoScalerProfile: aksConfiguration.nodePool.enableAutoScaling ? {
      'scale-down-delay-after-add': '10m'
      'scale-down-unneeded-time': '10m'
      'scale-down-utilization-threshold': '0.5'
    } : null
  }
}

//
// Security Center Configuration
//

resource securityCenterPricing 'Microsoft.Security/pricings@2022-03-01' = if (enableSecurityCenter && securityCenterTier == 'Standard') {
  name: 'VirtualMachines'
  properties: {
    pricingTier: securityCenterTier
  }
}

//
// Cost Management - Budgets
//

resource budgetResource 'Microsoft.Consumption/budgets@2023-05-01' = [for (budget, index) in budgets: {
  name: 'budget-${resourcePrefix}-${budget.name}'
  properties: {
    timePeriod: {
      startDate: budget.timePeriod.startDate
      endDate: budget.timePeriod.endDate
    }
    timeGrain: budget.timeGrain
    amount: budget.amount
    category: 'Cost'
    notifications: budget.notifications
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          rgName
        ]
      }
    }
  }
}]

//
// Private Endpoints (if enabled)
//

resource storagePrivateEndpoints 'Microsoft.Network/privateEndpoints@2023-05-01' = [for (sa, index) in storageAccounts: if (enableStoragePrivateEndpoints) {
  name: 'pe-${storageAccountsResource[index].name}-blob'
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/private-endpoints'
    }
    privateLinkServiceConnections: [
      {
        name: 'blob-connection'
        properties: {
          privateLinkServiceId: storageAccountsResource[index].id
          groupIds: ['blob']
        }
      }
    ]
  }
}]

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (enableStoragePrivateEndpoints) {
  name: 'pe-${keyVault.name}'
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/private-endpoints'
    }
    privateLinkServiceConnections: [
      {
        name: 'kv-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}

//
// Outputs
//

@description('Resource Group information')
output resourceGroup object = {
  name: rgName
  location: rgLocation
  id: resourceGroup().id
}

@description('Virtual Network information')
output virtualNetwork object = {
  name: vnet.name
  id: vnet.id
  addressSpace: vnet.properties.addressSpace.addressPrefixes
  subnets: [for (subnet, index) in vnet.properties.subnets: {
    name: subnet.name
    id: '${vnet.id}/subnets/${subnet.name}'
    addressPrefix: subnet.properties.addressPrefix
  }]
}

@description('Storage Account information')
output storageAccounts array = [for (sa, index) in storageAccounts: {
  name: storageAccountsResource[index].name
  id: storageAccountsResource[index].id
  primaryEndpoints: storageAccountsResource[index].properties.primaryEndpoints
}]

@description('Key Vault information')
output keyVault object = {
  name: keyVault.name
  id: keyVault.id
  uri: keyVault.properties.vaultUri
}

@description('Log Analytics Workspace information')
output logAnalyticsWorkspace object = {
  name: logAnalyticsWorkspace.name
  id: logAnalyticsWorkspace.id
  customerId: logAnalyticsWorkspace.properties.customerId
}

@description('Application Insights information')
output applicationInsights object = enableApplicationInsights ? {
  name: applicationInsights.name
  id: applicationInsights.id
  appId: applicationInsights.properties.AppId
  instrumentationKey: applicationInsights.properties.InstrumentationKey
  connectionString: applicationInsights.properties.ConnectionString
} : {}

@description('AKS Cluster information')
output aksCluster object = enableAks ? {
  name: aksCluster.name
  id: aksCluster.id
  fqdn: aksCluster.properties.fqdn
  kubernetesVersion: aksCluster.properties.kubernetesVersion
  nodeResourceGroup: aksCluster.properties.nodeResourceGroup
} : {}

@description('Deployment information')
output deploymentInfo object = {
  environment: environment
  projectName: projectName
  gitCommit: gitCommit
  deploymentDate: utcNow()
  location: location
  resourcePrefix: resourcePrefix
}

@description('Security configuration summary')
output securitySummary object = {
  enableDdosProtection: enableDdosProtection
  enableNetworkFlowLogs: enableNetworkFlowLogs
  enableStoragePrivateEndpoints: enableStoragePrivateEndpoints
  enableStorageThreatProtection: enableStorageThreatProtection
  keyVaultEnableRbac: keyVaultEnableRbac
  enableSecurityCenter: enableSecurityCenter
  securityCenterTier: securityCenterTier
}

@description('Resource counts for cost tracking')
output resourceCounts object = {
  storageAccounts: length(storageAccounts)
  subnets: length(subnetConfigurations)
  budgets: length(budgets)
  aksEnabled: enableAks
  applicationInsightsEnabled: enableApplicationInsights
}