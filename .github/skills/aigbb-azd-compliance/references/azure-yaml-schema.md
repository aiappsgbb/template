# azure.yaml Complete Schema Reference

## Table of Contents

1. [Root Properties](#root-properties)
2. [Services Configuration](#services-configuration)
3. [Infrastructure Configuration](#infrastructure-configuration)
4. [Hooks Configuration](#hooks-configuration)
5. [Complete Example](#complete-example)

---

## Root Properties

```yaml
# Required: Project name (used for resource naming)
name: my-project

# Optional: Template metadata
metadata:
  template: my-project@1.0.0

# Optional: Workflow customization
workflow:
  interactivity: "none"  # Skip interactive prompts (requires env vars pre-set)

# Optional: Default Azure settings
azure:
  location: eastus2
```

---

## Services Configuration

### Minimal Service

```yaml
services:
  api:
    project: ./src/api        # Path to service code (must exist on disk)
    language: python           # python, ts, js, csharp, java, go
    host: containerapp         # containerapp, appservice, function, staticwebapp
```

### Full Service Options

```yaml
services:
  api:
    # Required
    project: ./src/api
    language: python
    host: containerapp

    # Docker configuration (for containerapp/appservice)
    docker:
      path: ./Dockerfile       # Relative to project path
      context: .               # Build context relative to project
      remoteBuild: true        # Build in Azure (ALWAYS recommended)

    # Resource configuration
    resourceName: my-api-app   # Override auto-generated name

    # Service-specific hooks
    hooks:
      prepackage:
        shell: sh
        run: echo "Before packaging..."
      postdeploy:
        shell: sh
        run: echo "After deploying..."
```

### Service Languages

| Language | Value | Package Manager |
|----------|-------|-----------------|
| Python | `python` | requirements.txt or pyproject.toml |
| TypeScript | `ts` | package.json |
| JavaScript | `js` | package.json |
| C# | `csharp` | .csproj |
| Java | `java` | pom.xml or build.gradle |
| Go | `go` | go.mod |

### Service Hosts

| Host | Value | Required Bicep Resource | azd Tag |
|------|-------|------------------------|---------|
| Container Apps | `containerapp` | `Microsoft.App/containerApps` | `azd-service-name` |
| App Service | `appservice` | `Microsoft.Web/sites` | `azd-service-name` |
| Functions | `function` | `Microsoft.Web/sites` (kind: functionapp) | `azd-service-name` |
| Static Web Apps | `staticwebapp` | `Microsoft.Web/staticSites` | `azd-service-name` |
| AKS | `aks` | `Microsoft.ContainerService/managedClusters` | `azd-service-name` |

---

## Infrastructure Configuration

### Bicep Provider

```yaml
infra:
  provider: bicep
  path: ./infra              # Must exist as a directory
  module: main               # Optional: main module name (default: main)
```

### Terraform Provider

```yaml
infra:
  provider: terraform
  path: ./infra
```

---

## Hooks Configuration

### Available Hook Points

| Hook | Timing | Common Use Case |
|------|--------|-----------------|
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
    shell: sh                # sh, bash, pwsh, powershell
    run: |                   # Inline script OR path to script file
      echo "Running post-provision..."
      az role assignment create ... 2>/dev/null || true
    continueOnError: false   # Non-zero exit stops deployment (default)
    interactive: false
    cwd: ./scripts           # Working directory
```

### Hook Environment Variables

Available in all hooks:

```bash
${AZURE_ENV_NAME}              # Current environment name
${AZURE_LOCATION}              # Deployment location
${AZURE_SUBSCRIPTION_ID}       # Subscription ID
${AZURE_RESOURCE_GROUP}        # Resource group name
${SERVICE_<NAME>_URI}          # Service URL (e.g., SERVICE_API_URI)
${SERVICE_<NAME>_IMAGE_NAME}   # Full image path
# Any Bicep output becomes an env var automatically
```

### Critical Hook Rules

1. **Non-zero exit = deployment stops** unless `continueOnError: true`
2. **Use `|| true`** for idempotent operations (RBAC, DNS):
   ```bash
   az role assignment create ... 2>/dev/null || true
   ```
3. **Undeclared hooks don't run** — files in `infra/scripts/` must be declared in azure.yaml
4. **Required tools must be installed** — `uv`, `python`, `node`, etc.

---

## Complete Example

```yaml
name: my-azd-project
metadata:
  template: my-azd-project@1.0.0

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
    run: |
      echo ""
      echo "=========================================="
      echo "         Deployment Complete!            "
      echo "=========================================="
      echo "Web: ${SERVICE_WEB_URI}"
      echo "API: ${SERVICE_API_URI}"
      echo "Health: ${SERVICE_API_URI}/api/health"
```

---

## Environment-Specific Configuration

### Using Multiple Environments

```bash
azd env new dev
azd env new staging
azd env new prod

# Set environment-specific values
azd env select dev
azd env set AZURE_OPENAI_ENDPOINT "https://dev-openai.openai.azure.com"

azd env select prod
azd env set AZURE_OPENAI_ENDPOINT "https://prod-openai.openai.azure.com"

# Deploy specific environment
azd env select prod
azd up
```

### Environment File Structure

```
.azure/
├── config.json              # {"defaultEnvironment": "prod"}
├── dev/
│   ├── .env                 # Auto-generated from Bicep outputs
│   └── config.json          # Environment metadata
├── staging/
│   ├── .env
│   └── config.json
└── prod/
    ├── .env
    └── config.json
```

**Never manually edit `.azure/<env>/.env`** — use `azd env set`.
