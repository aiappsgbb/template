---
applyTo: "infra/**/*.bicep"
---

# Bicep Infrastructure Standards

## Core Rules
- NEVER inline resource definitions in `main.bicep` — use modules from `infra/core/`
- Follow [bicep-deployment-bestpractices.md](../bicep-deployment-bestpractices.md) for template organization
- Use the `bicep-azd-patterns` skill for parameter, output, and module patterns
- Use the `azd-deployment` skill for azure.yaml and Container Apps deployment patterns

## Security (MANDATORY)
- NEVER use `listKeys()` or output sensitive values
- User Assigned Managed Identity for all Container Apps
- Always include `AZURE_CLIENT_ID` in Container App environment variables
- RBAC: Least privilege roles — NEVER use Contributor/Owner when specific roles exist
- See [azure-bestpractices.md](../azure-bestpractices.md) for forbidden patterns

## Template Structure (7 sections in main.bicep)
1. Metadata — description, author, version
2. Parameters — with `@description`, `@allowed`, `@minLength` decorators
3. Variables — `abbrs`, `tags` (must include `azd-env-name`), `resourceToken`
4. Shared infrastructure — identity, Key Vault, monitoring
5. Hosting infrastructure — Container Apps Environment, Container Registry
6. Application modules — Container Apps with `azd-service-name` tags
7. Outputs — following `SERVICE_<NAME>_ENDPOINT_URL` naming convention

## azd Integration
- Tags: `'azd-env-name': environmentName` on resource group, `'azd-service-name': '<name>'` on service resources
- Outputs become azd environment variables automatically
- Container image params: `SERVICE_<NAME>_IMAGE_NAME` + `SERVICE_<NAME>_RESOURCE_EXISTS` for upsert behavior
- Use `abbreviations.json` for resource naming

## Parameter File (main.parameters.json)
- Every param without a default in main.bicep MUST have an entry
- Use `${AZURE_ENV_NAME}` and `${AZURE_LOCATION}` for azd auto-populated values
- Use `${SERVICE_<NAME>_IMAGE_NAME=}` with empty default for container image params
