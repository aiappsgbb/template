@description('The name for the Container App')
param name string

@description('The Azure region where the container app will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the container app')
param tags object = {}

@description('Whether the Container App already exists (for incremental updates)')
param exists bool = false

@description('Container Apps Environment ID')
param containerAppsEnvironmentId string

@description('Container Registry name for pulling images')
param containerRegistryName string = ''

@description('User Assigned Identity ID for ACR access')
param userAssignedIdentityId string = ''

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

@description('Container image to deploy')
param containerImage string = 'mcr.microsoft.com/k8se/quickstart:latest'

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// Container configuration for the app
var containerConfig = {
  name: 'main'
  image: containerImage
  resources: {
    cpu: json(resources.cpu)
    memory: resources.memory
  }
  env: environmentVariables
}

// For incremental updates, we'll rely on Container Apps' built-in revision management
// The AVM module handles updates efficiently by only changing what's necessary
var containersConfig = [containerConfig]

@description('Container port')
param containerPort int = 80

@description('Environment variables for the container')
param environmentVariables array = []

@description('CPU and memory resources')
param resources object = {
  cpu: '0.25'
  memory: '0.5Gi'
}

// Use AVM Container App module with dynamic container configuration
module containerApp 'br/public:avm/res/app/container-app:0.18.1' = {
  name: 'containerApp'
  params: {
    name: name
    location: location
    tags: tags
    environmentResourceId: containerAppsEnvironmentId
    managedIdentities: !empty(userAssignedIdentityId) ? {
      userAssignedResourceIds: [userAssignedIdentityId]
    } : {}
    containers: containersConfig
    ingressExternal: true
    ingressTargetPort: containerPort
    registries: !empty(containerRegistryName) ? [
      {
        server: '${containerRegistryName}.azurecr.io'
        identity: userAssignedIdentityId
      }
    ] : []
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'ContainerApp Reader'
        principalType: principalType
      }
    ] : []
  }
}

output id string = containerApp.outputs.resourceId
output name string = containerApp.outputs.name
output fqdn string = containerApp.outputs.fqdn
output latestRevisionName string = containerImage
output containerImage string = containerImage
output exists bool = exists
