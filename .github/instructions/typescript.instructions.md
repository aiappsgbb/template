---
applyTo: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx"
---

# TypeScript/JavaScript Coding Standards

## Package Management
- Use **npm** as the package manager
- Pin dependencies with `>=` and `<` to prevent major version breaks
- Include `.nvmrc` file in each app directory

## Code Quality
- **Strict TypeScript**: Enable strict mode in tsconfig.json
- **Linting**: ESLint with recommended rules
- **Formatting**: Prettier
- **Testing**: Jest or Vitest with comprehensive coverage
- **Logging**: Use structured logging (winston) — NEVER use `console.log()` in production

## Azure Authentication
- Use `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())` from `@azure/identity`
- NEVER use API keys — see [azure-bestpractices.md](../azure-bestpractices.md)

## Application Patterns
- **Express**: RESTful APIs with comprehensive middleware and error handling
- **React + Vite**: Modern frontends with Tailwind CSS, Context API
- **Configuration**: Environment-based config with type-safe interfaces
- **Error handling**: Structured error responses with proper HTTP status codes
- **OpenTelemetry**: Include tracing with Azure Monitor integration

## AI Integration
- Use the `azure-ai-projects-ts` skill for Azure AI Projects SDK
- Use the `copilot-sdk` skill for GitHub Copilot integrations
