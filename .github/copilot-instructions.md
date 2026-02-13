# GitHub Copilot Instructions

Comprehensive Azure Developer CLI template for modern cloud applications with AI capabilities.

## Repository Structure

```
template/
├── .github/
│   ├── skills/              # Copilot skills (SDK/framework reference)
│   ├── instructions/        # Path-specific coding standards
│   ├── prompts/             # Reusable task workflows
│   ├── agents/              # Custom agents (GBB, app-developer, infra-architect, azure-docs-research)
│   ├── templates/           # Research workflow templates
│   ├── azure-bestpractices.md          # Zero-trust security policy
│   └── bicep-deployment-bestpractices.md # Bicep + azd patterns
├── infra/                   # Bicep infrastructure (main.bicep + core/ modules)
├── src/                     # Application source code
├── azure.yaml               # Azure Developer CLI configuration
└── AGENTS.md                # Agent roles and collaboration
```

## Skills (`.github/skills/`)

Skills provide SDK and framework knowledge that Copilot loads on demand. Always prefer skills over inlining SDK code in prompts or instructions.

| Skill | Domain |
|-------|--------|
| `azd-deployment` | Azure Developer CLI + Container Apps deployment |
| `bicep-azd-patterns` | Bicep templates, parameters, outputs for azd |
| `azure-identity-py` | Azure Identity SDK (DefaultAzureCredential, managed identity) |
| `azure-storage-blob-py` | Azure Blob Storage SDK |
| `azure-ai-projects-ts` | Azure AI Projects SDK for TypeScript |
| `agent-framework-azure-ai-py` | Microsoft Agent Framework (Azure AI hosted agents) |
| `agents-v2-py` / `hosted-agents-v2-py` | Container-based Foundry Agents |
| `m365-agents-py` | Microsoft 365 Agents SDK |
| `copilot-sdk` | GitHub Copilot SDK (Node, Python, Go, .NET) |
| `fastapi-router-py` | FastAPI router patterns with CRUD + auth |
| `mcp-builder` | MCP server development (Python, TypeScript, C#) |
| `containerization` | Docker multi-stage builds for Azure Container Apps |

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
- **NEVER use API keys** for Azure services — see [azure-bestpractices.md](azure-bestpractices.md)
- Use `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())`
- Always set `AZURE_CLIENT_ID` in Container Apps environment variables
- Use the `azure-identity-py` skill for implementation patterns

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