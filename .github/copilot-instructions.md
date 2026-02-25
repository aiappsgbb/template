# GitHub Copilot Instructions

Comprehensive Azure Developer CLI template for modern cloud applications with AI capabilities.

## Repository Structure

```
template/
├── .github/
│   ├── skills/              # Copilot skills — best practices & SDK reference (see microsoft/skills)
│   ├── instructions/        # Path-specific coding standards
│   ├── prompts/             # Reusable task workflows
│   ├── agents/              # Custom agents (GBB, app-developer, infra-architect, azure-docs-research)
│   ├── azure-bestpractices.md          # Zero-trust security policy (→ aigbb-azure-security skill)
│   └── bicep-deployment-bestpractices.md # Bicep + azd patterns (→ bicep-azd-patterns skill)
├── infra/                   # Bicep infrastructure (main.bicep + core/ modules)
├── src/                     # Application source code
├── azure.yaml               # Azure Developer CLI configuration
└── AGENTS.md                # Agent roles and collaboration
```

## Skills (`.github/skills/`)

Skills provide SDK and framework knowledge that Copilot loads on demand. Always prefer skills over inlining SDK code in prompts or instructions.

For community-contributed skills, see the **[microsoft/skills](https://github.com/microsoft/skills)** repository — a curated collection of reusable Copilot skills you can add to any project.

### Best-Practice Skills

| Skill | Domain |
|-------|--------|
| `aigbb-azure-security` | Zero-trust auth (ChainedTokenCredential), env var policy, RBAC, managed identity — cross-language |
| `aigbb-observability` | OpenTelemetry + Application Insights, structured logging, health checks — Python, TypeScript, .NET |
| `aigbb-ip-standards` | IP metadata schema, compliance checklists, maturity levels, repository structure requirements |
| `aigbb-azd-compliance` | azd compliance validation, parameter sync, IMAGE_NAME/RESOURCE_EXISTS, tags, hooks, shared subscription safety |

### Infrastructure & Deployment Skills

| Skill | Domain |
|-------|--------|
| `azd-deployment` | Azure Developer CLI + Container Apps deployment |
| `bicep-azd-patterns` | Bicep templates, parameters, outputs for azd |
| `containerization` | Docker multi-stage builds for Azure Container Apps |

### SDK & Framework Skills

| Skill | Domain |
|-------|--------|
| `azure-identity-py` | Azure Identity SDK (DefaultAzureCredential, managed identity) |
| `azure-storage-blob-py` | Azure Blob Storage SDK |
| `azure-ai-projects-ts` | Azure AI Projects SDK for TypeScript |
| `agent-framework-azure-ai-py` | Microsoft Agent Framework (Azure AI hosted agents) |
| `agents-v2-py` / `hosted-agents-v2-py` | Container-based Foundry Agents |
| `m365-agents-py` | Microsoft 365 Agents SDK |
| `copilot-sdk` | GitHub Copilot SDK (Node, Python, Go, .NET) |
| `fastapi-router-py` | FastAPI router patterns with CRUD + auth |
| `mcp-builder` | MCP server development (Python, TypeScript, C#) |

## Build & Deploy

```bash
azd auth login          # Authenticate
azd init                # Initialize project
azd env new <name>      # Create environment
azd up                  # Provision + deploy (or azd provision && azd deploy)
```

Validate before deploying:
```bash
az bicep build --file infra/main.bicep --stdout | Out-Null   # Bicep syntax
azd provision --preview                                       # What-if check
```

## Core Conventions

### Security (MANDATORY)
- **NEVER use API keys** for Azure services — see the `aigbb-azure-security` skill and [azure-bestpractices.md](azure-bestpractices.md)
- Use `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())`
- Always set `AZURE_CLIENT_ID` in Container Apps environment variables
- Use the `aigbb-azure-security` skill for cross-language auth patterns; `azure-identity-py` for Python-specific details

### Code Quality
- **Python**: uv package manager, type hints, `logging` module (never `print()`), Ruff/Black, pytest
- **TypeScript**: npm, strict types, ESLint/Prettier, Jest/Vitest
- **.NET**: .NET 9, xUnit, IOptions pattern
- **All languages**: Structured error handling, OpenTelemetry tracing, health check endpoints

### Infrastructure
- Follow [bicep-deployment-bestpractices.md](bicep-deployment-bestpractices.md) and the `bicep-azd-patterns` skill
- Use modules from `infra/core/` — never inline resource definitions in main.bicep
- Use `abbreviations.json` for resource naming
- Always include `azd-env-name` tag and `azd-service-name` tags for service resources

### Containerization
- Use the `containerization` skill for Dockerfile patterns
- Azure Linux base images (`mcr.microsoft.com/azurelinux/base/*`)
- Multi-stage builds, non-root user, port 80, health checks

### Git Workflow
- Feature branches: `feature/add-{app-name}`
- Dependency pinning: `>=` and `<` operators to prevent major version breaks