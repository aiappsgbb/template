@description('The name for the storage account')
param name string

@description('The Azure region where the storage account will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the storage account')
param tags object = {}

@description('The storage account SKU')
param skuName string = 'Standard_LRS'

@description('Allow blob public access')
param allowBlobPublicAccess bool = false

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// Use AVM Storage Account module
module storageAccount 'br/public:avm/res/storage/storage-account:0.27.0' = {
  name: 'storageAccount'
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    kind: 'StorageV2'
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        principalType: principalType
      }
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Storage Account Contributor'
        principalType: principalType
      }
    ] : []
  }
}

output id string = storageAccount.outputs.resourceId
output name string = storageAccount.outputs.name
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint
