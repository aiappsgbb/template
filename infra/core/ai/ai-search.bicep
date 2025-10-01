@description('The name for the AI Search service')
param name string

@description('The Azure region where the service will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the service')
param tags object = {}

@description('Search service SKU')
@allowed(['free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param sku string = 'basic'

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

@description('Public network access setting')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

@description('Search service semantic search setting')
@allowed(['disabled', 'free', 'standard'])
param semanticSearch string = 'disabled'

// Use AVM AI Search module
module aiSearchService 'br/public:avm/res/search/search-service:0.11.1' = {
  name: 'aiSearchService'
  params: {
    name: name
    location: location
    tags: tags
    sku: sku
    publicNetworkAccess: publicNetworkAccess
    semanticSearch: semanticSearch
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Search Service Contributor'
        principalType: principalType
      }
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Search Index Data Contributor'
        principalType: principalType
      }
    ] : []
  }
}

output id string = aiSearchService.outputs.resourceId
output name string = aiSearchService.outputs.name
output endpoint string = 'https://${aiSearchService.outputs.name}.search.windows.net/'
