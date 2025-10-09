---
mode: 'agent'
model: Claude Sonnet 4 (copilot)
tools: ['githubRepo', 'search/codebase', 'edit', 'changes', 'git_branch', 'runCommands']
description: 'Create a new ASP.NET Core Web API application using .NET 9 following best practices and a simplified structure.'
---

# Create New ASP.NET Core Web API Application

- Create a new ASP.NET Core Web API application using .NET 9 under the src folder with a simplified structure.
- Ensure you create a new branch for this work with naming feature/add-${input:appName:my-dotnet-app}
- Make sure to use all the provided tools to actually create folders and files with the required content.

**Application Name**: ${input:appName:my-dotnet-app}

## Directory Structure

Create the following directory structure:

```text
src/
├── ${input:appName}/
│   ├── ${input:appName}.csproj
│   ├── README.md
│   ├── global.json
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── appsettings.json
│   ├── appsettings.Development.json
│   ├── Program.cs
│   ├── Controllers/
│   │   └── HealthController.cs
│   ├── Services/
│   │   ├── IHealthService.cs
│   │   └── HealthService.cs
│   ├── Models/
│   │   ├── HealthResponse.cs
│   │   └── ApiResponse.cs
│   ├── Configuration/
│   │   ├── AppSettings.cs
│   │   └── AzureSettings.cs
│   ├── Extensions/
│   │   ├── ServiceCollectionExtensions.cs
│   │   └── ApplicationBuilderExtensions.cs
│   ├── Middleware/
│   │   ├── ExceptionHandlingMiddleware.cs
│   │   └── RequestLoggingMiddleware.cs
│   └── Utils/
│       ├── AzureCredentialHelper.cs
│       └── LoggingHelper.cs
```

## File Requirements

### 1. ${input:appName}.csproj

Generate a `.csproj` file with:

- Project metadata targeting .NET 9.0
- Enable latest C# language features and nullable reference types
- Package references with safe version pinning (no major version upgrades):
  - Microsoft.AspNetCore.OpenApi>=9.0.0,<10.0.0
  - Swashbuckle.AspNetCore>=7.0.0,<8.0.0
  - Serilog.AspNetCore>=8.0.0,<9.0.0 (structured logging)
  - Serilog.Sinks.Console>=6.0.0,<7.0.0, Serilog.Sinks.File>=6.0.0,<7.0.0
- Azure integration packages:
  - Azure.Identity>=1.12.0,<2.0.0
  - Azure.Monitor.OpenTelemetry.AspNetCore>=1.2.0,<2.0.0
- OpenTelemetry packages:
  - OpenTelemetry.Extensions.Hosting>=1.9.0,<2.0.0
  - OpenTelemetry.Instrumentation.AspNetCore>=1.9.0,<2.0.0
  - OpenTelemetry.Instrumentation.Http>=1.9.0,<2.0.0
- Development packages: Microsoft.AspNetCore.Mvc.Testing>=9.0.0,<10.0.0, xunit>=2.9.0,<3.0.0, xunit.runner.visualstudio>=2.8.0,<3.0.0

Example .csproj:
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <LangVersion>latest</LangVersion>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <DockerDefaultTargetOS>Linux</DockerDefaultTargetOS>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="9.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="7.0.0" />
    <PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
    <PackageReference Include="Azure.Identity" Version="1.12.0" />
    <PackageReference Include="Azure.Monitor.OpenTelemetry.AspNetCore" Version="1.2.0" />
  </ItemGroup>

</Project>
```

### 2. global.json

Create a `global.json` file specifying .NET 9.0 SDK:

```json
{
  "sdk": {
    "version": "9.0.100",
    "rollForward": "latestMinor"
  }
}
```

### 3. Program.cs

Generate a `Program.cs` file using .NET 9 features with:

- Minimal API setup with top-level statements
- Configuration management with strongly-typed settings
- Dependency injection container configuration
- Serilog structured logging integration
- OpenTelemetry tracing configuration
- Exception handling middleware
- Health check endpoints
- Swagger/OpenAPI documentation
- CORS configuration
- Azure Monitor integration
- Production-ready settings

Example Program.cs structure:
```csharp
using Serilog;
using Azure.Monitor.OpenTelemetry.AspNetCore;
using MyDotNetApp.Configuration;
using MyDotNetApp.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
builder.Host.UseSerilog((context, configuration) =>
    configuration.ReadFrom.Configuration(context.Configuration));

// Configure strongly-typed settings
builder.Services.Configure<AppSettings>(builder.Configuration);
builder.Services.Configure<AzureSettings>(builder.Configuration.GetSection("Azure"));

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add custom services
builder.Services.AddApplicationServices();

// Add Azure Monitor OpenTelemetry
builder.Services.AddOpenTelemetry()
    .UseAzureMonitor();

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseExceptionHandling();
app.UseRequestLogging();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
```

### 4. Dockerfile

Create a multi-stage Dockerfile optimized for ASP.NET Core with:

- Multi-stage build for smaller production images
- .NET 9.0 runtime and SDK images (use Azure Linux base)
- Proper layer caching
- Non-root user for security
- Health check configuration
- Production-ready settings

```dockerfile
# Dockerfile structure for ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:9.0-azurelinux3.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Install CA certificates
RUN tdnf install -y ca-certificates && \
    update-ca-trust enable && \
    update-ca-trust extract && \
    tdnf clean all

FROM mcr.microsoft.com/dotnet/sdk:9.0-azurelinux3.0 AS build
WORKDIR /src
COPY ["${input:appName}.csproj", "."]
RUN dotnet restore "${input:appName}.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "${input:appName}.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "${input:appName}.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

ENTRYPOINT ["dotnet", "${input:appName}.dll"]
```

### 5. .dockerignore

Create a `.dockerignore` file to exclude:

- Development files (.git, .vs, .vscode, etc.)
- Build artifacts (bin/, obj/, etc.)
- Test files and documentation
- IDE configuration files
- OS-specific files
- Package files (*.nupkg)

### 6. Configuration/AppSettings.cs

Create a strongly-typed configuration class using .NET 9 features:

```csharp
namespace MyDotNetApp.Configuration;

public record AppSettings
{
    public string ApplicationName { get; init; } = string.Empty;
    public string Version { get; init; } = "1.0.0";
    public LoggingSettings Logging { get; init; } = new();
    public AzureSettings Azure { get; init; } = new();
}

public record LoggingSettings
{
    public string LogLevel { get; init; } = "Information";
    public bool EnableConsoleLogging { get; init; } = true;
    public bool EnableFileLogging { get; init; } = false;
    public string LogFilePath { get; init; } = "logs/app.log";
}

public record AzureSettings
{
    public string? ClientId { get; init; }
    public string? TenantId { get; init; }
    public string? KeyVaultEndpoint { get; init; }
    public string? ApplicationInsightsConnectionString { get; init; }
}
```

### 7. Utils/AzureCredentialHelper.cs

Create an Azure credential helper using best practices:

```csharp
using Azure.Identity;

namespace MyDotNetApp.Utils;

public static class AzureCredentialHelper
{
    /// <summary>
    /// Get Azure credential using best practice chain.
    /// This works for both local development (azd) and production (Container Apps).
    /// </summary>
    /// <returns>
    /// ChainedTokenCredential that tries Azure Developer CLI first, then Managed Identity.
    /// </returns>
    public static ChainedTokenCredential GetAzureCredential()
    {
        return new ChainedTokenCredential(
            new AzureDeveloperCliCredential(), // tries Azure Developer CLI (azd) for local development
            new ManagedIdentityCredential()    // fallback to managed identity for production
        );
    }

    /// <summary>
    /// Get Azure credential with specific client ID for managed identity.
    /// Use when AZURE_CLIENT_ID environment variable is set.
    /// </summary>
    /// <param name="clientId">The client ID of the managed identity</param>
    /// <returns>ChainedTokenCredential with specified client ID</returns>
    public static ChainedTokenCredential GetAzureCredential(string clientId)
    {
        return new ChainedTokenCredential(
            new AzureDeveloperCliCredential(),
            new ManagedIdentityCredential(clientId)
        );
    }
}
```

**Important**: Always ensure `AZURE_CLIENT_ID` environment variable is set in Azure Container Apps to specify which managed identity to use for authentication.

### 8. Extensions/ServiceCollectionExtensions.cs

Create service registration extensions:

```csharp
using MyDotNetApp.Services;

namespace MyDotNetApp.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register application services
        services.AddScoped<IHealthService, HealthService>();
        
        // Add HTTP client with Azure authentication
        services.AddHttpClient();
        
        // Add Azure credential helper
        services.AddSingleton(_ => AzureCredentialHelper.GetAzureCredential());
        
        return services;
    }
}
```

### 9. Middleware/ExceptionHandlingMiddleware.cs

Create global exception handling middleware:

```csharp
using System.Net;
using System.Text.Json;
using MyDotNetApp.Models;

namespace MyDotNetApp.Middleware;

public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var response = new ApiResponse<object>
        {
            Success = false,
            Message = "An error occurred while processing your request",
            Data = null
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = exception switch
        {
            ArgumentException => (int)HttpStatusCode.BadRequest,
            UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
            NotImplementedException => (int)HttpStatusCode.NotImplemented,
            _ => (int)HttpStatusCode.InternalServerError
        };

        var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(jsonResponse);
    }
}
```

### 10. Controllers/HealthController.cs

Create a health check controller:

```csharp
using Microsoft.AspNetCore.Mvc;
using MyDotNetApp.Models;
using MyDotNetApp.Services;

namespace MyDotNetApp.Controllers;

[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class HealthController(IHealthService healthService, ILogger<HealthController> logger) : ControllerBase
{
    /// <summary>
    /// Get application health status
    /// </summary>
    /// <returns>Health status information</returns>
    [HttpGet]
    [ProducesResponseType<ApiResponse<HealthResponse>>(StatusCodes.Status200OK)]
    public async Task<ActionResult<ApiResponse<HealthResponse>>> GetHealth()
    {
        logger.LogInformation("Health check requested");
        
        var healthResponse = await healthService.GetHealthAsync();
        
        return Ok(new ApiResponse<HealthResponse>
        {
            Success = true,
            Message = "Health check completed",
            Data = healthResponse
        });
    }
}
```

### 11. Models/ApiResponse.cs

Create standard API response models:

```csharp
namespace MyDotNetApp.Models;

public record ApiResponse<T>
{
    public bool Success { get; init; }
    public string Message { get; init; } = string.Empty;
    public T? Data { get; init; }
    public DateTime Timestamp { get; init; } = DateTime.UtcNow;
}

public record HealthResponse
{
    public string Status { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public DateTime Timestamp { get; init; } = DateTime.UtcNow;
    public Dictionary<string, object> Details { get; init; } = new();
}
```

### 12. appsettings.json

Create application configuration:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ApplicationName": "${input:appName}",
  "Version": "1.0.0",
  "Azure": {
    "ApplicationInsightsConnectionString": "",
    "KeyVaultEndpoint": "",
    "ClientId": ""
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.Hosting.Lifetime": "Information"
      }
    },
    "WriteTo": [
      {
        "Name": "Console",
        "Args": {
          "outputTemplate": "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}"
        }
      }
    ],
    "Enrich": ["FromLogContext", "WithMachineName", "WithThreadId"]
  }
}
```

### 13. README.md

Create a comprehensive `README.md` for the ASP.NET Core app with:

- Project description
- Prerequisites (.NET 9.0 SDK, Docker, Azure Application Insights)
- Installation and setup instructions
- Development workflow
- Running the application (local and Docker)
- Docker build and run instructions
- Configuration options (including Azure Monitor setup)
- API documentation and endpoints
- Testing instructions
- Container deployment guidance
- Monitoring and observability setup
- Azure Application Insights configuration

### 14. Azure Developer CLI Configuration

Update the root `azure.yaml` file to include the new ASP.NET Core application as a service:

- Add a new service entry under the `services` section
- Configure the service with:
  - Service name: "${input:appName}"
  - Language: dotnet
  - Host: containerapp
  - Docker configuration with:
    - Remote builds enabled: `remoteBuild: true`
  - Environment variables for Azure Monitor integration
  - **Critical**: Always include `AZURE_CLIENT_ID` environment variable for managed identity authentication
- Ensure proper service dependencies if needed
- Configure resource group and location references
- Add any required environment-specific configurations

Example service configuration:
```yaml
services:
  ${input:appName}:
    project: "./src/${input:appName}"
    language: dotnet
    host: containerapp
    docker:
      remoteBuild: true
```

### 15. Infrastructure Configuration

Update the `infra/main.bicep` file to include a new container app module for the ASP.NET Core application:

- Add a new module declaration using the `infra/core/host/container-app.bicep` template
- Configure the module with:
  - Unique name for the container app (based on app name and environment)
  - Location parameter reference
  - Tags from the main template
  - Container Apps Environment ID reference
  - Container Registry name reference
  - User Assigned Identity ID for ACR access
  - Managed Identity Principal ID for RBAC
  - GitHub Actions parameter for deployment context
  - Container image parameter (will be updated during deployment)
  - Environment variables specific to the ASP.NET Core application
  - Resource allocation (CPU and memory)
  - Container port (80 for Azure Container Apps)

Example module configuration:
```bicep
// ${input:appName} ASP.NET Core Application
module ${input:appName}App 'core/host/container-app.bicep' = {
  name: '${input:appName}-app'
  params: {
    name: '${abbrs.appContainerApps}${input:appName}-${environmentName}'
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    userAssignedIdentityId: userAssignedIdentity.outputs.id
    managedIdentityPrincipalId: principalId
    githubActions: githubActions
    containerImage: ${input:appName}AppImage
    containerPort: 80
    environmentVariables: [
      {
        name: 'AZURE_CLIENT_ID'
        value: userAssignedIdentity.outputs.clientId
      }
      {
        name: 'APPLICATION_INSIGHTS_CONNECTION_STRING'
        value: monitoring.outputs.applicationInsightsConnectionString
      }
      {
        name: 'AZURE_KEY_VAULT_ENDPOINT'
        value: keyVault.outputs.endpoint
      }
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
      {
        name: 'ASPNETCORE_URLS'
        value: 'http://+:80'
      }
      {
        name: 'Logging__LogLevel__Default'
        value: 'Information'
      }
    ]
    resources: {
      cpu: 1
      memory: '2Gi'
    }
  }
}
```

- Add a parameter for the container image at the top of main.bicep:
```bicep
@description('Container image for ${input:appName} ASP.NET Core application')
param ${input:appName}AppImage string = 'mcr.microsoft.com/k8se/quickstart:latest'
```

- Add output values for the new container app:
```bicep
// ${input:appName} App Outputs
output ${upper(replace("${input:appName}", '-', '_'))}_APP_ENDPOINT string = ${input:appName}App.outputs.fqdn
output ${upper(replace("${input:appName}", '-', '_'))}_APP_NAME string = ${input:appName}App.outputs.name
output ${upper(replace("${input:appName}", '-', '_'))}_APP_ID string = ${input:appName}App.outputs.id
```

## Technical Requirements

- Use .NET 9.0 with latest C# language features and syntax
- Follow ASP.NET Core best practices and conventions
- Implement proper configuration management with strongly-typed settings
- Include comprehensive XML documentation throughout
- Production-ready error handling and middleware
- Environment-based configuration with appsettings files
- Clean, maintainable code structure with SOLID principles
- Docker containerization ready for Azure Container Apps
- Multi-stage builds for optimization
- Security best practices (non-root user, HTTPS, proper authentication)
- Proper logging configuration using Serilog (never use Console.WriteLine)
- Structured logging with JSON format for production environments
- Azure Monitor integration via OpenTelemetry
- Distributed tracing for microservices architecture
- Observability and monitoring ready with health checks
- Performance tracking and metrics collection
- Safe dependency versioning (use >= and < operators to prevent major version upgrades)
- Comprehensive API documentation with Swagger/OpenAPI
- Nullable reference types enabled for better null safety
- Global error handling with proper HTTP status codes
- Dependency injection best practices
- Async/await patterns throughout
- Unit testing support with xUnit
- Integration testing capabilities
- CORS configuration for cross-origin requests
- Health check endpoints for container orchestration