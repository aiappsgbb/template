# Azure Developer CLI (azd) Troubleshooting Guide

## Table of Contents

1. [Build Failures](#build-failures)
2. [Provision Failures](#provision-failures)
3. [Deployment Failures](#deployment-failures)
4. [Container App Runtime Issues](#container-app-runtime-issues)
5. [Environment Configuration](#environment-configuration)
6. [Networking Issues](#networking-issues)
7. [RBAC and Permissions](#rbac-and-permissions)
8. [Shared Subscription Issues](#shared-subscription-issues)
9. [Debug Commands](#debug-commands)

---

## Build Failures

### Remote Build Fails — "Cannot find Dockerfile"

**Symptom:**
```
Error: cannot find Dockerfile at ./Dockerfile
```

**Fix:** `docker.path` is relative to the service's `project` path:
```yaml
services:
  api:
    project: ./src/api
    docker:
      path: ./Dockerfile      # Relative to ./src/api, NOT project root
      context: .
```

### ARM64 Build on x86 Failure

**Symptom:**
```
exec format error
```

**Fix:** Use remote builds:
```yaml
docker:
  remoteBuild: true    # ALWAYS use — builds on Azure's AMD64 infrastructure
```

### ACR Push Fails — "Unauthorized"

**Symptom:**
```
denied: requested access to the resource is denied
```

**Fixes:**
1. Re-authenticate: `azd auth login`
2. Verify ACR managed identity or admin access is configured in Bicep
3. Check `AcrPull` role assignment exists

---

## Provision Failures

### Parameter Mismatch

**Symptom:**
```
Error: The following parameters do not have values: ...
```

**Fix:** Every main.bicep param without a default must be in main.parameters.json:
```json
{
  "parameters": {
    "environmentName": { "value": "${AZURE_ENV_NAME}" },
    "location": { "value": "${AZURE_LOCATION}" }
  }
}
```

### Bicep Compilation Error

**Symptom:**
```
Error BCP xxx: ...
```

**Fix:** Validate locally first:
```powershell
az bicep build --file infra/main.bicep --stdout | Out-Null
```

### Soft-Delete Conflict

**Symptom:**
```
Error: A vault with the same name already exists in deleted state
```

**Fixes:**
1. Purge the deleted resource:
   ```bash
   az keyvault purge --name <vault-name>
   ```
2. Or use unique names with `resourceToken`:
   ```bicep
   name: '${abbrs.keyVaultVaults}${resourceToken}'
   ```

### Resource Name Collision (Shared Subscription)

**Symptom:**
```
Error: The name '<resource>' is already in use
```

**Fix:** Use `uniqueString()` for globally unique resources:
```bicep
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
```

---

## Deployment Failures

### Service Not Found After Deploy

**Symptom:** `azd deploy` succeeds but service not updated

**Fix:** Ensure `azd-service-name` tag matches azure.yaml service key:
```bicep
tags: union(tags, { 'azd-service-name': 'api' })  // Must match azure.yaml key
```

### "Could not find container app for service"

**Symptom:**
```
Error: could not find container app for service 'api'
```

**Fixes:**
1. Verify `azd-service-name` tag exists on the Container App
2. Verify `azd-env-name` tag exists on the resource group
3. Run `azd provision` first, then `azd deploy`

### Image Overwritten On Re-Provision

**Symptom:** Running `azd provision` (or `azd up`) replaces the deployed image with a placeholder

**Fix:** Add IMAGE_NAME and RESOURCE_EXISTS variables (see SKILL.md §3):
```json
{
  "apiImageName": { "value": "${SERVICE_API_IMAGE_NAME=}" },
  "apiExists": { "value": "${SERVICE_API_RESOURCE_EXISTS=false}" }
}
```

### Hook Script Fails

**Symptom:**
```
Error: hook 'postprovision' failed with exit code 1
```

**Fixes:**
1. Add error handling:
   ```yaml
   run: |
     az role assignment create ... 2>/dev/null || true
   ```
2. Verify script file exists at declared path
3. Verify required tools (python, uv, etc.) are installed
4. Run hook commands manually to debug

---

## Container App Runtime Issues

### Container Keeps Restarting

**Diagnosis:**
```bash
az containerapp logs show -n <app> -g <rg> --type system
az containerapp logs show -n <app> -g <rg> --type console
```

**Common Causes:**

1. **Port mismatch** — Bicep `targetPort` must match Dockerfile EXPOSE and app listen port
2. **Missing environment variable** — App crashes on startup
3. **Health check failing** — Add a health endpoint:
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
     CMD curl -f http://localhost:8000/health || exit 1
   ```

### Custom Domain Lost After Redeploy

**Fix:** Set `customDomains` to `null` to preserve Portal-managed domains:
```bicep
ingress: {
  customDomains: empty(customDomainsParam) ? null : customDomainsParam
}
```

### Managed Identity Auth Fails

**Symptom:**
```
AuthenticationError: DefaultAzureCredential failed
```

**Fixes:**
1. Verify `AZURE_CLIENT_ID` env var is set in container
2. Verify managed identity is enabled on the Container App
3. Verify RBAC role assignments exist:
   ```bash
   az role assignment list --assignee <principal-id>
   ```

---

## Environment Configuration

### Variable Not Available in Container

**Diagnosis:**
```bash
azd env get-values  # What's in .azure/<env>/.env
az containerapp show -n <app> -g <rg> \
  --query "properties.template.containers[0].env"
```

**Fix chain:**
1. Set via `azd env set MY_VAR "value"`
2. Map in `main.parameters.json`: `"myVar": { "value": "${MY_VAR}" }`
3. Declare in main.bicep: `param myVar string = ''`
4. Pass to container: `{ name: 'MY_VAR', value: myVar }`

### Resetting an Environment

```bash
azd env delete <env-name>
azd env new <env-name>
```

---

## Networking Issues

### Frontend Can't Reach Backend (502/504)

**Fixes:**
1. Use internal HTTP, not HTTPS:
   ```bicep
   { name: 'BACKEND_URL', value: 'http://ca-api-${token}' }  // HTTP!
   ```
2. Verify both apps are in the same Container Apps Environment
3. Check nginx proxy config uses `$proxy_host`:
   ```nginx
   location /api {
       proxy_pass $BACKEND_URL;
       proxy_set_header Host $proxy_host;
   }
   ```

### CORS Errors

**Fix:** Set CORS in backend:
```bicep
{ name: 'CORS_ORIGINS', value: '*' }  // Or specific origins in production
```

---

## RBAC and Permissions

### Role Assignment "Already Exists"

**Fix:** Suppress in hooks:
```bash
az role assignment create ... 2>/dev/null || true
```

### Role Assignment Fails with Empty principalId

**Fix:** Guard in Bicep:
```bicep
resource rbac '...' = if (!empty(principalId)) {
  // ...
}
```

### Getting Resource IDs for RBAC

```bash
# Azure OpenAI
az cognitiveservices account list --query "[?name=='$NAME'].id" -o tsv

# Azure AI Search
az resource list --resource-type "Microsoft.Search/searchServices" \
  --query "[?name=='$NAME'].id" -o tsv
```

---

## Shared Subscription Issues

### Quota Exceeded

**Symptom:**
```
QuotaExceeded: The subscription has reached its limit of ...
```

**Fixes:**
1. Use smaller SKUs (basic instead of standard)
2. Reduce Container Apps CPU/memory
3. Delete unused environments: `azd down`
4. Request quota increase

### Multiple Developers Colliding

**Fix:** Each developer uses their own azd environment:
```bash
azd env new dev-alice
azd env new dev-bob
```

Bicep must include `environmentName` in resource group name for isolation.

---

## Debug Commands

```bash
# Project state
azd show
azd env get-values

# Verbose deployment
azd up --debug

# Container logs
az containerapp logs show -n <app> -g <rg> --follow
az containerapp logs show -n <app> -g <rg> --type system

# Revision status
az containerapp revision list -n <app> -g <rg> \
  --query "[].{name:name, active:active, traffic:trafficWeight}"

# Container App URL
az containerapp show -n <app> -g <rg> \
  --query "properties.configuration.ingress.fqdn"

# Validate Bicep
az bicep build --file infra/main.bicep --stdout | Out-Null

# What-if deployment
azd provision --preview
```
