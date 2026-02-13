---
applyTo: "**/*.py"
---

# Python Coding Standards

## Package Management
- Use **uv** as the package manager (not pip directly)
- Pin dependencies with `>=` and `<` to prevent major version breaks
- Include `.python-version` file in each app directory

## Code Quality
- **Type hints**: Required on all function signatures and class attributes
- **Linting**: Ruff for linting, Black for formatting
- **Testing**: pytest with comprehensive coverage
- **Logging**: Use `logging` module — NEVER use `print()` in production code
- **Log levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL — choose appropriately

## Azure Authentication
- Use `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())`
- NEVER use API keys — see [azure-bestpractices.md](../azure-bestpractices.md)
- Use the `azure-identity-py` skill for implementation patterns

## Application Patterns
- **FastAPI**: Use the `fastapi-router-py` skill for router patterns
- **Configuration**: pydantic-settings with `BaseSettings` subclass
- **Error handling**: Structured exception handling with meaningful messages
- **Async**: Prefer async APIs for I/O-bound operations
- **OpenTelemetry**: Include tracing with Azure Monitor integration

## Agent Framework
- Use the `agent-framework-azure-ai-py` skill for Azure AI hosted agents
- Use the `m365-agents-py` skill for Microsoft 365 agents
