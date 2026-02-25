# Environment Variable Policy

## Allowed Variables (Endpoints & Configuration)

These are safe to set as environment variables — they contain no secrets.

### Required for ALL Container Apps

| Variable | Source (Bicep) | Description |
|----------|---------------|-------------|
| `AZURE_CLIENT_ID` | `userAssignedIdentity.outputs.clientId` | **REQUIRED** — managed identity ID |

### Azure Service Endpoints

| Variable | Source (Bicep) | Description |
|----------|---------------|-------------|
| `AZURE_OPENAI_ENDPOINT` | `openAi.outputs.endpoint` | Azure OpenAI service URL |
| `AZURE_SEARCH_ENDPOINT` | `searchService.outputs.endpoint` | AI Search service URL |
| `AZURE_STORAGE_ACCOUNT_URL` | `storageAccount.outputs.primaryEndpoints.blob` | Blob storage URL |
| `AZURE_COSMOS_ENDPOINT` | `cosmosDb.outputs.endpoint` | Cosmos DB URL |
| `AZURE_KEY_VAULT_ENDPOINT` | `keyVault.outputs.endpoint` | Key Vault URI |

### Monitoring & Configuration

| Variable | Source (Bicep) | Description |
|----------|---------------|-------------|
| `APPLICATION_INSIGHTS_CONNECTION_STRING` | `monitoring.outputs.applicationInsightsConnectionString` | App Insights (no secret) |
| `LOG_LEVEL` | Hardcoded `'INFO'` | Application log level |
| `DEBUG` | Hardcoded `'false'` | Debug mode flag |

### Application-Specific

| Variable | Source (Bicep) | Description |
|----------|---------------|-------------|
| `PORT` | Hardcoded `'80'` | Server port |
| `NODE_ENV` | Hardcoded `'production'` | Node.js environment |
| `GRADIO_SERVER_PORT` | Hardcoded `'80'` | Gradio port |
| `STREAMLIT_SERVER_PORT` | Hardcoded `'80'` | Streamlit port |

---

## Forbidden Variables (API Keys & Secrets)

**NEVER set these as environment variables.** Use managed identity instead.

| Variable | Why Forbidden | Fix |
|----------|---------------|-----|
| `AZURE_OPENAI_API_KEY` | API key auth | Use `ChainedTokenCredential` |
| `AZURE_AI_SEARCH_KEY` | API key auth | Use `ChainedTokenCredential` |
| `AZURE_STORAGE_ACCOUNT_KEY` | Storage key auth | Use `ChainedTokenCredential` |
| `AZURE_COSMOS_DB_KEY` | Database key auth | Use `ChainedTokenCredential` |
| `AZURE_SPEECH_KEY` | Speech key auth | Use `ChainedTokenCredential` |
| Any `*_KEY` variable | API key exposure | Managed identity or Key Vault |
| Any `*_SECRET` variable | Secret exposure | Key Vault with managed identity |
| Any `*_PASSWORD` variable | Credential exposure | Key Vault with managed identity |

---

## Bicep Pattern — Environment Variables Block

```bicep
environmentVariables: [
  // ─── Identity (REQUIRED) ───
  {
    name: 'AZURE_CLIENT_ID'
    value: userAssignedIdentity.outputs.clientId
  }
  // ─── Azure Service Endpoints ───
  {
    name: 'AZURE_OPENAI_ENDPOINT'
    value: openAi.outputs.endpoint
  }
  {
    name: 'AZURE_KEY_VAULT_ENDPOINT'
    value: keyVault.outputs.endpoint
  }
  // ─── Monitoring ───
  {
    name: 'APPLICATION_INSIGHTS_CONNECTION_STRING'
    value: monitoring.outputs.applicationInsightsConnectionString
  }
  // ─── Application Config ───
  {
    name: 'LOG_LEVEL'
    value: 'INFO'
  }
]
```

---

## Naming Convention

- Use `SCREAMING_SNAKE_CASE` for all environment variables
- Prefix Azure service endpoints with `AZURE_`
- Match names exactly between Bicep, `pydantic-settings`, and `.env` files
- Use descriptive suffixes: `_ENDPOINT`, `_URL`, `_NAME`

### Cross-File Alignment Example

**Bicep** → `AZURE_OPENAI_ENDPOINT`
**Python** → `azure_openai_endpoint` (pydantic-settings with `env_prefix="AZURE_"` becomes `OPENAI_ENDPOINT`)
**TypeScript** → `process.env.AZURE_OPENAI_ENDPOINT`
**.NET** → `configuration["Azure:OpenAiEndpoint"]`
**.env** → `AZURE_OPENAI_ENDPOINT=https://...`
