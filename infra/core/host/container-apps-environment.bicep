@description('The name for the Container Apps Environment')
param name string

@description('The Azure region where the environment will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the environment')
param tags object = {}

@description('Log Analytics Workspace ID for the environment')
param logAnalyticsWorkspaceId string

@description('Whether to enable workload profiles')
param workloadProfiles array = []

@description('Zone redundancy setting')
param zoneRedundant bool = false

// Container Apps Environment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2023-09-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2023-09-01').primarySharedKey
      }
    }
    zoneRedundant: zoneRedundant
    workloadProfiles: !empty(workloadProfiles) ? workloadProfiles : null
  }
}

output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
output defaultDomain string = containerAppsEnvironment.properties.defaultDomain
