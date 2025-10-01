@description('The name for the Machine Learning workspace')
param workspaceName string

@description('The name for the AI Hub')
param aiHubName string

@description('The Azure region where the resources will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the resources')
param tags object = {}

@description('Key Vault resource ID')
param keyVaultId string

@description('Storage Account resource ID')
param storageAccountId string

@description('Application Insights resource ID')
param applicationInsightsId string

@description('Container Registry resource ID (optional)')
param containerRegistryId string = ''

// AI Hub (Machine Learning Workspace)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'AI Hub for AI Foundry'
    friendlyName: aiHubName
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: !empty(containerRegistryId) ? containerRegistryId : null
    hbiWorkspace: false
    allowPublicAccessWhenBehindVnet: true
    discoveryUrl: 'https://${location}.api.azureml.ms/discovery'
  }
  kind: 'Hub'
}

// AI Project (Machine Learning Workspace)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: workspaceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'AI Project workspace'
    friendlyName: workspaceName
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: !empty(containerRegistryId) ? containerRegistryId : null
    hbiWorkspace: false
    allowPublicAccessWhenBehindVnet: true
    hubResourceId: aiHub.id
  }
  kind: 'Project'
}

output aiHubId string = aiHub.id
output aiHubName string = aiHub.name
output aiProjectId string = aiProject.id
output aiProjectName string = aiProject.name
output discoveryUrl string = aiHub.properties.discoveryUrl
