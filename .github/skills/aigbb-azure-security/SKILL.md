---
name: aigbb-azure-security
description: "Zero-trust security patterns for Azure applications and infrastructure. Cross-language authentication with ChainedTokenCredential (Python, TypeScript, .NET), managed identity, RBAC least-privilege roles, environment variable policies (allowed/forbidden), Azure Key Vault integration, and pre-deployment security checklists. Use when connecting to any Azure service, configuring authentication, setting up RBAC, reviewing environment variables, or validating security posture. Triggers on Azure security, authentication, managed identity, credential, API key, RBAC, role assignment, Key Vault, AZURE_CLIENT_ID, zero trust, ChainedTokenCredential, AzureDeveloperCliCredential, ManagedIdentityCredential, forbidden, allowed environment variables."
---

# Azure Zero-Trust Security Patterns

Mandatory security patterns for every Azure integration in this repository. **No exceptions. No API keys. No compromise.**

> **Community skills**: For additional Azure SDK skills, see the [microsoft/skills](https://github.com/microsoft/skills) community repository — a collection of reusable Copilot skills maintained by the community.

---

## Core Principle

**NEVER use API keys or connection strings for Azure service authentication.** All authentication MUST use Microsoft Entra ID (Azure Active Directory) with:

1. **Azure Developer CLI** for local development
2. **Managed Identity** for production deployments

---

## 1. Authentication — ChainedTokenCredential

Use `ChainedTokenCredential` in every application that connects to Azure. This provides seamless local → production authentication without code changes.

### Python

```python
from azure.identity import (
    AzureDeveloperCliCredential,
    ManagedIdentityCredential,
    ChainedTokenCredential,
)

def get_azure_credential() -> ChainedTokenCredential:
    """Best-practice credential chain: azd (local) → managed identity (prod)."""
    return ChainedTokenCredential(
        AzureDeveloperCliCredential(),   # Local development with azd
        ManagedIdentityCredential(),     # Production in Container Apps
    )
```

### TypeScript

```typescript
import {
  ChainedTokenCredential,
  AzureDeveloperCliCredential,
  ManagedIdentityCredential,
} from "@azure/identity";

export function getAzureCredential(): ChainedTokenCredential {
  return new ChainedTokenCredential(
    new AzureDeveloperCliCredential(),  // Local development with azd
    new ManagedIdentityCredential(),    // Production in Container Apps
  );
}
```

### .NET (C#)

```csharp
using Azure.Identity;

public static class AzureCredentialHelper
{
    public static ChainedTokenCredential GetAzureCredential()
    {
        return new ChainedTokenCredential(
            new AzureDeveloperCliCredential(),  // Local development with azd
            new ManagedIdentityCredential()     // Production in Container Apps
        );
    }
}
```

---

## 2. Service Client Configuration

Always pass `credential` (never an API key) when constructing Azure SDK clients.

### Python Examples

```python
# Azure OpenAI
from openai import AzureOpenAI
from azure.identity import get_bearer_token_provider

credential = get_azure_credential()
token_provider = get_bearer_token_provider(
    credential, "https://cognitiveservices.azure.com/.default"
)
client = AzureOpenAI(
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
    azure_ad_token_provider=token_provider,
    api_version="2024-12-01-preview",
)

# Azure AI Search
from azure.search.documents import SearchClient
client = SearchClient(
    endpoint=os.environ["AZURE_SEARCH_ENDPOINT"],
    index_name="my-index",
    credential=credential,
)

# Azure Blob Storage
from azure.storage.blob import BlobServiceClient
client = BlobServiceClient(
    account_url=os.environ["AZURE_STORAGE_ACCOUNT_URL"],
    credential=credential,
)

# Azure Cosmos DB
from azure.cosmos import CosmosClient
client = CosmosClient(
    url=os.environ["AZURE_COSMOS_ENDPOINT"],
    credential=credential,
)

# Azure Key Vault
from azure.keyvault.secrets import SecretClient
client = SecretClient(
    vault_url=os.environ["AZURE_KEY_VAULT_ENDPOINT"],
    credential=credential,
)
```

### TypeScript Examples

```typescript
import { AzureOpenAI } from "openai";
import { getBearerTokenProvider } from "@azure/identity";

const credential = getAzureCredential();
const tokenProvider = getBearerTokenProvider(
  credential,
  "https://cognitiveservices.azure.com/.default",
);
const client = new AzureOpenAI({
  azureADTokenProvider: tokenProvider,
  endpoint: process.env.AZURE_OPENAI_ENDPOINT!,
  apiVersion: "2024-12-01-preview",
});
```

---

## 3. Environment Variable Policy

### ✅ ALLOWED (endpoints and connection strings)

These are safe — they contain no secrets:

| Variable | Purpose |
|----------|---------|
| `AZURE_CLIENT_ID` | **REQUIRED** — managed identity client ID |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI service endpoint |
| `AZURE_SEARCH_ENDPOINT` | Azure AI Search endpoint |
| `AZURE_STORAGE_ACCOUNT_URL` | Storage account blob endpoint |
| `AZURE_COSMOS_ENDPOINT` | Cosmos DB account endpoint |
| `AZURE_KEY_VAULT_ENDPOINT` | Key Vault URI |
| `APPLICATION_INSIGHTS_CONNECTION_STRING` | App Insights (no secret) |

### ❌ FORBIDDEN (API keys and secrets)

**NEVER set these as environment variables:**

| Variable | Why Forbidden |
|----------|---------------|
| `AZURE_OPENAI_API_KEY` | Use managed identity instead |
| `AZURE_AI_SEARCH_KEY` | Use managed identity instead |
| `AZURE_STORAGE_ACCOUNT_KEY` | Use managed identity instead |
| `AZURE_COSMOS_DB_KEY` | Use managed identity instead |
| Any `*_KEY` or `*_SECRET` | Use Key Vault + managed identity |

---

## 4. Infrastructure — Managed Identity

### User Assigned Managed Identity (required)

```bicep
// Always create a User Assigned Managed Identity
module userAssignedIdentity 'core/security/user-assigned-identity.bicep' = {
  name: 'user-assigned-identity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${environmentName}'
    location: location
    tags: tags
  }
}
```

### Assign to Container Apps

```bicep
module containerApp 'core/host/container-app.bicep' = {
  name: 'container-app'
  params: {
    userAssignedIdentityId: userAssignedIdentity.outputs.id
    managedIdentityPrincipalId: userAssignedIdentity.outputs.principalId
    environmentVariables: [
      {
        name: 'AZURE_CLIENT_ID'
        value: userAssignedIdentity.outputs.clientId   // ← REQUIRED
      }
    ]
  }
}
```

---

## 5. RBAC — Least Privilege Roles

Use specific roles; never `Contributor` or `Owner`.

### Common Role Assignments

| Service | Role | Role ID |
|---------|------|---------|
| Key Vault | Key Vault Secrets User | `4633458b-17de-408a-b874-0445c86b69e6` |
| Storage | Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` |
| Azure OpenAI | Cognitive Services User | `5e0bd9bd-7b93-4f28-af87-19fc36ad61bd` |
| AI Search | Search Service Contributor | `7ca78c08-252a-4471-8644-bb5ff32d4ba0` |
| AI Search | Search Index Data Contributor | `8ebe5a00-799e-43f5-93ac-243d3dce84a7` |
| Cosmos DB | Cosmos DB Built-in Data Contributor | `00000000-0000-0000-0000-000000000002` |
| Container Registry | AcrPull | `7f951dda-4ed3-4680-a7ca-43fe172d538d` |

### Bicep Pattern

```bicep
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(resource.id, principalId, roleDefinitionId)
  scope: resource
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions', roleDefinitionId
    )
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

**Guard with `if (!empty(principalId))`** to avoid failures when no principal is provided.

---

## 6. Configuration Management

### Python (pydantic-settings)

```python
from pydantic_settings import BaseSettings

class AzureSettings(BaseSettings):
    # Endpoints only — no keys
    openai_endpoint: str
    search_endpoint: str
    storage_account_url: str
    cosmos_endpoint: str
    keyvault_endpoint: str

    # Managed identity
    client_id: str | None = None

    class Config:
        env_prefix = "AZURE_"
```

### TypeScript

```typescript
interface AzureConfig {
  openaiEndpoint: string;
  searchEndpoint: string;
  storageAccountUrl: string;
  cosmosEndpoint: string;
  keyvaultEndpoint: string;
  clientId?: string;
}
```

### .NET (IOptions pattern)

```csharp
public record AzureSettings
{
    public string OpenAiEndpoint { get; init; } = string.Empty;
    public string SearchEndpoint { get; init; } = string.Empty;
    public string StorageAccountUrl { get; init; } = string.Empty;
    public string CosmosEndpoint { get; init; } = string.Empty;
    public string KeyVaultEndpoint { get; init; } = string.Empty;
    public string? ClientId { get; init; }
}
```

---

## 7. Forbidden Patterns

### Code

```python
# ❌ FORBIDDEN — API key authentication
client = OpenAIClient(endpoint=endpoint, api_key="sk-...")

# ❌ FORBIDDEN — connection string with embedded key
client = BlobServiceClient(conn_str="DefaultEndpointsProtocol=https;AccountKey=...")
```

### Bicep

```bicep
// ❌ FORBIDDEN — extracting access keys
var storageKey = storageAccount.listKeys().keys[0].value

// ❌ FORBIDDEN — outputting secrets
output storageKey string = storageAccount.listKeys().keys[0].value

// ❌ FORBIDDEN — access-key auth mode
properties: { authenticationMethod: 'accessKey' }
```

---

## 8. Pre-Deployment Security Checklist

Before deploying any code or infrastructure:

- [ ] No API keys in code, configuration, or environment variables
- [ ] All Azure service clients use `ChainedTokenCredential`
- [ ] `AZURE_CLIENT_ID` environment variable is set for Container Apps
- [ ] Managed Identity is assigned appropriate RBAC roles
- [ ] No `Contributor` or `Owner` role assignments (use specific roles)
- [ ] All sensitive values are retrieved from Key Vault (if needed)
- [ ] Infrastructure uses User Assigned Managed Identity
- [ ] No `listKeys()` functions in Bicep templates
- [ ] No `*_KEY` or `*_SECRET` environment variables

### Code Review Quick Scan

Search for forbidden patterns:
```
api_key=    secret=    password=    listKeys()    *_KEY    *_SECRET
```

---

## References

- [Azure Identity client library](https://learn.microsoft.com/python/api/overview/azure/identity-readme)
- [Managed identities for Azure resources](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/)
- [Azure RBAC built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles)
- [Azure Best Practices (this repo)](../../.github/azure-bestpractices.md)
