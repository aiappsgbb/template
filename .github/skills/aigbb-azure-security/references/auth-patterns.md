# Azure Zero-Trust Authentication Quick Reference

## ChainedTokenCredential — Complete Examples

### Python: FastAPI with Azure OpenAI

```python
import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from azure.identity import (
    AzureDeveloperCliCredential,
    ManagedIdentityCredential,
    ChainedTokenCredential,
    get_bearer_token_provider,
)
from openai import AzureOpenAI

logger = logging.getLogger(__name__)

_credential: ChainedTokenCredential | None = None
_openai_client: AzureOpenAI | None = None


def get_credential() -> ChainedTokenCredential:
    global _credential
    if _credential is None:
        _credential = ChainedTokenCredential(
            AzureDeveloperCliCredential(),
            ManagedIdentityCredential(),
        )
    return _credential


def get_openai_client() -> AzureOpenAI:
    global _openai_client
    if _openai_client is None:
        credential = get_credential()
        token_provider = get_bearer_token_provider(
            credential, "https://cognitiveservices.azure.com/.default"
        )
        _openai_client = AzureOpenAI(
            azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
            azure_ad_token_provider=token_provider,
            api_version="2024-12-01-preview",
        )
    return _openai_client


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing Azure credentials")
    get_credential()
    yield
    logger.info("Shutting down")


app = FastAPI(lifespan=lifespan)
```

### TypeScript: Express with Azure OpenAI

```typescript
import { AzureOpenAI } from "openai";
import {
  ChainedTokenCredential,
  AzureDeveloperCliCredential,
  ManagedIdentityCredential,
  getBearerTokenProvider,
} from "@azure/identity";

let credential: ChainedTokenCredential | null = null;
let openaiClient: AzureOpenAI | null = null;

export function getCredential(): ChainedTokenCredential {
  if (!credential) {
    credential = new ChainedTokenCredential(
      new AzureDeveloperCliCredential(),
      new ManagedIdentityCredential(),
    );
  }
  return credential;
}

export function getOpenAIClient(): AzureOpenAI {
  if (!openaiClient) {
    const cred = getCredential();
    const tokenProvider = getBearerTokenProvider(
      cred,
      "https://cognitiveservices.azure.com/.default",
    );
    openaiClient = new AzureOpenAI({
      azureADTokenProvider: tokenProvider,
      endpoint: process.env.AZURE_OPENAI_ENDPOINT!,
      apiVersion: "2024-12-01-preview",
    });
  }
  return openaiClient;
}
```

### .NET: ASP.NET Core with Azure OpenAI

```csharp
using Azure.Identity;
using Azure.AI.OpenAI;
using Microsoft.Extensions.DependencyInjection;

public static class AzureServiceExtensions
{
    public static IServiceCollection AddAzureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Register singleton credential
        services.AddSingleton<ChainedTokenCredential>(_ =>
            new ChainedTokenCredential(
                new AzureDeveloperCliCredential(),
                new ManagedIdentityCredential()
            ));

        // Register Azure OpenAI client
        services.AddSingleton(sp =>
        {
            var credential = sp.GetRequiredService<ChainedTokenCredential>();
            var endpoint = configuration["Azure:OpenAiEndpoint"]
                ?? throw new InvalidOperationException("Azure:OpenAiEndpoint not configured");
            return new AzureOpenAIClient(new Uri(endpoint), credential);
        });

        return services;
    }
}
```

---

## Token Scopes by Service

| Azure Service | Token Scope |
|---------------|-------------|
| Azure OpenAI / Cognitive Services | `https://cognitiveservices.azure.com/.default` |
| Azure AI Search | `https://search.azure.com/.default` |
| Azure Storage | `https://storage.azure.com/.default` |
| Azure Key Vault | `https://vault.azure.net/.default` |
| Azure Cosmos DB | `https://cosmos.azure.com/.default` |
| Microsoft Graph | `https://graph.microsoft.com/.default` |
| Azure Management | `https://management.azure.com/.default` |

---

## Credential Singleton Pattern

**Always reuse credential instances** — creating new clients for every request is expensive:

```python
# ✅ CORRECT — singleton
_credential = None
def get_credential():
    global _credential
    if _credential is None:
        _credential = ChainedTokenCredential(...)
    return _credential

# ❌ WRONG — creates new credential on every call
def get_client():
    credential = ChainedTokenCredential(...)  # Expensive!
    return SomeClient(credential=credential)
```

---

## Local Development Setup

1. Install Azure Developer CLI: `winget install Microsoft.Azd`
2. Authenticate: `azd auth login`
3. Set environment: `azd env select <env-name>`
4. Run app — `AzureDeveloperCliCredential` will use your azd token automatically

No `.env` file with keys needed. The credential chain handles everything.
