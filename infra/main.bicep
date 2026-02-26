targetScope = 'subscription'

// ── METADATA ──────────────────────────────────────────────────
metadata description = 'Main infrastructure template — uses Azure Verified Modules (AVM) directly'

// ── PARAMETERS ────────────────────────────────────────────────
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

@description('Resource group name. If not provided, will be generated based on environment name.')
param resourceGroupName string = ''

// ── VARIABLES ─────────────────────────────────────────────────
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  'deployment-source': githubActions ? 'github-actions' : 'local'
}
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// ── RESOURCE GROUP ────────────────────────────────────────────
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// ══════════════════════════════════════════════════════════════
// All modules below use Azure Verified Modules (AVM) directly
// from the public Bicep registry: br/public:avm/...
// Docs: https://azure.github.io/Azure-Verified-Modules/
// ══════════════════════════════════════════════════════════════

// ── SHARED INFRASTRUCTURE ─────────────────────────────────────

// User Assigned Managed Identity
module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'managedIdentity'
  scope: rg
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

// ── MONITORING (uncomment and modify as needed) ───────────────

// Log Analytics Workspace
// module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
//   name: 'logAnalyticsWorkspace'
//   scope: rg
//   params: {
//     name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
//     location: location
//     tags: tags
//     dataRetention: 30
//     skuName: 'PerGB2018'
//   }
// }

// Application Insights
// module applicationInsights 'br/public:avm/res/insights/component:0.6.0' = {
//   name: 'applicationInsights'
//   scope: rg
//   params: {
//     name: '${abbrs.insightsComponents}${resourceToken}'
//     location: location
//     tags: tags
//     applicationType: 'web'
//     workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
//   }
// }

// ── SECURITY (uncomment and modify as needed) ─────────────────

// Key Vault
// module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
//   name: 'keyVault'
//   scope: rg
//   params: {
//     name: '${abbrs.keyVaultVaults}${resourceToken}'
//     location: location
//     tags: tags
//     sku: 'standard'
//     enableRbacAuthorization: true
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'Key Vault Secrets User'
//         principalType: principalType
//       }
//     ]
//   }
// }

// ── HOSTING INFRASTRUCTURE (uncomment and modify as needed) ───

// Container Registry
// module containerRegistry 'br/public:avm/res/container-registry/registry:0.9.3' = {
//   name: 'containerRegistry'
//   scope: rg
//   params: {
//     name: '${abbrs.containerRegistryRegistries}${resourceToken}'
//     location: location
//     tags: tags
//     acrSku: 'Basic'
//     acrAdminUserEnabled: true
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'AcrPull'
//         principalType: principalType
//       }
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'AcrPush'
//         principalType: principalType
//       }
//     ]
//   }
// }

// Container Apps Environment
// module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
//   name: 'containerAppsEnvironment'
//   scope: rg
//   params: {
//     name: '${abbrs.appManagedEnvironments}${resourceToken}'
//     location: location
//     tags: tags
//     appLogsConfiguration: {
//       destination: 'log-analytics'
//       logAnalyticsConfiguration: {
//         customerId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
//         sharedKey: listKeys(logAnalyticsWorkspace.outputs.resourceId, '2023-09-01').primarySharedKey
//       }
//     }
//     zoneRedundant: false
//   }
// }

// Container App
// module containerApp 'br/public:avm/res/app/container-app:0.18.1' = {
//   name: 'containerApp'
//   scope: rg
//   params: {
//     name: '${abbrs.appContainerApps}web-${resourceToken}'
//     location: location
//     tags: union(tags, { 'azd-service-name': 'web' })
//     environmentResourceId: containerAppsEnvironment.outputs.resourceId
//     managedIdentities: {
//       userAssignedResourceIds: [managedIdentity.outputs.resourceId]
//     }
//     containers: [
//       {
//         name: 'main'
//         image: 'mcr.microsoft.com/k8se/quickstart:latest'
//         resources: {
//           cpu: json('1')
//           memory: '2Gi'
//         }
//         env: [
//           { name: 'AZURE_CLIENT_ID', value: managedIdentity.outputs.clientId }
//         ]
//       }
//     ]
//     ingressExternal: true
//     ingressTargetPort: 80
//     registries: [
//       {
//         server: '${containerRegistry.outputs.name}.azurecr.io'
//         identity: managedIdentity.outputs.resourceId
//       }
//     ]
//   }
// }

// ── AI SERVICES (uncomment and modify as needed) ──────────────

// Azure OpenAI
// module azureOpenAi 'br/public:avm/res/cognitive-services/account:0.10.1' = {
//   name: 'azureOpenAi'
//   scope: rg
//   params: {
//     name: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
//     kind: 'OpenAI'
//     location: location
//     tags: tags
//     customSubDomainName: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
//     publicNetworkAccess: 'Enabled'
//     deployments: [
//       {
//         name: 'gpt-4o'
//         model: {
//           format: 'OpenAI'
//           name: 'gpt-4o'
//           version: '2024-11-20'
//         }
//         sku: {
//           name: 'Standard'
//           capacity: 20
//         }
//       }
//     ]
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
//         principalType: principalType
//       }
//     ]
//   }
// }

// AI Search
// module aiSearch 'br/public:avm/res/search/search-service:0.11.1' = {
//   name: 'aiSearch'
//   scope: rg
//   params: {
//     name: '${abbrs.searchSearchServices}${resourceToken}'
//     location: location
//     tags: tags
//     sku: 'basic'
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'Search Service Contributor'
//         principalType: principalType
//       }
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'Search Index Data Contributor'
//         principalType: principalType
//       }
//     ]
//   }
// }

// ── DATA (uncomment and modify as needed) ─────────────────────

// Cosmos DB
// module cosmosDb 'br/public:avm/res/document-db/database-account:0.16.0' = {
//   name: 'cosmosDb'
//   scope: rg
//   params: {
//     name: '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
//     location: location
//     tags: tags
//     defaultConsistencyLevel: 'Session'
//     sqlDatabases: [
//       {
//         name: 'main'
//         containers: [
//           {
//             name: 'items'
//             paths: ['/id']
//           }
//         ]
//       }
//     ]
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'DocumentDB Account Contributor'
//         principalType: principalType
//       }
//     ]
//   }
// }

// ── STORAGE (uncomment and modify as needed) ──────────────────

// Storage Account
// module storageAccount 'br/public:avm/res/storage/storage-account:0.27.0' = {
//   name: 'storageAccount'
//   scope: rg
//   params: {
//     name: '${abbrs.storageStorageAccounts}${resourceToken}'
//     location: location
//     tags: tags
//     skuName: 'Standard_LRS'
//     kind: 'StorageV2'
//     allowBlobPublicAccess: false
//     roleAssignments: [
//       {
//         principalId: managedIdentity.outputs.principalId
//         roleDefinitionIdOrName: 'Storage Blob Data Contributor'
//         principalType: principalType
//       }
//     ]
//   }
// }

// Add your Azure resources here

// ── OUTPUTS ───────────────────────────────────────────────────
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_PRINCIPAL_ID string = principalId
output GITHUB_ACTIONS bool = githubActions
