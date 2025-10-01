@description('The name for the Container Apps Environment')
param name string

@description('The Azure region where the environment will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the environment')
param tags object = {}

@description('Log Analytics Workspace ID for the environment')
param logAnalyticsWorkspaceId string

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

@description('Zone redundancy setting')
param zoneRedundant bool = false

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// Use AVM Container Apps Environment module
module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
  name: 'containerAppsEnvironment'
  params: {
    name: name
    location: location
    tags: tags
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2023-09-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2023-09-01').primarySharedKey
      }
    }
    zoneRedundant: zoneRedundant
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'ContainerApp Environment Reader'
        principalType: principalType
      }
    ] : []
  }
}

output id string = containerAppsEnvironment.outputs.resourceId
output name string = containerAppsEnvironment.outputs.name
output defaultDomain string = containerAppsEnvironment.outputs.defaultDomain
