---
applyTo: "**/*.cs,**/*.csproj"
---

# .NET Coding Standards

## Framework
- **.NET 9** with ASP.NET Core minimal hosting model
- Use latest C# language features

## Code Quality
- **Testing**: xUnit with Test Host and Web Application Factory
- **Configuration**: Strongly-typed with `IOptions<T>` pattern and appsettings.json
- **DI**: Built-in dependency injection container with proper lifecycle management
- **Logging**: `ILogger<T>` — NEVER use `Console.WriteLine()` in production
- **Error handling**: Custom middleware for structured exception handling

## Azure Authentication
- Use `ChainedTokenCredential(AzureDeveloperCliCredential(), ManagedIdentityCredential())` from `Azure.Identity`
- NEVER use API keys — see [azure-bestpractices.md](../azure-bestpractices.md)

## Application Patterns
- Minimal hosting model with `WebApplication.CreateBuilder()`
- Middleware pipeline: Logging → Exception handling → Auth → Routing
- Health check endpoints for Container Apps orchestration
- OpenTelemetry integration with Azure Monitor
