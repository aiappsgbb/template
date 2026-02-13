# Azure Developer CLI Template

An opinionated, **Copilot-powered starter template** for building Azure cloud applications. This repo provides the scaffolding — Bicep infrastructure modules, lifecycle hooks, coding standards, GitHub Copilot skills, and reusable prompts — so you can go from zero to a deployed app on Azure Container Apps using AI-assisted development.

> **This is a template, not a finished application.** You clone/fork it, then use the embedded Copilot prompts and skills to generate your application code, wire up infrastructure, and deploy.

## Prerequisites

- [VS Code](https://code.visualstudio.com/) with [GitHub Copilot](https://github.com/features/copilot) (Chat enabled)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for container builds)
- Language runtimes as needed: Python 3.12+ with [uv](https://docs.astral.sh/uv/), Node.js 20+, .NET 9

## How to Develop With This Template

Everything in this template is designed to be used **through GitHub Copilot Chat in VS Code**. The repo embeds skills, prompts, path-specific instructions, and agent personas that give Copilot deep context about Azure best practices, so it generates correct, production-ready code from the start.

### 1. Create Your Repo

Click the **"Use this template"** button on GitHub to create a new repository from this template. Clone it locally and open it in VS Code — Copilot automatically picks up all `.github/` customization files.

### 2. Research (Optional but Recommended)

Ask **`GBB`** to research Azure documentation for your project. It hands off to the internal research agent, which handles both planning and collection in a single session using:
- **Context7** — resolves library IDs and retrieves SDK-level documentation and code examples
- **MS Learn** — searches service docs and fetches official code samples
- **Azure MCP** — Azure service-specific documentation
- **Web search** — fallback for gaps

You can also invoke the lightweight prompts `/research-plan` and `/research-collect` which delegate to the agent.

Output lands in `.github/scratchpad/` as structured plan and collection files. Attach those files to subsequent Copilot chat sessions so every prompt has authoritative context.

### 3. Scaffold Your Application

Tell Copilot what you want to build. Invoke the matching prompt in Copilot Chat and attach your research artifacts (`planFile`, `collectionFile`) if you have them:

| Prompt | What You Get |
|--------|-------------|
| `/newPythonApp` | FastAPI REST API with uv, structured logging, Dockerfile |
| `/newNodeApp` | Node.js / TypeScript API with npm, ESLint, Dockerfile |
| `/newDotNetApp` | ASP.NET Core Web API with .NET 9, xUnit, Dockerfile |
| `/newAgentApp` | AI agent using Microsoft Agent Framework |
| `/newGradioApp` | Gradio interactive AI demo |
| `/newStreamlitApp` | Streamlit data-science UI |
| `/newReactApp` | React + Vite frontend |

Each prompt generates code in `src/<your-service>/`, including a Dockerfile, dependencies, and health endpoints — all following the conventions in this template.

### 4. Wire Up Infrastructure

Once your app code exists, configure the Azure resources it needs:

| Prompt | What It Does |
|--------|-------------|
| `/setupInfra` | Generates Bicep modules in `infra/` for your required Azure services |
| `/addAzdService` | Registers your service in `azure.yaml` and adds Container App Bicep |
| `/checkAzdCompliance` | **Run this before every `azd up`** — validates your entire azd config and catches issues that break deployment |

### 5. Deploy

Only after steps 3–4 are complete and `/checkAzdCompliance` passes:

```bash
azd auth login            # Authenticate with Azure
azd env new <env-name>    # Create an environment
azd up                    # Provision infrastructure + deploy
```

Optionally validate first:
```bash
az bicep build --file infra/main.bicep --stdout | Out-Null   # Bicep syntax check
azd provision --preview                                       # What-if preview
```

### Utility Prompts

| Prompt | Purpose |
|--------|---------|
| `/newReadme` | Generate a project README from your codebase |
| `/ipMetadata` | Add IP tracking metadata to `azure.yaml` |
| `/ipCompliance` | Validate IP compliance across the project |

### What Happens Automatically

As you code, Copilot applies the right context without you doing anything:
- **Edit a `.py` file** → Python coding standards load automatically
- **Edit a `.bicep` file** → Bicep rules + module patterns load automatically
- **Edit a `Dockerfile`** → Container best practices load automatically
- **Mention an SDK** (e.g., "Azure Identity", "FastAPI") → the matching skill loads on demand
- **Every chat** → repo-wide security policy and conventions are always present

### Custom Agents

Select **`GBB`** from the agents dropdown in Copilot Chat — it's the **only agent you need**. Sub-agents are internal specialists; `GBB` routes to them automatically via handoff buttons. If you see them in the dropdown, ignore them — their descriptions say "Select GBB instead".

| Agent | Role | How It's Used |
|-------|------|---------------|
| **GBB** | Primary orchestrator — routes to specialists, guides the full workflow | **Select this one** |
| app-developer | Scaffolds apps (Python, TypeScript, .NET, AI agents), enforces coding standards | Auto-routed via handoff |
| infra-architect | Bicep infrastructure, azd config, compliance validation | Auto-routed via handoff |
| azure-docs-research | Gathers authoritative Azure SDK/service documentation | Auto-routed via handoff |

After each response, `GBB` offers handoff buttons to the relevant specialist. The guided workflow:

```
GBB → azure-docs-research → app-developer → infra-architect → azd up
```

---

## Repository Structure

```
template/
├── .github/
│   ├── copilot-instructions.md       # Repo-wide conventions (always loaded)
│   ├── azure-bestpractices.md        # Zero-trust security policy
│   ├── bicep-deployment-bestpractices.md  # Bicep authoring guide
│   ├── skills/                       # 13 Copilot skills (SDK/framework reference)
│   ├── instructions/                 # 5 path-specific coding standards
│   ├── prompts/                      # 15 reusable task workflows
│   ├── agents/                       # 4 custom agents (orchestrator + specialists)
│   └── templates/                    # Research workflow templates
├── infra/
│   ├── main.bicep                    # Entry point — modules only, no inline resources
│   ├── main.parameters.json          # Parameters with IMAGE_NAME/RESOURCE_EXISTS patterns
│   ├── abbreviations.json            # Resource naming conventions
│   ├── core/                         # Reusable Bicep modules
│   │   ├── ai/                       #   Azure OpenAI, AI Search
│   │   ├── database/                 #   Cosmos DB
│   │   ├── host/                     #   Container Apps, Container Apps Environment
│   │   ├── monitor/                  #   Application Insights, Log Analytics
│   │   ├── security/                 #   Key Vault, Managed Identity
│   │   ├── storage/                  #   Container Registry, Storage Account
│   │   └── deployment/               #   ACR image import
│   ├── data/                         # Data seed files
│   └── scripts/                      # Python lifecycle hooks (pre/post provision/deploy)
├── src/                              # Application source code (your services go here)
├── azure.yaml                        # azd project definition
└── AGENTS.md                         # Agent roles and Copilot hierarchy
```

---

## GitHub Copilot Customization

Copilot loads context in this priority order:

| Priority | File(s) | Loaded When |
|----------|---------|-------------|
| 1 | `.github/copilot-instructions.md` | Always (every chat) |
| 2 | `.github/instructions/*.instructions.md` | Editing files matching `applyTo` pattern |
| 3 | `.github/skills/*/SKILL.md` | On demand (keyword triggers) |
| 4 | `.github/prompts/*.prompt.md` | User-invoked (`/promptName`) |
| 5 | `.github/agents/*.agent.md` | `GBB` selected by user; sub-agents via handoff |
| 6 | `AGENTS.md` | Agent-level instructions |

### Path-Specific Instructions (auto-loaded)

| File | Applies To |
|------|-----------|
| `python.instructions.md` | `**/*.py` |
| `typescript.instructions.md` | `**/*.ts, *.tsx, *.js, *.jsx` |
| `bicep.instructions.md` | `infra/**/*.bicep` |
| `dockerfile.instructions.md` | `**/Dockerfile` |
| `dotnet.instructions.md` | `**/*.cs, *.csproj` |

### Skills (on-demand SDK reference)

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

---

## Features & Best Practices

### Security
- **Zero API keys policy** — all Azure auth uses `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())`
- `AZURE_CLIENT_ID` always set in Container Apps environment
- Key Vault for secrets; Managed Identities for service-to-service auth
- Least-privilege RBAC assignments (no blanket `Contributor`/`Owner`)
- Full policy documented in `.github/azure-bestpractices.md`

### Infrastructure (Bicep + azd)
- Modular Bicep — `infra/core/` modules, never inline resources in `main.bicep`
- `abbreviations.json` for consistent resource naming
- Required tags: `azd-env-name` on resource group, `azd-service-name` on service resources
- Container image preservation via `IMAGE_NAME`/`RESOURCE_EXISTS` parameters
- Output convention: `SERVICE_<NAME>_ENDPOINT`, `SERVICE_<NAME>_NAME`
- Lifecycle hooks in Python (uv) for pre/post provision and deploy
- Full patterns in `.github/bicep-deployment-bestpractices.md`

### Containerization
- Azure Linux base images (`mcr.microsoft.com/azurelinux/base/*`)
- Multi-stage builds, non-root user, port 80, health checks
- Remote build via ACR (`docker.remoteBuild: true` in `azure.yaml`)
- Language-specific Dockerfile templates (Python, Node.js, .NET)

### Application Development
- **Python**: uv package manager, type hints, `logging` (never `print()`), Ruff/Black, pytest
- **TypeScript**: npm, strict types, ESLint/Prettier, Jest/Vitest
- **.NET**: .NET 9, xUnit, IOptions pattern, ILogger
- All languages: structured error handling, OpenTelemetry tracing, health endpoints

### AI / Agent Frameworks
- Microsoft Agent Framework with Azure AI Foundry hosted agents
- Container-based Foundry Agents (v2) with custom images
- Microsoft 365 Agents SDK for Teams/Copilot Studio
- Azure AI Projects SDK (TypeScript) for connections, deployments, evaluations
- GitHub Copilot SDK for programmatic integrations
- MCP server patterns for tool integration

### Git & Workflow
- Feature branches: `feature/add-{app-name}`
- Dependency pinning: `>=` and `<` operators to prevent major version breaks
- Research-first approach: gather docs before coding
- `/checkAzdCompliance` before every `azd up`