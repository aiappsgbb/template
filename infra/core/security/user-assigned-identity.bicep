@description('The name for the User Assigned Managed Identity')
param name string

@description('The Azure region where the identity will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the identity')
param tags object = {}

// User Assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

output id string = userAssignedIdentity.id
output name string = userAssignedIdentity.name
output principalId string = userAssignedIdentity.properties.principalId
output clientId string = userAssignedIdentity.properties.clientId
