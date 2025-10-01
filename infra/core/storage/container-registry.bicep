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

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

output id string = containerRegistry.id
output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
