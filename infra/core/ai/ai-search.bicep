@description('The name for the AI Search service')
param name string

@description('The Azure region where the service will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the service')
param tags object = {}

@description('Search service SKU')
@allowed(['free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param sku string = 'basic'

@description('Number of replicas')
param replicaCount int = 1

@description('Number of partitions')
param partitionCount int = 1

@description('Hosting mode for the search service')
@allowed(['default', 'highDensity'])
param hostingMode string = 'default'

@description('Public network access setting')
@allowed(['enabled', 'disabled'])
param publicNetworkAccess string = 'enabled'

@description('Search service semantic search setting')
@allowed(['disabled', 'free', 'standard'])
param semanticSearch string = 'disabled'

// AI Search Service
resource aiSearchService 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
    hostingMode: hostingMode
    publicNetworkAccess: publicNetworkAccess
    semanticSearch: semanticSearch
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
  }
}

output id string = aiSearchService.id
output name string = aiSearchService.name
output endpoint string = 'https://${aiSearchService.name}.search.windows.net/'
