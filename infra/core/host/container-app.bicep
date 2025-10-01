@description('The name for the Container App')
param name string

@description('The Azure region where the container app will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the container app')
param tags object = {}

@description('Container Apps Environment ID')
param containerAppsEnvironmentId string

@description('Container Registry name for pulling images')
param containerRegistryName string = ''

@description('User Assigned Identity ID for ACR access')
param userAssignedIdentityId string = ''

@description('Container image to deploy')
param containerImage string = 'mcr.microsoft.com/k8se/quickstart:latest'

@description('Container port')
param containerPort int = 80

@description('Environment variables for the container')
param environmentVariables array = []

@description('CPU and memory resources')
param resources object = {
  cpu: '0.25'
  memory: '0.5Gi'
}

@description('Replica settings')
param scale object = {
  minReplicas: 0
  maxReplicas: 10
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  tags: tags
  identity: !empty(userAssignedIdentityId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  } : null
  properties: {
    environmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: containerPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: !empty(containerRegistryName) ? [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: userAssignedIdentityId
        }
      ] : []
    }
    template: {
      containers: [
        {
          name: 'main'
          image: containerImage
          env: environmentVariables
          resources: resources
        }
      ]
      scale: scale
    }
  }
}

output id string = containerApp.id
output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
output latestRevisionName string = containerApp.properties.latestRevisionName
