# azd Compliance Checklist

Structured validation steps to catch issues that would break `azd provision` or `azd deploy`.

---

## 🔴 Critical Checks (Will Break azd)

### 1. azure.yaml Structure

| # | Check | Command / How to Verify | Blocks |
|---|-------|-------------------------|--------|
| 1.1 | `name` field exists | Open azure.yaml, verify top-level `name:` | `azd *` |
| 1.2 | `infra.path` points to existing directory | `Test-Path (Get-Content azure.yaml \| ConvertFrom-Yaml).infra.path` | `azd provision` |
| 1.3 | Service `project` paths exist | Check each service's `project:` path exists on disk | `azd deploy` |
| 1.4 | Service `host` matches infrastructure | `containerapp` → Container App in Bicep, etc. | `azd deploy` |

### 2. Parameter Mismatch

| # | Check | How to Verify |
|---|-------|---------------|
| 2.1 | Every param in main.bicep without a default has a mapping in main.parameters.json | Compare declarations to parameter file |
| 2.2 | `${AZURE_ENV_NAME}` maps to `environmentName` | Check parameters.json |
| 2.3 | `${AZURE_LOCATION}` maps to `location` | Check parameters.json |

```powershell
# Quick check: find params without defaults in main.bicep
Select-String -Path infra/main.bicep -Pattern "^param\s+\w+\s+\w+\s*$" |
  ForEach-Object { ($_ -split '\s+')[1] }

# Cross-reference with parameters.json
$params = (Get-Content infra/main.parameters.json | ConvertFrom-Json).parameters
$params.PSObject.Properties.Name
```

### 3. Service Tags

| # | Check | How to Verify |
|---|-------|---------------|
| 3.1 | Resource group has `azd-env-name` tag | Grep main.bicep for `azd-env-name` in tags variable |
| 3.2 | Each service resource has `azd-service-name` tag matching azure.yaml key | Grep Bicep modules for `azd-service-name` |

```powershell
# Verify azd-env-name tag exists
Select-String -Path infra/main.bicep -Pattern "azd-env-name"

# Verify azd-service-name tags match azure.yaml services
Select-String -Path infra/*.bicep -Pattern "azd-service-name" -Recurse
```

### 4. IMAGE_NAME / RESOURCE_EXISTS

For each containerapp service:

| # | Check | Pattern |
|---|-------|---------|
| 4.1 | `main.parameters.json` has `SERVICE_<NAME>_IMAGE_NAME` | `${SERVICE_API_IMAGE_NAME=}` |
| 4.2 | `main.parameters.json` has `SERVICE_<NAME>_RESOURCE_EXISTS` | `${SERVICE_API_RESOURCE_EXISTS=false}` |
| 4.3 | main.bicep declares corresponding params with defaults | `param apiImageName string = ''` and `param apiExists bool = false` |
| 4.4 | Image param has empty-check guard | `!empty(apiImageName) ? apiImageName : 'fallback'` |

```powershell
# Verify both variables exist for each containerapp service
Select-String -Path infra/main.parameters.json -Pattern 'SERVICE_.*_IMAGE_NAME|SERVICE_.*_RESOURCE_EXISTS'
```

---

## 🟡 Common Pitfalls (Runtime Failures)

### 5. Missing Bicep Outputs

| # | Check | Pattern |
|---|-------|---------|
| 5.1 | Each service has `SERVICE_<NAME>_ENDPOINT_URL` output | `output SERVICE_API_ENDPOINT_URL string = ...` |
| 5.2 | Each service has `SERVICE_<NAME>_NAME` output | `output SERVICE_API_NAME string = ...` |
| 5.3 | `AZURE_CONTAINER_REGISTRY_ENDPOINT` output exists | For containerapp services with remote build |

### 6. Hook Scripts

| # | Check | How to Verify |
|---|-------|---------------|
| 6.1 | Declared hook scripts exist at specified paths | Check file existence |
| 6.2 | Required tools available (uv, python, etc.) | Check PATH |
| 6.3 | Error handling present (`\|\| true` or proper exit codes) | Read hook scripts |
| 6.4 | All hook scripts in infra/scripts/ are declared | Compare files to azure.yaml hooks |

```powershell
# Check for undeclared hook scripts
Get-ChildItem infra/scripts/ -Filter "*.py" |
  Where-Object { $_.BaseName -match "pre|post" } |
  ForEach-Object { Write-Host "Found: $($_.Name) - is it in azure.yaml hooks?" }
```

### 7. Container Apps Configuration

| # | Check |
|---|-------|
| 7.1 | All containerapp services have `remoteBuild: true` |
| 7.2 | Port in Bicep matches Dockerfile EXPOSE and app listen port |
| 7.3 | Internal service URLs use `http://` not `https://` |
| 7.4 | `AZURE_CLIENT_ID` env var is set in container for managed identity |

### 8. RBAC

| # | Check |
|---|-------|
| 8.1 | All RBAC assignments guarded with `if (!empty(principalId))` |
| 8.2 | Hook RBAC commands use `\|\| true` to handle "already exists" |
| 8.3 | Specific roles used (not Contributor/Owner) |

---

## 🏢 Shared Subscription Checks

### 9. Resource Naming

| # | Check |
|---|-------|
| 9.1 | Key Vault, Storage, ACR, Cognitive Services use `uniqueString()` / `resourceToken` |
| 9.2 | Resource group name includes `environmentName` |
| 9.3 | Storage account names ≤ 24 characters |

### 10. Quota & Soft-Delete

| # | Check |
|---|-------|
| 10.1 | Reasonable SKU defaults (basic/standard, not premium) |
| 10.2 | Soft-delete conflicts handled (unique names or purge hooks) |
| 10.3 | Container Apps CPU/memory within subscription quota |

---

## ✅ Validation Commands (Pre-Flight)

```powershell
# 1. Verify azd can parse the project
azd config list

# 2. Check authentication
azd auth login --check-status

# 3. Verify environment is set
azd env list

# 4. Validate Bicep compiles
az bicep build --file infra/main.bicep --stdout | Out-Null

# 5. What-if deployment
azd provision --preview
```

---

## Output Format

When reporting compliance results, use this structure:

### 🔴 Blocking Issues
Issues that will cause `azd provision` or `azd deploy` to fail. Include file + line + exact fix.

### 🟡 Likely Runtime Issues
Configuration that will deploy but likely fail at runtime.

### 🟢 Status
What's correctly configured.

**Skip**: Style issues, optional best practices, "nice to have" items.
