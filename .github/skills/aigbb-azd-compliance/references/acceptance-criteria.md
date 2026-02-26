# Azure Developer CLI (azd) Compliance Acceptance Criteria

**Skill**: `azd-compliance`
**Purpose**: Validate and deploy containerized applications to Azure Container Apps with compliance-first patterns
**Focus**: azure.yaml, Bicep parameter sync, IMAGE_NAME/RESOURCE_EXISTS, service tags, hooks, shared subscription safety

---

## 1. azure.yaml Configuration

### 1.1 ✅ CORRECT: Minimal Service with Remote Build

```yaml
name: my-app
services:
  api:
    project: ./src/api
    language: python
    host: containerapp
    docker:
      path: ./Dockerfile
      remoteBuild: true
```

### 1.2 ✅ CORRECT: Full Configuration with Hooks

```yaml
name: my-app
metadata:
  template: my-project@1.0.0

infra:
  provider: bicep
  path: ./infra

services:
  web:
    project: ./src/web
    language: ts
    host: containerapp
    docker:
      path: ./Dockerfile
      context: .
      remoteBuild: true

  api:
    project: ./src/api
    language: python
    host: containerapp
    docker:
      path: ./Dockerfile
      context: .
      remoteBuild: true

hooks:
  preprovision:
    shell: sh
    run: python infra/scripts/preprovision.py
  postprovision:
    shell: sh
    run: python infra/scripts/postprovision.py
  postdeploy:
    shell: sh
    run: |
      echo "API: ${SERVICE_API_URI}"
```

### 1.3 ❌ INCORRECT: Missing remoteBuild

```yaml
# WRONG — local builds fail on ARM Macs, in CI/CD, and require Docker Desktop
docker:
  path: ./Dockerfile
  remoteBuild: false   # Should be true
```

### 1.4 ❌ INCORRECT: Missing name field

```yaml
# WRONG — azd refuses to run without top-level name
services:
  api:
    project: ./src/api
```

### 1.5 ❌ INCORRECT: Non-existent project path

```yaml
# WRONG — azd deploy can't find source code
services:
  api:
    project: ./src/backend   # Directory doesn't exist
```

---

## 2. Parameter Sync

### 2.1 ✅ CORRECT: All Required Parameters Mapped

main.bicep:
```bicep
param environmentName string      // No default — MUST be in parameters.json
param location string             // No default — MUST be in parameters.json
param principalId string = ''     // Has default — optional in parameters.json
```

main.parameters.json:
```json
{
  "parameters": {
    "environmentName": { "value": "${AZURE_ENV_NAME}" },
    "location": { "value": "${AZURE_LOCATION}" },
    "principalId": { "value": "${AZURE_PRINCIPAL_ID}" }
  }
}
```

### 2.2 ❌ INCORRECT: Missing Required Parameter

main.bicep:
```bicep
param environmentName string
param location string
param myCustomParam string   // No default — MISSING from parameters.json
```

main.parameters.json:
```json
{
  "parameters": {
    "environmentName": { "value": "${AZURE_ENV_NAME}" },
    "location": { "value": "${AZURE_LOCATION}" }
    // ❌ myCustomParam missing — azd provision will fail
  }
}
```

---

## 3. IMAGE_NAME / RESOURCE_EXISTS Pattern

### 3.1 ✅ CORRECT: Both Variables Mapped Per Service

For service `api` in azure.yaml:

main.parameters.json:
```json
{
  "parameters": {
    "apiImageName": { "value": "${SERVICE_API_IMAGE_NAME=}" },
    "apiExists": { "value": "${SERVICE_API_RESOURCE_EXISTS=false}" }
  }
}
```

main.bicep:
```bicep
param apiImageName string = ''
param apiExists bool = false

module api 'br/public:avm/res/app/container-app:0.18.1' = {
  params: {
    containers: [
      {
        name: 'main'
        image: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
      }
    ]
  }
}
```

### 3.2 ❌ INCORRECT: Missing IMAGE_NAME

```json
{
  "parameters": {
    // ❌ Missing apiImageName — re-provision overwrites deployed image
    "apiExists": { "value": "${SERVICE_API_RESOURCE_EXISTS=false}" }
  }
}
```

### 3.3 ❌ INCORRECT: Missing Empty-Check Guard

```bicep
// WRONG — deploys blank image when apiImageName is empty
containers: [
  {
    name: 'main'
    image: apiImageName    // Should use !empty() guard
  }
]
```

### 3.4 ❌ INCORRECT: Missing Default Suffix

```json
{
  "parameters": {
    // WRONG — no '=' means first deploy fails when var isn't set
    "apiImageName": { "value": "${SERVICE_API_IMAGE_NAME}" }
  }
}
```

Correct: `${SERVICE_API_IMAGE_NAME=}` (with `=` for empty default)

---

## 4. Service Tags

### 4.1 ✅ CORRECT: azd-env-name on Tags Variable

```bicep
var tags = {
  'azd-env-name': environmentName
}
```

### 4.2 ✅ CORRECT: azd-service-name Matching azure.yaml

```bicep
// azure.yaml has: services.api
tags: union(tags, { 'azd-service-name': 'api' })
```

### 4.3 ❌ INCORRECT: Missing azd-service-name

```bicep
// WRONG — azd can't find this Container App
tags: {
  'environment': 'production'
}
```

### 4.4 ❌ INCORRECT: Tag Mismatch

```bicep
// WRONG — azure.yaml has 'api' but tag says 'backend'
tags: union(tags, { 'azd-service-name': 'backend' })
```

---

## 5. Bicep Outputs

### 5.1 ✅ CORRECT: Service Discovery Outputs

```bicep
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
```

### 5.2 ❌ INCORRECT: Missing Service Outputs

```bicep
// WRONG — azd can't determine service endpoint
// No SERVICE_API_ENDPOINT_URL or SERVICE_API_NAME output
```

---

## 6. RBAC

### 6.1 ✅ CORRECT: Guarded with principalId Check

```bicep
resource rbac '...' = if (!empty(principalId)) {
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

### 6.2 ✅ CORRECT: Hook Error Suppression

```yaml
run: |
  az role assignment create ... 2>/dev/null || true
```

### 6.3 ❌ INCORRECT: Unguarded RBAC

```bicep
// WRONG — fails when principalId is empty (CI/CD)
resource rbac '...' = {
  properties: {
    principalId: principalId   // Empty string → failure
  }
}
```

---

## 7. Hook Scripts

### 7.1 ✅ CORRECT: All Scripts Declared

```yaml
hooks:
  preprovision:
    shell: sh
    run: python infra/scripts/preprovision.py
  postprovision:
    shell: sh
    run: python infra/scripts/postprovision.py
```

Files exist: `infra/scripts/preprovision.py`, `infra/scripts/postprovision.py`

### 7.2 ❌ INCORRECT: Undeclared Hook Scripts

Files exist in `infra/scripts/`: `preprovision.py`, `postprovision.py`
But azure.yaml has no `hooks:` section → scripts never execute.

---

## 8. Shared Subscription Safety

### 8.1 ✅ CORRECT: Unique Resource Names

```bicep
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
name: '${abbrs.keyVaultVaults}${resourceToken}'
```

### 8.2 ❌ INCORRECT: Static Resource Names

```bicep
// WRONG — collides in shared subscriptions
name: 'kv-myapp'
```

### 8.3 ✅ CORRECT: Environment-Isolated Resource Group

```bicep
name: '${abbrs.resourcesResourceGroups}${environmentName}'
```

### 8.4 ❌ INCORRECT: Shared Resource Group

```bicep
// WRONG — all developers share the same resource group
name: 'rg-myapp'
```

---

## 9. Container Apps Configuration

### 9.1 ✅ CORRECT: Managed Identity for ACR Pull

```bicep
registries: [
  {
    server: containerRegistry.properties.loginServer
    identity: 'system'
  }
]
```

### 9.2 ❌ INCORRECT: Admin Credentials for ACR

```bicep
// WRONG — security risk
registries: [
  {
    server: registryServer
    username: registryUsername
    passwordSecretRef: 'acr-password'
  }
]
```

### 9.3 ✅ CORRECT: Internal Service Communication

```bicep
{ name: 'BACKEND_URL', value: 'http://ca-api-${token}' }  // HTTP
```

### 9.4 ❌ INCORRECT: External URL for Internal Communication

```bicep
// WRONG — unnecessary network hops, TLS overhead
{ name: 'BACKEND_URL', value: 'https://ca-api.azurecontainerapps.io' }
```

---

## 10. Compliance Checklist

- [ ] `azure.yaml` has `name` field
- [ ] `azure.yaml` has `remoteBuild: true` for all containerapp services
- [ ] `infra.path` directory exists
- [ ] All service `project` paths exist
- [ ] Every main.bicep param without default is in main.parameters.json
- [ ] IMAGE_NAME and RESOURCE_EXISTS mapped per containerapp service
- [ ] Image params have `!empty()` guard
- [ ] `azd-env-name` tag on resource group tags
- [ ] `azd-service-name` tag on each service resource (matching azure.yaml key)
- [ ] `SERVICE_<NAME>_ENDPOINT_URL` and `SERVICE_<NAME>_NAME` outputs exist
- [ ] RBAC guarded with `if (!empty(principalId))`
- [ ] Hook scripts declared in azure.yaml and files exist
- [ ] Hooks use `|| true` for idempotent operations
- [ ] Managed identity for ACR pull (not admin credentials)
- [ ] Internal services use `http://` not `https://`
- [ ] Globally unique resources use `resourceToken`/`uniqueString()`
- [ ] Resource group name includes `environmentName`
- [ ] `AZURE_CLIENT_ID` env var set in containers
