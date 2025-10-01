targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles (optional)')
param principalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

// Optional parameters with defaults
@description('Resource group name. If not provided, will be generated based on environment name.')
param resourceGroupName string = ''

// Variables
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  'deployment-source': githubActions ? 'github-actions' : 'local'
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// User Assigned Managed Identity (uncomment and modify as needed)
module managedIdentity './core/security/user-assigned-identity.bicep' = {
  name: 'managedIdentity'
  scope: rg
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

// Container Apps Environment (uncomment and modify as needed)
// module containerAppsEnvironment './core/host/container-apps-environment.bicep' = {
//   name: 'containerAppsEnvironment'
//   scope: rg
//   params: {
//     name: '${abbrs.appManagedEnvironments}${resourceToken}'
//     location: location
//     tags: tags
//     logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     githubActions: githubActions
//   }
// }

// Container Registry (uncomment and modify as needed)
// module containerRegistry './core/storage/container-registry.bicep' = {
//   name: 'containerRegistry'
//   scope: rg
//   params: {
//     name: '${abbrs.containerRegistryRegistries}${resourceToken}'
//     location: location
//     tags: tags
//     adminUserEnabled: true
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     managedIdentityClientId: managedIdentity.outputs.clientId
//     managedIdentityResourceId: managedIdentity.outputs.id
//     githubActions: githubActions
//   }
// }

// Container App (uncomment and modify as needed)
// module containerApp './core/host/container-app.bicep' = {
//   name: 'containerApp'
//   scope: rg
//   params: {
//     name: '${abbrs.appContainerApps}web-${resourceToken}'
//     location: location
//     tags: tags
//     exists: false // Set to true for incremental updates, false for initial deployment
//     containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
//     containerRegistryName: containerRegistry.outputs.name
//     userAssignedIdentityId: managedIdentity.outputs.id
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     githubActions: githubActions
//   }
// }

// Application Insights & Log Analytics (uncomment and modify as needed)
// module monitoring './core/monitor/monitoring.bicep' = {
//   name: 'monitoring'
//   scope: rg
//   params: {
//     logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
//     applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
//     location: location
//     tags: tags
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     managedIdentityClientId: managedIdentity.outputs.clientId
//     managedIdentityResourceId: managedIdentity.outputs.id
//     githubActions: githubActions
//   }
// }

// Key Vault (uncomment and modify as needed)
// module keyVault './core/security/keyvault.bicep' = {
//   name: 'keyVault'
//   scope: rg
//   params: {
//     name: '${abbrs.keyVaultVaults}${resourceToken}'
//     location: location
//     tags: tags
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     managedIdentityClientId: managedIdentity.outputs.clientId
//     managedIdentityResourceId: managedIdentity.outputs.id
//     githubActions: githubActions
//   }
// }

// AI Search (uncomment and modify as needed)
// module aiSearch './core/ai/ai-search.bicep' = {
//   name: 'aiSearch'
//   scope: rg
//   params: {
//     name: '${abbrs.searchSearchServices}${resourceToken}'
//     location: location
//     tags: tags
//     sku: 'basic'
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     githubActions: githubActions
//   }
// }

// Cosmos DB (uncomment and modify as needed)
// module cosmosDb './core/database/cosmos-db.bicep' = {
//   name: 'cosmosDb'
//   scope: rg
//   params: {
//     name: '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
//     location: location
//     tags: tags
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     githubActions: githubActions
//   }
// }

// Storage Account (uncomment and modify as needed)
// module storageAccount './core/storage/storage-account.bicep' = {
//   name: 'storageAccount'
//   scope: rg
//   params: {
//     name: '${abbrs.storageStorageAccounts}${resourceToken}'
//     location: location
//     tags: tags
//     managedIdentityPrincipalId: managedIdentity.outputs.principalId
//     githubActions: githubActions
//   }
// }

// AI Foundry (uncomment and modify as needed)
// module aiFoundry './core/ai/ai-foundry.bicep' = {
//   name: 'aiFoundry'
//   scope: rg
//   params: {
//     workspaceName: 'mlw-${resourceToken}'
//     aiHubName: 'aih-${resourceToken}'
//     location: location
//     tags: tags
//     keyVaultId: keyVault.outputs.id
//     storageAccountId: storageAccount.outputs.id
//     applicationInsightsId: monitoring.outputs.applicationInsightsId
//   }
// }

// Add your Azure resources here

// Outputs (add relevant outputs based on your resources)
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_PRINCIPAL_ID string = principalId
output GITHUB_ACTIONS bool = githubActions
