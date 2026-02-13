# Agents Configuration

This file defines AI agents and their capabilities for the Azure Template Project repository.

## Repository Overview

**Name**: Azure Template Project
**Description**: A comprehensive Azure Developer CLI template for modern cloud applications with AI capabilities
**Type**: Infrastructure Template & Development Framework
**Owner**: AI Apps GBB Team

## Primary Agents

### Azure Infrastructure Architect

**Role**: Infrastructure Design & Deployment Specialist

**Skills**: `azd-deployment`, `bicep-azd-patterns`

**Context Files**: `infra/**/*.bicep`, `azure.yaml`, `infra/main.parameters.json`, `infra/abbreviations.json`

**References**: [azure-bestpractices.md](.github/azure-bestpractices.md), [bicep-deployment-bestpractices.md](.github/bicep-deployment-bestpractices.md)

### Application Developer

**Role**: Multi-Language Application Development Specialist

**Skills**: `fastapi-router-py`, `azure-identity-py`, `azure-storage-blob-py`, `agent-framework-azure-ai-py`, `m365-agents-py`, `copilot-sdk`, `containerization`

**Context Files**: `src/**/*`, `.github/prompts/**/*.prompt.md`, `azure.yaml`

### DevOps Engineer

**Role**: Automation & Deployment Specialist

**Skills**: `azd-deployment`, `containerization`, `mcp-builder`

**Context Files**: `.github/workflows/**/*`, `azure.yaml`, `infra/scripts/**/*.py`

### AI Solutions Architect

**Role**: AI/ML Integration & Optimization Specialist

**Skills**: `agent-framework-azure-ai-py`, `agents-v2-py`, `hosted-agents-v2-py`, `azure-ai-projects-ts`, `m365-agents-py`

**Context Files**: `infra/core/ai/**/*.bicep`, `src/**/*`

## Key Technologies

- **Infrastructure**: Azure Bicep, Azure Developer CLI, Container Apps, Container Registry
- **AI/ML**: Azure AI Foundry, Azure OpenAI, Azure AI Search, Microsoft Agent Framework
- **Security**: Azure Key Vault, Managed Identities (zero API keys policy)
- **Monitoring**: Azure Monitor, Application Insights, OpenTelemetry
- **Languages**: Python (uv, FastAPI, Gradio, Streamlit), TypeScript (npm, Express, React, Vite), .NET 9 (ASP.NET Core)

## Customization Hierarchy

Copilot uses these files in priority order:

1. **`.github/copilot-instructions.md`** — Repository-wide conventions (always loaded)
2. **`.github/instructions/*.instructions.md`** — Path-specific rules (loaded when editing matching files)
3. **`.github/skills/*/SKILL.md`** — SDK/framework reference (loaded on demand by keyword triggers)
4. **`.github/prompts/*.prompt.md`** — Reusable task workflows (user-invoked)
5. **`.github/agents/*.agent.md`** — Custom agent personas

## Anti-Patterns to Avoid

- Hard-coded credentials or API keys (see [azure-bestpractices.md](.github/azure-bestpractices.md))
- `print()` / `console.log()` instead of structured logging
- Inline resource definitions in main.bicep (use `infra/core/` modules)
- Manual deployment processes (use `azd up`)
- Over-provisioned RBAC roles (`Contributor`/`Owner` when specific roles suffice)
