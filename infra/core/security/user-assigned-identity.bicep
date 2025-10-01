@description('The name for the User Assigned Managed Identity')
param name string

@description('The Azure region where the identity will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the identity')
param tags object = {}

// Use AVM User Assigned Managed Identity module
module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'userAssignedIdentity'
  params: {
    name: name
    location: location
    tags: tags
  }
}

output id string = userAssignedIdentity.outputs.resourceId
output name string = userAssignedIdentity.outputs.name
output principalId string = userAssignedIdentity.outputs.principalId
output clientId string = userAssignedIdentity.outputs.clientId
