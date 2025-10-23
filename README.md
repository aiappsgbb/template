# Spec-Driven Design Workflow

This repository uses a research-first approach to ensure implementations are backed by authoritative documentation:

### 1. Research Phase
Start with the `azure-docs-research` chat mode agent:
- **`/research-plan`** - Generate a research plan with scope, topics, libraries, and refined search terms
- **`/research-collect`** - Execute research and collect code snippets, configurations, and documentation. Make sure to attach the filled planning template from the previous step to your Github Copilot chat session.

Output: Research artifacts in `.github/scratchpad/` (plan and collection files)

### 2. Implementation Phase
**Before invoking application prompts**: Attach the filled research templates (plan and collection files from `.github/scratchpad/`) to your GitHub Copilot chat session.

Then use application-specific prompts with research templates as input:
- `/newPythonApp` - FastAPI application
- `/newStreamlitApp` - Data science UI
- `/newReactApp` - React + Vite frontend
- `/newAgentApp` - AI agent with Microsoft Agent Framework
- `/newGradioApp` - Interactive AI demo
- `/newNodeApp` - Node.js/TypeScript API
- `/newDotNetApp` - ASP.NET Core Web API

Each prompt references research artifacts via inputs: `planFile`, `collectionFile`, `initialPrompt`, `researchPlan`

### 3. Infrastructure Phase
Deploy with Bicep using research-informed configurations:
- `/setupInfra` - Configure comprehensive Azure infrastructure
- `/addAzdService` - Add new service to azure.yaml