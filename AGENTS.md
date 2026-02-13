# Agents Configuration

This file defines AI agents and their capabilities for the Azure Template Project repository.

## Repository Overview

**Name**: Azure Template Project
**Description**: A comprehensive Azure Developer CLI template for modern cloud applications with AI capabilities
**Type**: Infrastructure Template & Development Framework
**Owner**: AI Apps GBB Team

## Custom Agents (`.github/agents/`)

Select **`GBB`** from the agents dropdown in Copilot Chat — it is the **only user-facing agent**. All other agents are internal specialists that `GBB` routes to via handoff buttons. Their descriptions are prefixed with `[Internal sub-agent]` so you know to ignore them in the dropdown.

| Agent | Role | How It's Used | Hands Off To |
|-------|------|---------------|:------------:|
| **GBB** | Primary orchestrator — guides the full workflow, routes to specialists | **Select this one** | app-developer, infra-architect, azure-docs-research |
| app-developer | Scaffolds applications across Python, TypeScript, .NET, AI agents | Auto-routed via handoff | infra-architect, azure-docs-research |
| infra-architect | Bicep infrastructure, azd config, compliance validation | Auto-routed via handoff | app-developer, azure-docs-research |
| azure-docs-research | Gathers authoritative Azure SDK/service documentation | Auto-routed via handoff | app-developer, infra-architect |

### Workflow

```
GBB (start here)
    ├── azure-docs-research → collect docs → hand off to app-developer
    ├── app-developer → scaffold app → hand off to infra-architect
    └── infra-architect → set up Bicep + azd → /checkAzdCompliance → azd up
```

## Skills (shared across all agents)

Skills in `.github/skills/` load on demand by keyword trigger. They are **cross-cutting** — every agent benefits from them automatically.

| Skill | Domain |
|-------|--------|
| `azd-deployment` | Azure Developer CLI + Container Apps deployment |
| `bicep-azd-patterns` | Bicep templates, parameters, outputs for azd |
| `containerization` | Docker multi-stage builds for Azure Container Apps |
| `azure-identity-py` | Azure Identity SDK (DefaultAzureCredential, managed identity) |
| `azure-storage-blob-py` | Azure Blob Storage SDK |
| `fastapi-router-py` | FastAPI router patterns with CRUD + auth |
| `azure-ai-projects-ts` | Azure AI Projects SDK for TypeScript |
| `agent-framework-azure-ai-py` | Microsoft Agent Framework (Azure AI hosted agents) |
| `agents-v2-py` / `hosted-agents-v2-py` | Container-based Foundry Agents |
| `m365-agents-py` | Microsoft 365 Agents SDK |
| `copilot-sdk` | GitHub Copilot SDK (Node, Python, Go, .NET) |
| `mcp-builder` | MCP server development (Python, TypeScript, C#) |

## Key Technologies

- **Infrastructure**: Azure Bicep, Azure Developer CLI, Container Apps, Container Registry
- **AI/ML**: Azure AI Foundry, Azure OpenAI, Azure AI Search, Microsoft Agent Framework
- **Security**: Azure Key Vault, Managed Identities (zero API keys policy)
- **Monitoring**: Azure Monitor, Application Insights, OpenTelemetry
- **Languages**: Python (uv, FastAPI, Gradio, Streamlit), TypeScript (npm, Express, React, Vite), .NET 9 (ASP.NET Core)

## Copilot Customization Hierarchy

| Priority | File(s) | Loaded When |
|----------|---------|-------------|
| 1 | `.github/copilot-instructions.md` | Always (every chat) |
| 2 | `.github/instructions/*.instructions.md` | Editing files matching `applyTo` pattern |
| 3 | `.github/skills/*/SKILL.md` | On demand (keyword triggers) |
| 4 | `.github/prompts/*.prompt.md` | User-invoked (`/promptName`) |
| 5 | `.github/agents/*.agent.md` | `GBB` selected by user; sub-agents via handoff |
| 6 | `AGENTS.md` | Agent-level instructions |

## Anti-Patterns to Avoid

- Hard-coded credentials or API keys (see [azure-bestpractices.md](.github/azure-bestpractices.md))
- `print()` / `console.log()` instead of structured logging
- Inline resource definitions in main.bicep (use `infra/core/` modules)
- Manual deployment processes (use `azd up`)
- Over-provisioned RBAC roles (`Contributor`/`Owner` when specific roles suffice)
