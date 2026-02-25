# Bicep Patterns for Azure Container Apps (azd-compliant)

## Table of Contents

1. [Main Bicep Structure](#main-bicep-structure)
2. [Container Apps Environment Module](#container-apps-environment-module)
3. [Container App Module](#container-app-module)
4. [Resource Naming Conventions](#resource-naming-conventions)
5. [Environment Variables Pattern](#environment-variables-pattern)
6. [Image Preservation Pattern](#image-preservation-pattern)

---

## Main Bicep Structure

### Resource Group-Scoped Deployment

```bicep
targetScope = 'resourceGroup'

// ── METADATA ─────────────────────────────────────────────────
metadata description = 'Main infrastructure template for [Project Name]'

// ── PARAMETERS ───────────────────────────────────────────────
@minLength(1)
@maxLength(64)
@description('Name of the environment')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Principal ID for local RBAC (empty in CI)')
param principalId string = ''

// Per-service image preservation params (REQUIRED for containerapp services)
@description('Container image for the api service')
param apiImageName string = ''

@description('Whether the api Container App already exists')
param apiExists bool = false

@description('Container image for the web service')
param webImageName string = ''

@description('Whether the web Container App already exists')
param webExists bool = false

// External service parameters
@description('Azure OpenAI service endpoint')
param azureOpenAiEndpoint string = ''

// ── VARIABLES ────────────────────────────────────────────────
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName  // REQUIRED — azd resource discovery
}

// ── SHARED INFRASTRUCTURE ────────────────────────────────────
module userAssignedIdentity 'core/security/user-assigned-identity.bicep' = {
  name: 'user-assigned-identity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

module monitoring 'core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    name: '${abbrs.insightsComponents}${resourceToken}'
    location: location
    tags: tags
  }
}

module keyVault 'core/security/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}

// ── HOSTING INFRASTRUCTURE ───────────────────────────────────
module containerRegistry 'core/storage/container-registry.bicep' = {
  name: 'container-registry'
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    tags: tags
  }
}

module containerAppsEnvironment 'core/host/container-apps-environment.bicep' = {
  name: 'container-apps-environment'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

// ── APPLICATION MODULES ──────────────────────────────────────
module api 'core/host/container-app.bicep' = {
  name: 'api'
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })  // ← REQUIRED for azd
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    containerImage: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    targetPort: 8000
    env: [
      { name: 'AZURE_CLIENT_ID', value: userAssignedIdentity.outputs.clientId }
      { name: 'AZURE_OPENAI_ENDPOINT', value: azureOpenAiEndpoint }
    ]
  }
}

module web 'core/host/container-app.bicep' = {
  name: 'web'
  params: {
    name: '${abbrs.appContainerApps}web-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })  // ← REQUIRED for azd
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    containerImage: !empty(webImageName) ? webImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    targetPort: 80
    env: [
      { name: 'BACKEND_URL', value: 'http://${abbrs.appContainerApps}api-${resourceToken}' }
    ]
  }
}

// ── OUTPUTS ──────────────────────────────────────────────────
// Environment info
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup().name

// Identity
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId

// Infrastructure
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

// Per-service (pattern: SERVICE_<NAME>_<PROPERTY>)
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
output SERVICE_WEB_ENDPOINT_URL string = web.outputs.fqdn
output SERVICE_WEB_NAME string = web.outputs.name
```

---

## Container Apps Environment Module

```bicep
// infra/core/host/container-apps-environment.bicep
@description('Name of the Container Apps environment')
param name string

@description('Location')
param location string = resourceGroup().location

@description('Tags')
param tags object = {}

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: last(split(logAnalyticsWorkspaceId, '/'))
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
```

---

## Container App Module

```bicep
// infra/core/host/container-app.bicep
@description('Container App name')
@minLength(1)
param name string

@description('Location')
param location string = resourceGroup().location

@description('Tags — must include azd-service-name for azd discovery')
param tags object = {}

@description('Container Apps Environment ID')
param containerAppsEnvironmentId string

@description('Container Registry name')
param containerRegistryName string

@description('Container image to deploy')
param containerImage string

@description('Target port')
param targetPort int = 80

@description('Environment variables')
param env array = []

@description('CPU cores')
param cpu string = '0.5'

@description('Memory')
param memory string = '1Gi'

@description('Minimum replicas')
param minReplicas int = 1

@description('Maximum replicas')
param maxReplicas int = 3

@description('Custom domains (empty = preserve Portal-added)')
param customDomains array = []

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'auto'
        allowInsecure: false
        customDomains: empty(customDomains) ? null : customDomains
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: 'system'  // ✅ Managed identity — NOT admin credentials
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'main'
          image: containerImage
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: { concurrentRequests: '100' }
            }
          }
        ]
      }
    }
  }
}

output id string = containerApp.id
output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
output uri string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output principalId string = containerApp.identity.principalId
```

---

## Resource Naming Conventions

```bicep
// Generate unique, deterministic suffix
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Use abbreviations.json for prefixes
var abbrs = loadJsonContent('./abbreviations.json')

// Naming examples
var names = {
  resourceGroup: '${abbrs.resourcesResourceGroups}${environmentName}'
  containerAppsEnv: '${abbrs.appManagedEnvironments}${resourceToken}'
  containerRegistry: '${abbrs.containerRegistryRegistries}${resourceToken}'
  keyVault: '${abbrs.keyVaultVaults}${resourceToken}'
  apiApp: '${abbrs.appContainerApps}api-${resourceToken}'
  webApp: '${abbrs.appContainerApps}web-${resourceToken}'
}
```

**Shared subscription safety**: Always include `resourceToken` for globally unique resources (Key Vault, Storage, ACR, Cognitive Services).

---

## Environment Variables Pattern

### Container App Env Vars in Bicep

```bicep
env: [
  // Static — known at deploy time
  { name: 'PORT', value: '8000' }

  // Dynamic — from parameters or other modules
  { name: 'AZURE_CLIENT_ID', value: identity.outputs.clientId }
  { name: 'AZURE_OPENAI_ENDPOINT', value: azureOpenAiEndpoint }

  // Internal service discovery (HTTP, not HTTPS)
  { name: 'BACKEND_URL', value: 'http://ca-api-${resourceToken}' }

  // Secret reference (from secretRef)
  { name: 'API_KEY', secretRef: 'api-key-secret' }
]
```

### Key Vault References (Production)

```bicep
secrets: [
  {
    name: 'api-key'
    keyVaultUrl: '${keyVault.properties.vaultUri}secrets/api-key'
    identity: 'system'
  }
]
```

---

## Image Preservation Pattern

For each containerapp service, ensure both IMAGE_NAME and RESOURCE_EXISTS are wired through:

### 1. main.parameters.json

```json
{
  "parameters": {
    "apiImageName": { "value": "${SERVICE_API_IMAGE_NAME=}" },
    "apiExists": { "value": "${SERVICE_API_RESOURCE_EXISTS=false}" },
    "webImageName": { "value": "${SERVICE_WEB_IMAGE_NAME=}" },
    "webExists": { "value": "${SERVICE_WEB_RESOURCE_EXISTS=false}" }
  }
}
```

### 2. main.bicep Params

```bicep
@description('Container image for the api service')
param apiImageName string = ''

@description('Whether the api Container App already exists')
param apiExists bool = false
```

### 3. Image Guard in Module Call

```bicep
module api 'core/host/container-app.bicep' = {
  params: {
    containerImage: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
  }
}
```

### AVM Alternative (Recommended)

```bicep
module api 'br/public:avm/ptn/azd/container-app-upsert:<version>' = {
  params: {
    imageName: !empty(apiImageName) ? apiImageName : ''
    exists: apiExists
  }
}
```
