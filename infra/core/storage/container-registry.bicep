@description('The name for the Container Registry')
param name string

@description('The Azure region where the registry will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the registry')
param tags object = {}

@description('Container Registry SKU')
param sku string = 'Basic'

@description('Enable admin user for the registry')
param adminUserEnabled bool = false

@description('Enable public network access')
param publicNetworkAccess string = 'Enabled'

@description('Zone redundancy setting')
param zoneRedundancy string = 'Disabled'

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('User Assigned Managed Identity Client ID')
param managedIdentityClientId string = ''

@description('User Assigned Managed Identity Resource ID')
param managedIdentityResourceId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// Use AVM Container Registry module
module containerRegistry 'br/public:avm/res/container-registry/registry:0.9.3' = {
  name: 'containerRegistry'
  params: {
    name: name
    location: location
    tags: tags
    acrSku: sku
    acrAdminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'AcrPull' // Built-in role for pulling images
        principalType: principalType
      }
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'AcrPush' // Built-in role for pushing images
        principalType: principalType
      }
    ] : []
  }
}

output id string = containerRegistry.outputs.resourceId
output name string = containerRegistry.outputs.name
output loginServer string = containerRegistry.outputs.loginServer
