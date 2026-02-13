---
name: bicep-azd-patterns
description: Bicep infrastructure templates and patterns for Azure Developer CLI (azd) projects. Use when writing main.bicep, creating modules, configuring Container Apps in Bicep, managing parameters, outputs, tags, RBAC assignments, or aligning environment variables between Bicep and application code. Triggers on Bicep, main.bicep, parameters.json, azd tags, RBAC, Container Apps Bicep, module, output.
---

# Bicep Templates for Azure Developer CLI (azd)

Patterns for writing Bicep infrastructure that integrates cleanly with `azd provision`, `azd deploy`, and `azd down`.

## main.bicep Organization (7 sections)

```bicep
targetScope = 'resourceGroup'

// ── 1. METADATA ──────────────────────────────────────────────
metadata description = 'Main infrastructure template for [Project Name]'

// ── 2. PARAMETERS ────────────────────────────────────────────
@description('Environment name')
@minLength(1)
@maxLength(64)
param environmentName string

@description('Primary location for all resources')
param location string

@description('Principal ID for local RBAC (empty in CI)')
param principalId string = ''

// Per-service image + exists params (see Container Image Preservation)
@description('Container image for the api service')
param apiImageName string = ''

@description('Whether the api Container App already exists')
param apiExists bool = false

// ── 3. VARIABLES ─────────────────────────────────────────────
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
}

// ── 4. SHARED INFRASTRUCTURE ─────────────────────────────────
module userAssignedIdentity 'core/security/user-assigned-identity.bicep' = {
  name: 'user-assigned-identity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

module monitoring 'core/monitor/monitoring.bicep' = { /* ... */ }
module keyVault 'core/security/keyvault.bicep' = { /* ... */ }

// ── 5. HOSTING INFRASTRUCTURE ────────────────────────────────
module containerRegistry 'core/storage/container-registry.bicep' = { /* ... */ }
module containerAppsEnvironment 'core/host/container-apps-environment.bicep' = { /* ... */ }

// ── 6. APPLICATION MODULES ───────────────────────────────────
module api 'core/host/container-app.bicep' = {
  name: 'api'
  params: {
    name: '${abbrs.appContainerApps}api-${resourceToken}'
    tags: union(tags, { 'azd-service-name': 'api' })  // ← REQUIRED for azd
    containerImage: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    // ...
  }
}

// ── 7. OUTPUTS ───────────────────────────────────────────────
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup().name
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
```

## Parameter Validation

```bicep
@description('Environment name')
@minLength(1)
@maxLength(64)
param environmentName string

@description('SKU tier')
@allowed(['basic', 'standard', 'premium'])
param skuTier string = 'basic'

@description('Container image (managed by azd deploy)')
param containerImage string = ''
```

Always add `@description` to every parameter. Use `@allowed`, `@minLength`, `@maxLength`, `@minValue`, `@maxValue` where applicable.

## main.parameters.json

Every parameter without a default in main.bicep **must** appear here:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": { "value": "${AZURE_ENV_NAME}" },
    "location": { "value": "${AZURE_LOCATION}" },
    "principalId": { "value": "${AZURE_PRINCIPAL_ID}" },
    "apiImageName": { "value": "${SERVICE_API_IMAGE_NAME=}" },
    "apiExists": { "value": "${SERVICE_API_RESOURCE_EXISTS=false}" }
  }
}
```

- `${AZURE_ENV_NAME}` and `${AZURE_LOCATION}` are auto-populated by azd.
- `${SERVICE_<NAME>_IMAGE_NAME=}` — the `=` provides an empty default for first deploy.
- `${SERVICE_<NAME>_RESOURCE_EXISTS=false}` — defaults to `false` for first deploy.

## Container Image Preservation (IMAGE_NAME / RESOURCE_EXISTS)

For each service with `host: containerapp` in azure.yaml, azd manages two variables to prevent re-provision from overwriting the deployed image:

| Variable | Set By | Purpose |
|----------|--------|---------|
| `SERVICE_<NAME>_IMAGE_NAME` | `azd deploy` | Currently deployed image tag |
| `SERVICE_<NAME>_RESOURCE_EXISTS` | `azd provision` | Whether resource already exists |

### Bicep usage

```bicep
param apiImageName string = ''
param apiExists bool = false

module api 'core/host/container-app.bicep' = {
  params: {
    containerImage: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    // pass exists to module if it supports upsert behavior
  }
}
```

### What breaks without this

| Scenario | Without these params | With them |
|----------|---------------------|-----------|
| First `azd provision` | ✅ Works | ✅ Works |
| Re-run `azd provision` | ❌ Overwrites deployed image | ✅ Preserves image |
| `azd up` (provision + deploy) | ⚠️ Temporary downtime | ✅ No downtime |

## Tags

### Resource Group
```bicep
var tags = {
  'azd-env-name': environmentName  // REQUIRED — azd uses this to find resources
}
```

### Service Resources (Container Apps, Functions, App Service)
```bicep
tags: union(tags, {
  'azd-service-name': 'api'  // MUST match service key in azure.yaml
})
```

## Output Naming Convention

```bicep
// Environment info
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup().name

// Identity
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId

// Per-service endpoints (pattern: SERVICE_<NAME>_<PROPERTY>)
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
output SERVICE_WEB_ENDPOINT_URL string = web.outputs.fqdn

// Infrastructure endpoints (consumed by app config)
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
```

Outputs automatically become azd environment variables.

## RBAC Assignments

Always guard with `if (!empty(principalId))`:

```bicep
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(resource.id, principalId, roleId)
  scope: resource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

### Common Role IDs

| Role | ID |
|------|----|
| Cognitive Services User | `a97b65f3-24c7-4388-baec-2e87135dc908` |
| Key Vault Secrets User | `4633458b-17de-408a-b874-0445c86b69e6` |
| Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` |
| Search Service Contributor | `7ca78c08-252a-4471-8644-bb5ff32d4ba0` |
| AcrPull | `7f951dda-4ed3-4680-a7ca-43fe172d538d` |

**Never use `Contributor` or `Owner`** when a specific role suffices.

## Module Template

```bicep
// infra/core/<category>/<service>.bicep
targetScope = 'resourceGroup'

@description('Resource name')
@minLength(1)
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

@description('Managed Identity Principal ID for RBAC')
param managedIdentityPrincipalId string = ''

resource svc 'Microsoft.SomeService/resource@2024-01-01' = {
  name: name
  location: location
  tags: tags
  properties: { /* ... */ }
}

// Conditional RBAC
resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(managedIdentityPrincipalId)) {
  name: guid(svc.id, managedIdentityPrincipalId, 'RoleName')
  scope: svc
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '<role-id>')
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output id string = svc.id
output name string = svc.name
```

## Environment Variable Alignment

Container Apps env vars **must match** the application's configuration class:

```bicep
// Bicep
environmentVariables: [
  { name: 'AZURE_CLIENT_ID', value: identity.outputs.clientId }
  { name: 'AZURE_OPENAI_ENDPOINT', value: openAi.outputs.endpoint }
  { name: 'APPLICATION_INSIGHTS_CONNECTION_STRING', value: monitoring.outputs.appInsightsConnectionString }
]
```

```python
# Python app config
class Settings(BaseSettings):
    azure_client_id: str | None = None
    azure_openai_endpoint: str
    application_insights_connection_string: str
```

## Shared Subscription Considerations

- Use `uniqueString(subscription().id, environmentName, location)` for globally unique names (Key Vault, Storage, ACR, Cognitive Services)
- Include `environmentName` in resource group name for isolation
- Handle soft-delete conflicts (Key Vault 90-day, Cognitive Services 48-hour retention)
- Use quota-friendly defaults (basic SKUs, minimal CPU/memory)

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Missing `azd-env-name` tag | azd can't find resources → add to `tags` variable |
| Missing `azd-service-name` tag | `azd deploy` fails → add `union(tags, {'azd-service-name': '...'})` |
| Missing IMAGE_NAME/EXISTS params | Re-provision overwrites deployed image → add both params |
| `principalId` empty in CI | RBAC creation fails → guard with `if (!empty(principalId))` |
| Hardcoded location | Use `resourceGroup().location` or parameter |
| No `AZURE_CLIENT_ID` env var | Managed identity auth fails at runtime |
