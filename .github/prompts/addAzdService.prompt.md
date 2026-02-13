---
agent: 'agent'
model:
  - Claude Opus 4.6 (copilot)
  - Claude Sonnet 4 (copilot)
tools: ['githubRepo', 'search/codebase', 'edit', 'changes', 'runCommands', 'mcp']
description: 'Add a new service to azure.yaml configuration'
---

# Add Service to Azure Developer CLI Configuration

Add a new service to the `azure.yaml` file for deployment with Azure Developer CLI.

**Skills to use**: Load the `azd-deployment` and `bicep-azd-patterns` skills for azure.yaml schema, Bicep patterns, and IMAGE_NAME/RESOURCE_EXISTS conventions.

**Security**: Follow [azure-bestpractices.md](../azure-bestpractices.md) — NEVER include API keys in environment variables.

## Service Configuration

Update the root `azure.yaml` to include a new service entry:

### Standard Service Entry

```yaml
services:
  <service-name>:
    project: "./src/<service-directory>"
    language: <python|js|dotnet>
    host: containerapp
    docker:
      remoteBuild: true  # ← Always prefer remote builds
```

### Language-Specific Examples

#### Python (FastAPI, Gradio, Streamlit)
```yaml
services:
  my-python-app:
    project: "./src/my-python-app"
    language: python
    host: containerapp
    docker:
      remoteBuild: true
```

#### Node.js/TypeScript
```yaml
services:
  my-node-app:
    project: "./src/my-node-app"
    language: js
    host: containerapp
    docker:
      remoteBuild: true
```

#### .NET
```yaml
services:
  my-dotnet-app:
    project: "./src/my-dotnet-app"
    language: dotnet
    host: containerapp
    docker:
      remoteBuild: true
```

## Required Bicep Changes

For each new service, update `infra/main.bicep` and `infra/main.parameters.json`:

### 1. Add Container Image Parameters (main.bicep)

```bicep
@description('Container image for the <service-name> service')
param <serviceName>ImageName string = ''

@description('Whether the <service-name> Container App already exists')
param <serviceName>Exists bool = false
```

### 2. Add Parameter Mappings (main.parameters.json)

```json
"<serviceName>ImageName": {
  "value": "${SERVICE_<SERVICE_NAME_UPPER>_IMAGE_NAME=}"
},
"<serviceName>Exists": {
  "value": "${SERVICE_<SERVICE_NAME_UPPER>_RESOURCE_EXISTS=false}"
}
```

### 3. Add Container App Module (main.bicep)

```bicep
module <serviceName> 'core/host/container-app.bicep' = {
  name: '<service-name>'
  params: {
    name: '${abbrs.appContainerApps}<service-name>-${resourceToken}'
    tags: union(tags, { 'azd-service-name': '<service-name>' })
    containerImage: !empty(<serviceName>ImageName) ? <serviceName>ImageName : 'mcr.microsoft.com/k8se/quickstart:latest'
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    userAssignedIdentityId: userAssignedIdentity.outputs.id
    environmentVariables: [
      { name: 'AZURE_CLIENT_ID', value: userAssignedIdentity.outputs.clientId }
      { name: 'APPLICATION_INSIGHTS_CONNECTION_STRING', value: monitoring.outputs.applicationInsightsConnectionString }
      // Add service-specific endpoints (NEVER API keys)
    ]
  }
}
```

### 4. Add Outputs (main.bicep)

```bicep
output SERVICE_<SERVICE_NAME_UPPER>_ENDPOINT_URL string = <serviceName>.outputs.fqdn
output SERVICE_<SERVICE_NAME_UPPER>_NAME string = <serviceName>.outputs.name
```

## Environment Variables Policy

**✅ ALLOWED** — endpoints and connection strings:
- `AZURE_CLIENT_ID` (REQUIRED for managed identity)
- `AZURE_OPENAI_ENDPOINT`
- `AZURE_SEARCH_ENDPOINT`
- `AZURE_COSMOS_ENDPOINT`
- `AZURE_KEY_VAULT_ENDPOINT`
- `APPLICATION_INSIGHTS_CONNECTION_STRING`

**❌ FORBIDDEN** — API keys and secrets:
- `AZURE_OPENAI_API_KEY`
- `AZURE_AI_SEARCH_KEY`
- `AZURE_STORAGE_ACCOUNT_KEY`
- Any `*_KEY` or `*_SECRET` variables

## Validation Checklist

After adding the service:

- [ ] `azure.yaml` has correct `project` path, `language`, `host: containerapp`, `docker.remoteBuild: true`
- [ ] `main.parameters.json` has `SERVICE_<NAME>_IMAGE_NAME` and `SERVICE_<NAME>_RESOURCE_EXISTS` entries
- [ ] `main.bicep` has matching parameters, Container App module with `azd-service-name` tag, and outputs
- [ ] Container App module includes `AZURE_CLIENT_ID` environment variable
- [ ] No API keys in environment variables
- [ ] Run `az bicep build --file infra/main.bicep --stdout | Out-Null` to validate syntax