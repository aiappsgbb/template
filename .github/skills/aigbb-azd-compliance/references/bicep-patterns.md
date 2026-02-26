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
module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'managed-identity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'log-analytics'
  params: {
    name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
    tags: tags
  }
}

module applicationInsights 'br/public:avm/res/insights/component:0.6.0' = {
  name: 'application-insights'
  params: {
    name: '${abbrs.insightsComponents}${resourceToken}'
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
}

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'keyvault'
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
  }
}

// ── HOSTING INFRASTRUCTURE ───────────────────────────────────
module containerRegistry 'br/public:avm/res/container-registry/registry:0.9.3' = {
  name: 'container-registry'
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    tags: tags
  }
}

// Reference deployed Log Analytics workspace for shared key
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspace.outputs.name
}

module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
  name: 'container-apps-environment'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// ── APPLICATION MODULES ──────────────────────────────────────
module api 'br/public:avm/res/app/container-app:0.18.1' = {
  name: 'api'
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })  // ← REQUIRED for azd
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    containers: [
      {
        name: 'main'
        image: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
        resources: { cpu: json('0.5'), memory: '1Gi' }
        env: [
          { name: 'AZURE_CLIENT_ID', value: managedIdentity.outputs.clientId }
          { name: 'AZURE_OPENAI_ENDPOINT', value: azureOpenAiEndpoint }
        ]
      }
    ]
    ingressExternal: true
    ingressTargetPort: 8000
    registries: [
      {
        server: containerRegistry.outputs.loginServer
        identity: managedIdentity.outputs.resourceId
      }
    ]
    managedIdentities: {
      userAssignedResourceIds: [managedIdentity.outputs.resourceId]
    }
  }
}

module web 'br/public:avm/res/app/container-app:0.18.1' = {
  name: 'web'
  params: {
    name: '${abbrs.appContainerApps}web-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })  // ← REQUIRED for azd
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    containers: [
      {
        name: 'main'
        image: !empty(webImageName) ? webImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
        resources: { cpu: json('0.5'), memory: '1Gi' }
        env: [
          { name: 'BACKEND_URL', value: 'http://${abbrs.appContainerApps}api-${resourceToken}' }
        ]
      }
    ]
    ingressExternal: true
    ingressTargetPort: 80
    registries: [
      {
        server: containerRegistry.outputs.loginServer
        identity: managedIdentity.outputs.resourceId
      }
    ]
    managedIdentities: {
      userAssignedResourceIds: [managedIdentity.outputs.resourceId]
    }
  }
}

// ── OUTPUTS ──────────────────────────────────────────────────
// Environment info
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup().name

// Identity
output AZURE_CLIENT_ID string = managedIdentity.outputs.clientId

// Infrastructure
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.uri
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

// Per-service (pattern: SERVICE_<NAME>_<PROPERTY>)
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
output SERVICE_WEB_ENDPOINT_URL string = web.outputs.fqdn
output SERVICE_WEB_NAME string = web.outputs.name
```

---

## Container Apps Environment (AVM Pattern)

```bicep
// No wrapper module needed — call AVM directly from main.bicep

// Reference deployed Log Analytics workspace for shared key
resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspace.outputs.name
}

module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
  name: 'container-apps-environment'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Key AVM outputs:
// .outputs.resourceId  — use for Container App environmentResourceId
// .outputs.name        — environment name
```

---

## Container App (AVM Pattern)

```bicep
// No wrapper module needed — call AVM directly from main.bicep
module api 'br/public:avm/res/app/container-app:0.18.1' = {
  name: 'api'
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })  // ← REQUIRED for azd

    // Link to Container Apps Environment
    environmentResourceId: containerAppsEnvironment.outputs.resourceId

    // Container definition (replaces template.containers in raw resource)
    containers: [
      {
        name: 'main'
        image: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
        resources: { cpu: json('0.5'), memory: '1Gi' }
        env: [
          { name: 'AZURE_CLIENT_ID', value: managedIdentity.outputs.clientId }
          { name: 'PORT', value: '8000' }
        ]
      }
    ]

    // Ingress (replaces properties.configuration.ingress)
    ingressExternal: true
    ingressTargetPort: 8000

    // ACR pull via managed identity (replaces properties.configuration.registries)
    registries: [
      {
        server: containerRegistry.outputs.loginServer
        identity: managedIdentity.outputs.resourceId
      }
    ]

    // Identity (replaces identity block)
    managedIdentities: {
      userAssignedResourceIds: [managedIdentity.outputs.resourceId]
    }
  }
}

// Key AVM outputs:
// .outputs.resourceId  — Container App resource ID
// .outputs.name        — Container App name (use for SERVICE_<NAME>_NAME)
// .outputs.fqdn        — Ingress FQDN (use for SERVICE_<NAME>_ENDPOINT_URL)
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
  { name: 'AZURE_CLIENT_ID', value: managedIdentity.outputs.clientId }
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
module api 'br/public:avm/res/app/container-app:0.18.1' = {
  params: {
    containers: [
      {
        name: 'main'
        image: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
        // ... other container properties
      }
    ]
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
