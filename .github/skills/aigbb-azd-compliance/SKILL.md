---
name: aigbb-azd-compliance
description: "Validate and deploy Azure Developer CLI (azd) projects with compliance-first patterns. Covers azure.yaml configuration, Bicep parameter sync, Container Apps image preservation (IMAGE_NAME/RESOURCE_EXISTS), service-to-resource binding, azd tags, hook scripts, shared subscription safety, and pre-flight validation. Use when setting up azd projects, writing azure.yaml, validating Bicep infrastructure for Container Apps, troubleshooting azd up failures, running compliance checks, or preparing for deployment. Triggers on azd, azure.yaml, azd compliance, azd deploy, azd provision, azd up, Container Apps deployment, IMAGE_NAME, RESOURCE_EXISTS, remoteBuild, azd tags, parameter mismatch, pre-flight check, deployment validation."
---

# Azure Developer CLI (azd) Compliance & Deployment

Deploy containerized applications to Azure Container Apps with full compliance validation. This skill combines deployment patterns with the checks needed to prevent `azd provision` and `azd deploy` failures.

**Philosophy**: Only flag issues that will cause failures or runtime problems. Skip style preferences.

---

## Quick Start

```bash
azd auth login          # Authenticate
azd init                # Creates azure.yaml and .azure/ folder
azd env new <env-name>  # Create environment (dev, staging, prod)
azd up                  # Provision infra + build + deploy
```

---

## 1. azure.yaml Configuration

### Minimal Configuration

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

### Full Configuration with Hooks

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

  predeploy:
    shell: sh
    run: python infra/scripts/predeploy.py

  postdeploy:
    shell: sh
    run: python infra/scripts/postdeploy.py
```

### Critical azure.yaml Rules

| Check | Why It Matters |
|-------|----------------|
| `name` field exists | azd refuses to run without it |
| `infra.path` points to existing directory | `azd provision` fails immediately |
| Service `project` paths exist | `azd deploy` can't find source code |
| Service `host` matches infrastructure | Deploys to wrong/nonexistent resource |
| `remoteBuild: true` on all containerapp services | Local builds fail on ARM Macs, in CI/CD, and require Docker Desktop |

### Service Hosts

| azure.yaml `host` | Required Bicep Resource |
|-------------------|------------------------|
| `containerapp` | Container App with matching name pattern |
| `function` | Function App |
| `appservice` | App Service |
| `staticwebapp` | Static Web App |

### Service Languages

| Language | Value | Package Manager |
|----------|-------|-----------------|
| Python | `python` | requirements.txt or pyproject.toml |
| TypeScript | `ts` | package.json |
| JavaScript | `js` | package.json |
| C# | `csharp` | .csproj |
| Java | `java` | pom.xml or build.gradle |
| Go | `go` | go.mod |

---

## 2. Parameter Sync (Most Common Failure)

Every parameter in `main.bicep` that lacks a default **MUST** have a mapping in `main.parameters.json`.

### main.bicep Parameters

```bicep
// These MUST be in main.parameters.json (no default)
param environmentName string
param location string

// These are OPTIONAL in main.parameters.json (have defaults)
param principalId string = ''
param apiImageName string = ''
param apiExists bool = false
```

### main.parameters.json

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

### Parameter Injection Syntax

| Syntax | Meaning |
|--------|---------|
| `${AZURE_ENV_NAME}` | Required — azd auto-populates |
| `${AZURE_LOCATION}` | Required — azd auto-populates |
| `${MY_VAR}` | Must be set via `azd env set MY_VAR "value"` |
| `${MY_VAR=default}` | Uses `default` if not set |
| `${SERVICE_API_IMAGE_NAME=}` | Empty string default (for first deploy) |
| `${SERVICE_API_RESOURCE_EXISTS=false}` | Boolean default (for first deploy) |

### Validation

```powershell
# List parameters without defaults in main.bicep
Select-String -Path infra/main.bicep -Pattern "^param\s+\w+\s+\w+$" | 
  Where-Object { $_ -notmatch "=" }

# List parameters in main.parameters.json
(Get-Content infra/main.parameters.json | ConvertFrom-Json).parameters.PSObject.Properties.Name

# Compare — every param without a default must appear in parameters.json
```

---

## 3. Container Image Preservation (IMAGE_NAME / RESOURCE_EXISTS)

For each service with `host: containerapp` in azure.yaml, azd manages two variables to prevent re-provision from overwriting the deployed container image.

**Reference**: [Deploy to Azure Container Apps using azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/container-apps-workflows)

### Required Variables Per Service

For a service named `api` in azure.yaml:

| Variable | Set By | Purpose |
|----------|--------|---------|
| `SERVICE_API_IMAGE_NAME` | `azd deploy` | Currently deployed image tag |
| `SERVICE_API_RESOURCE_EXISTS` | `azd provision` | Whether Container App already exists |

**Pattern**: `SERVICE_<UPPER_CASE_SERVICE_NAME>_IMAGE_NAME` and `SERVICE_<UPPER_CASE_SERVICE_NAME>_RESOURCE_EXISTS`

### Check 1: main.parameters.json Must Map Both

```json
{
  "parameters": {
    "apiImageName": {
      "value": "${SERVICE_API_IMAGE_NAME=}"
    },
    "apiExists": {
      "value": "${SERVICE_API_RESOURCE_EXISTS=false}"
    }
  }
}
```

The `=` after the variable name provides a default (empty string or `false`) for first-time deployments.

### Check 2: Bicep Must Declare and Use Both

```bicep
@description('Container image name for the api service')
param apiImageName string = ''

@description('Whether the api Container App already exists')
param apiExists bool = false

module api 'core/host/container-app.bicep' = {
  name: 'api'
  params: {
    containerImage: !empty(apiImageName) ? apiImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    // pass exists to module for upsert behavior
  }
}
```

### Check 3: AVM container-app-upsert (Recommended)

Prefer the AVM [`container-app-upsert`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/azd/container-app-upsert) module which encapsulates the upsert logic:

```bicep
module api 'br/public:avm/ptn/azd/container-app-upsert:<version>' = {
  params: {
    imageName: !empty(apiImageName) ? apiImageName : ''
    exists: apiExists
    // ...
  }
}
```

### What Breaks Without This

| Scenario | Without IMAGE_NAME / RESOURCE_EXISTS | With both variables |
|----------|--------------------------------------|---------------------|
| First `azd provision` | ✅ Works (uses default placeholder) | ✅ Works |
| `azd deploy` | ✅ Pushes new image | ✅ Pushes new image |
| Re-run `azd provision` | ❌ **Overwrites deployed image** with placeholder, app breaks | ✅ Preserves current image |
| `azd up` (provision + deploy) | ⚠️ Temporary downtime between provision and deploy | ✅ Image preserved during provision phase |

### Validation Command

```powershell
# Verify both variables exist for each containerapp service
Select-String -Path infra/main.parameters.json -Pattern 'SERVICE_.*_IMAGE_NAME|SERVICE_.*_RESOURCE_EXISTS'
```

---

## 4. Service-to-Resource Binding & Tags

azd uses tags to discover deployed resources. Without them, `azd deploy` and `azd down` can't find your resources.

### Required: Resource Group Tag

```bicep
var tags = {
  'azd-env-name': environmentName  // REQUIRED — azd uses this to find resources
}
```

### Required: Service Resource Tags

For each service in azure.yaml, the corresponding Bicep resource **must** include `azd-service-name`:

```bicep
tags: union(tags, {
  'azd-service-name': 'api'  // MUST match service key in azure.yaml
})
```

### Tag-to-Service Mapping

| azure.yaml | Bicep tag required |
|------------|-------------------|
| `services.api:` | `'azd-service-name': 'api'` |
| `services.web:` | `'azd-service-name': 'web'` |
| `services.frontend:` | `'azd-service-name': 'frontend'` |
| `services.backend:` | `'azd-service-name': 'backend'` |

**Why it matters**: Without these tags, azd can't find deployed resources for `azd deploy` or `azd down`.

---

## 5. Bicep Output Naming Convention

azd needs outputs to know where services deployed and to auto-populate `.azure/<env>/.env`.

### Per-Service Outputs (Required)

```bicep
// Pattern: SERVICE_<SERVICE_NAME>_<PROPERTY>
output SERVICE_API_ENDPOINT_URL string = api.outputs.fqdn
output SERVICE_API_NAME string = api.outputs.name
output SERVICE_WEB_ENDPOINT_URL string = web.outputs.fqdn
output SERVICE_WEB_NAME string = web.outputs.name
```

### Infrastructure Outputs (Common)

```bicep
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = resourceGroup().name
output AZURE_CLIENT_ID string = userAssignedIdentity.outputs.clientId
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
```

All Bicep outputs automatically become azd environment variables in `.azure/<env>/.env`.

---

## 6. Hook Scripts

### Available Hook Points

| Hook | Timing | Use Case |
|------|--------|----------|
| `prerestore` | Before package restore | Pre-install setup |
| `postrestore` | After package restore | Post-install setup |
| `preprovision` | Before infra deployment | Save existing state, validation |
| `postprovision` | After infra deployment | RBAC, DNS, configuration |
| `prepackage` | Before app packaging | Build steps |
| `postpackage` | After app packaging | Verification |
| `predeploy` | Before app deployment | Pre-deploy checks |
| `postdeploy` | After app deployment | Smoke tests, notifications |
| `predown` | Before resource deletion | Backup, confirmation |
| `postdown` | After resource deletion | Cleanup |

### Hook Properties

```yaml
hooks:
  postprovision:
    shell: sh               # sh, bash, pwsh, powershell
    run: |                   # Inline script OR path to script
      echo "Running post-provision..."
    continueOnError: false   # Non-zero exit stops deployment
    interactive: false
    cwd: ./scripts           # Working directory
```

### Critical Hook Rules

1. **Non-zero exit = deployment stops** — Always handle errors:
   ```yaml
   run: |
     az role assignment create ... 2>/dev/null || true
   ```

2. **Undeclared hooks don't run** — Scripts in `infra/scripts/` must be declared in azure.yaml:
   ```powershell
   # Check for undeclared hook scripts
   Get-ChildItem infra/scripts/ -Filter "*.py" | 
     Where-Object { $_.BaseName -match "pre|post" }
   ```

3. **Required tools must be available** — If hooks use `uv`, `python`, `node`, etc., they must be installed.

### Hook Environment Variables

Available in all hooks after provision:

```bash
${AZURE_ENV_NAME}              # Current environment name
${AZURE_LOCATION}              # Deployment location
${AZURE_SUBSCRIPTION_ID}       # Subscription ID
${AZURE_RESOURCE_GROUP}        # Resource group name
${SERVICE_<NAME>_URI}          # Service URL (e.g., SERVICE_API_URI)
${SERVICE_<NAME>_IMAGE_NAME}   # Full image path
# Any Bicep output becomes an env var
```

---

## 7. Container Apps Build Configuration

### Always Use Remote Build

```yaml
services:
  api:
    host: containerapp
    docker:
      path: ./Dockerfile
      context: .
      remoteBuild: true  # ✅ Builds in ACR, no local Docker needed
```

**Why**:
- Local builds require Docker Desktop running
- Local builds fail on ARM Macs deploying to AMD64
- Local builds fail in CI/CD without proper Docker setup
- Remote builds are more reliable and portable

### ACR Integration

For `host: containerapp` with `docker.remoteBuild: true`:
- Bicep must output `AZURE_CONTAINER_REGISTRY_ENDPOINT` or similar
- Container App must reference the correct registry
- ACR must have the managed identity or admin access configured

---

## 8. main.bicep Organization (7 Sections)

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

// Per-service image + exists params
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

---

## 9. RBAC Assignments

Always guard with `if (!empty(principalId))` to prevent failures when `principalId` is empty (CI/CD):

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

---

## 10. Shared Subscription Considerations

### Resource Naming Collisions

In shared subscriptions, globally unique names cause conflicts:

| Resource | Uniqueness | Fix |
|----------|------------|-----|
| Key Vault | Global | Include `resourceToken` (uniqueString) |
| Storage Account | Global | Include `resourceToken`, max 24 chars |
| Container Registry | Global | Include `resourceToken` |
| Cognitive Services | Global | Include `resourceToken` |

```bicep
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
```

### Soft-Delete Conflicts

Redeploying fails if a soft-deleted resource with same name exists:

| Resource | Retention | Mitigation |
|----------|-----------|------------|
| Key Vault | 90 days | Use unique names OR purge in preprovision hook |
| Cognitive Services | 48 hours | Use unique names OR purge in preprovision hook |
| API Management | Soft-deleted blocks new | Use unique names |

### Environment Isolation

Each developer's environment must be isolated:

```bicep
// Good: Environment name in resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'  // ✅ Includes env name
}
```

### Quota-Friendly Defaults

Shared subscriptions often hit quota limits:

| Resource | Watch For |
|----------|-----------|
| Container Apps | CPU/memory requests |
| Cognitive Services | SKU tier (use S0 not S1+ unless needed) |
| AI Search | SKU (basic vs standard) |
| VMs/VMSS | Core counts |

---

## 11. Environment Variables Flow

### Three-Level Configuration

1. **Local `.env`** — For local development only
2. **`.azure/<env>/.env`** — azd-managed, auto-populated from Bicep outputs
3. **`main.parameters.json`** — Maps azd env vars to Bicep parameters

### Setting Environment Variables

```bash
azd env set AZURE_OPENAI_ENDPOINT "https://my-openai.openai.azure.com"
azd env get-values   # Show all env vars for current environment
```

**Never manually edit `.azure/<env>/.env`** — use `azd env set`.

### Bicep Env Var Alignment

Container Apps env vars **must match** the application's configuration class:

```bicep
// Bicep
environmentVariables: [
  { name: 'AZURE_CLIENT_ID', value: identity.outputs.clientId }
  { name: 'AZURE_OPENAI_ENDPOINT', value: openAi.outputs.endpoint }
]
```

```python
# Python app (Pydantic BaseSettings)
class Settings(BaseSettings):
    azure_client_id: str | None = None
    azure_openai_endpoint: str
```

---

## 12. Container App Module Template

```bicep
// infra/core/host/container-app.bicep
@description('Container App name')
@minLength(1)
param name string

@description('Location')
param location string = resourceGroup().location

@description('Resource tags')
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
          identity: 'system' // Use managed identity, not admin credentials
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
        minReplicas: 1
        maxReplicas: 3
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

## 13. Internal Service Discovery

Container Apps in the same environment communicate via internal HTTP DNS:

```bicep
// Backend reference in frontend env vars
env: [
  {
    name: 'BACKEND_URL'
    value: 'http://ca-backend-${resourceToken}'  // Internal DNS — HTTP, not HTTPS
  }
]
```

**Always use `http://` (not `https://`)** for internal service-to-service communication within a Container Apps environment.

---

## 14. Common Commands

```bash
# Environment management
azd env list                        # List environments
azd env select <name>               # Switch environment
azd env get-values                  # Show all env vars
azd env set KEY value               # Set variable

# Deployment
azd up                              # Full provision + deploy
azd provision                       # Infrastructure only
azd deploy                          # Code deployment only
azd deploy --service api            # Deploy single service

# Validation
azd config list                     # Should not error
azd auth login --check-status       # Verify authentication

# Debugging
azd show                            # Show project status
azd up --debug                      # Verbose output
az containerapp logs show -n <app> -g <rg> --follow  # Stream logs
```

---

## 15. Pre-Flight Checklist

Run these before `azd up`:

```powershell
# 1. Verify azd can parse the project
azd config list

# 2. Check authentication
azd auth login --check-status

# 3. Verify environment is set
azd env list

# 4. Validate Bicep compiles (catches syntax errors)
az bicep build --file infra/main.bicep --stdout | Out-Null

# 5. What-if deployment (catches parameter/resource issues)
azd provision --preview
```

If all pass, `azd up` should succeed.

---

## 16. Anti-Patterns Summary

| Anti-Pattern | Impact | Fix |
|--------------|--------|-----|
| Missing `remoteBuild: true` | Build fails on ARM Macs / CI | Add `remoteBuild: true` to docker config |
| Missing `azd-env-name` tag | azd can't find resource group | Add to `tags` variable |
| Missing `azd-service-name` tag | `azd deploy` can't find resources | Add `union(tags, {'azd-service-name': '...'})` |
| Missing IMAGE_NAME/EXISTS params | Re-provision overwrites deployed image | Add both params per service |
| Parameter without default, missing from parameters.json | `azd provision` fails | Add mapping to parameters.json |
| Hardcoded secrets in Bicep | Security vulnerability | Use `azd env set` + Key Vault |
| Manual `.azure/.env` edits | Values overwritten by azd | Use `azd env set` |
| Missing `\|\| true` in hooks | RBAC "already exists" fails deployment | Add error suppression |
| External URLs for internal services | Unnecessary network hops, TLS overhead | Use internal `http://` DNS |
| ACR admin credentials | Security risk | Use managed identity |
| Empty `principalId` in RBAC | Role assignment fails in CI | Guard with `if (!empty(principalId))` |
| Undeclared hook scripts | Scripts exist but never run | Declare in azure.yaml `hooks:` |
| No `AZURE_CLIENT_ID` env var | Managed identity auth fails at runtime | Output from Bicep |

---

## Reference Files

- **Bicep patterns**: See [references/bicep-patterns.md](references/bicep-patterns.md) for Container Apps modules
- **Troubleshooting**: See [references/troubleshooting.md](references/troubleshooting.md) for common issues
- **azure.yaml schema**: See [references/azure-yaml-schema.md](references/azure-yaml-schema.md) for full options
- **Compliance checklist**: See [references/compliance-checklist.md](references/compliance-checklist.md) for validation steps
- **Acceptance criteria**: See [references/acceptance-criteria.md](references/acceptance-criteria.md) for correct/incorrect examples

## External References

- [azd schema reference](https://learn.microsoft.com/azure/developer/azure-developer-cli/azd-schema)
- [Container Apps deployment strategies](https://learn.microsoft.com/azure/developer/azure-developer-cli/container-apps-workflows) (IMAGE_NAME / RESOURCE_EXISTS patterns)
- [AVM container-app-upsert module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/azd/container-app-upsert) (recommended upsert pattern)
