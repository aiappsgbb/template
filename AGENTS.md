# Agents Configuration

This file defines AI agents and their capabilities for the Azure Template Project repository.

## Repository Overview

**Name**: Azure Template Project  
**Description**: A comprehensive Azure Developer CLI template for modern cloud applications with AI capabilities  
**Type**: Infrastructure Template & Development Framework  
**Maturity**: Bronze  
**Owner**: AI Apps GBB Team  

## Primary Agents

### Azure Infrastructure Architect

**Role**: Infrastructure Design & Deployment Specialist  

**Capabilities**:

- Design and optimize Azure infrastructure using Bicep templates
- Configure Container Apps environments and deployments
- Set up AI services (OpenAI, AI Search, Machine Learning)
- Implement security best practices with Key Vault and Managed Identities
- Design monitoring and logging strategies

**Context Files**:

- `infra/**/*.bicep` - Infrastructure as Code templates
- `infra/core/**/*.bicep` - Reusable Bicep modules (AVM and custom)
- `infra/abbreviations.json` - Azure resource naming conventions
- `infra/main.bicep` - Main infrastructure template
- `infra/main.parameters.json` - Environment-specific parameters
- `azure.yaml` - Azure Developer CLI configuration
- `.azure/**/*` - Environment configurations
- `.github/ip-metadata.schema.json` - IP metadata validation schema

**Specializations**:

- Azure Verified Modules (AVM) integration
- Container Apps and serverless architectures
- AI/ML infrastructure patterns
- Security and compliance configurations

### Application Developer

**Role**: Multi-Language Application Development Specialist  

**Capabilities**:

- Create Python applications using modern tooling (uv, FastAPI, Gradio, Streamlit)
- Develop Node.js/TypeScript applications with Express and React
- Build ASP.NET Core Web APIs using .NET 9 with latest language features
- Build React applications with Vite, Tailwind CSS, and Application Insights
- Implement interactive AI applications with Gradio and Streamlit
- **Create AI agents using Microsoft Agent Framework with chat, workflow, and custom patterns**
- Design RESTful APIs and microservices with comprehensive observability
- Configure CI/CD pipelines and testing frameworks
- Implement data science applications with visualization and analytics

**Context Files**:

- `src/**/*` - Application source code
- `.github/prompts/**/*.prompt.md` - Development templates and automation
- `pyproject.toml`, `package.json`, `*.csproj` - Project configurations
- `tests/**/*` - Test suites and configurations
- `azure.yaml` - Service definitions and deployment configuration
- `infra/scripts/**/*.py` - Deployment hook scripts
- `Dockerfile`, `.dockerignore` - Container configurations

**Specializations**:

- FastAPI and modern Python development with async patterns
- ASP.NET Core Web APIs with .NET 9 and latest C# language features
- Gradio and Streamlit for AI/ML application interfaces
- **Microsoft Agent Framework for conversational AI, multi-agent workflows, and custom DAG processing**
- TypeScript, Node.js, and React ecosystem with modern tooling
- React applications with Vite, Tailwind CSS, and comprehensive state management
- Data science applications with visualization and analytics
- Containerized application deployment with multi-stage Docker builds
- Testing and quality assurance with comprehensive coverage
- OpenTelemetry integration for distributed tracing and monitoring

### DevOps Engineer

**Role**: Automation & Deployment Specialist  

**Capabilities**:

- Configure Azure Developer CLI workflows
- Set up GitHub Actions for CI/CD
- Manage container registries and image deployment
- Implement infrastructure automation
- Configure monitoring and alerting

**Context Files**:

- `.github/workflows/**/*` - CI/CD pipelines
- `.github/prompts/**/*` - Automation templates
- `azure.yaml` - Deployment configuration and service definitions
- `infra/scripts/**/*.py` - AZD hook scripts for deployment automation
- `infra/core/deployment/**/*` - Deployment utilities and modules
- `.azure/env/` - Environment-specific configurations
- `infra/main.parameters.json` - Infrastructure parameters

**Specializations**:

- Azure Developer CLI (azd) workflows
- Container orchestration with Azure Container Apps
- Infrastructure as Code automation
- Multi-environment deployment strategies
- Python-based deployment hook scripts
- GitHub Actions with federated identity
- Container image management and deployment

### AI Solutions Architect

**Role**: AI/ML Integration & Optimization Specialist  

**Capabilities**:

- Design AI Foundry workspaces and projects
- Configure Azure AI Search for intelligent applications
- Implement Azure OpenAI integration patterns
- Set up ML model deployment pipelines
- Optimize AI workloads for performance and cost

**Context Files**:

- `infra/core/ai/**/*.bicep` - AI infrastructure templates and modules
- `src/**/*ai*/**/*` - AI application code and implementations
- `docs/ai-patterns.md` - AI implementation patterns and best practices
- `.github/ip-metadata.schema.json` - IP metadata schema for AI projects
- `azure.yaml` - AI service deployment configurations
- `infra/core/ai/README-azure-openai.md` - Azure OpenAI module documentation

**Specializations**:

- Azure AI Foundry platform
- Retrieval Augmented Generation (RAG) patterns
- Large Language Model integration
- AI search and knowledge mining

## Shared Context

### Repository Structure

```text
template/
├── .azure/                        # AZD environment configurations
│   ├── env/                      # Environment-specific settings
│   └── .env                      # Local environment variables
├── .github/                      # GitHub integration & automation
│   ├── prompts/                  # GitHub Copilot prompt files
│   │   ├── newPythonApp.prompt.md       # Python FastAPI app creation
│   │   ├── newNodeApp.prompt.md         # Node.js/TypeScript app creation
│   │   ├── newDotNetApp.prompt.md       # ASP.NET Core Web API app creation
│   │   ├── newReactApp.prompt.md        # React + Vite + Tailwind app creation
│   │   ├── newGradioApp.prompt.md       # Gradio AI demo app creation
│   │   ├── newStreamlitApp.prompt.md    # Streamlit data science app creation
│   │   ├── newAgentApp.prompt.md        # Microsoft Agent Framework app creation
│   │   ├── ipCompliance.prompt.md       # IP compliance validation
│   │   ├── setupInfra.prompt.md         # Infrastructure setup
│   │   ├── addAzdService.prompt.md      # Service addition to azd
│   │   └── newReadme.prompt.md          # README generation
│   ├── workflows/                # CI/CD pipelines
│   │   └── azure-infra.yml       # Unified deployment workflow
│   ├── ip-metadata.json          # Intellectual Property metadata
│   ├── ip-metadata.schema.json   # IP metadata validation schema
│   └── copilot-instructions.md   # Copilot configuration
├── docs/                         # Documentation
│   └── ARCHITECTURE.md          # System architecture documentation
├── infra/                        # Infrastructure as Code (Bicep)
│   ├── abbreviations.json        # Azure resource abbreviations
│   ├── main.bicep                # Main infrastructure template
│   ├── main.parameters.json      # Environment parameters
│   ├── core/                     # Reusable Bicep modules
│   │   ├── ai/                   # AI service modules
│   │   │   ├── ai-foundry.bicep         # Azure AI Foundry workspace
│   │   │   ├── ai-search.bicep          # Azure AI Search service
│   │   │   ├── azure-openai.bicep       # Azure OpenAI (new/existing)
│   │   │   └── README-azure-openai.md   # OpenAI module documentation
│   │   ├── database/             # Database modules
│   │   │   └── cosmos-db.bicep          # Azure Cosmos DB
│   │   ├── deployment/           # Deployment utilities
│   │   │   ├── import-images-to-acr.bicep    # Container image import
│   │   │   └── fetch-container-image.bicep   # Image fetching utility
│   │   ├── host/                 # Hosting modules
│   │   │   ├── container-app.bicep           # Azure Container Apps
│   │   │   ├── container-apps-environment.bicep  # Container Apps Environment
│   │   │   └── fetch-container-image.bicep   # Container image management
│   │   ├── monitor/              # Monitoring modules
│   │   │   └── monitoring.bicep         # Application Insights & Log Analytics
│   │   ├── security/             # Security modules
│   │   │   ├── keyvault.bicep           # Azure Key Vault
│   │   │   └── user-assigned-identity.bicep  # Managed Identity
│   │   └── storage/              # Storage modules
│   │       ├── container-registry.bicep     # Azure Container Registry
│   │       └── storage-account.bicep        # Azure Storage Account
│   ├── data/                     # Data and sample files
│   │   └── README.md
│   └── scripts/                  # AZD hook scripts (Python-based)
│       ├── pyproject.toml        # Python dependencies for hooks
│       ├── utils.py              # Shared utilities for hooks
│       ├── preprovision.py       # Pre-provision hook (validate env)
│       ├── postprovision.py      # Post-provision hook (configure resources)
│       ├── predeploy.py          # Pre-deploy hook (prepare deployments)
│       └── postdeploy.py         # Post-deploy hook (finalization)
├── schemas/                      # JSON schemas (moved to .github/)
├── src/                          # Application source code
│   └── README.md                # Application development guide
├── tests/                        # Test suites
├── assets/                       # Static assets and documentation
│   └── README.md
├── azure.yaml                    # Azure Developer CLI configuration
├── .gitignore                   # Git ignore patterns
├── LICENSE                      # License file
├── README.md                    # Main project documentation
└── AGENTS.md                    # AI agent configuration (this file)
```

### Key Technologies

- **Infrastructure**: Azure Bicep, Azure Developer CLI
- **Containers**: Azure Container Apps, Azure Container Registry
- **AI/ML**: Azure AI Foundry, Azure OpenAI, Azure AI Search
- **Data**: Azure Cosmos DB, Azure Storage
- **Security**: Azure Key Vault, Managed Identities
- **Monitoring**: Azure Monitor, Application Insights, OpenTelemetry
- **Development**:
  - **Python**: uv package manager, FastAPI, Gradio, Streamlit, pytest
  - **Node.js/TypeScript**: npm, Express, React, Vite, Jest, Vitest
  - **.NET**: .NET 9 SDK, ASP.NET Core, Entity Framework Core, xUnit
  - **Frontend**: React, Vite, Tailwind CSS, Application Insights React plugin
  - **AI/ML Interfaces**: Gradio for demos, Streamlit for data science
  - **AI Agents**: Microsoft Agent Framework for conversational AI and workflows
- **Build Tools**: Docker multi-stage builds, Azure Linux base images
- **Testing**: Comprehensive test coverage with framework-specific tools

### Infrastructure as Code (Bicep) Best Practices

**Template Organization**:

- **Modular Design**: Use `infra/core/` modules for reusability across projects
- **Azure Verified Modules (AVM)**: Prefer AVM modules when available for standard resources
- **Resource Naming**: Follow Azure naming conventions using `abbreviations.json`
- **Parameter Management**: Use `main.parameters.json` for environment-specific values
- **Output Definitions**: Always define outputs for resource integration points

**Security & Compliance**:

- **Managed Identities**: Use User Assigned Managed Identity for all Azure authentication
- **RBAC Configuration**: Implement least privilege access with proper role assignments
- **Secret Management**: Store secrets in Azure Key Vault, never in templates
- **Network Security**: Configure appropriate network access controls
- **Resource Tags**: Apply consistent tagging for governance and cost tracking

**Module Standards**:

- **Parameter Validation**: Use decorators for input validation (@minLength, @allowed)
- **Resource Dependencies**: Properly define dependencies between resources
- **Conditional Logic**: Use conditions for optional features (existing vs new resources)
- **Cross-Resource Group**: Support resources in different resource groups when needed
- **Documentation**: Include comprehensive README files for complex modules

**Template Structure**:

```bicep
// Standard module structure
targetScope = 'resourceGroup'

// Parameters with validation
@description('Resource name')
param name string

@description('Location for resources')
param location string = resourceGroup().location

// Variables for computed values
var resourceName = '${name}-${uniqueString(resourceGroup().id)}'

// Resources using AVM or custom modules
module exampleResource 'br/public:avm/res/web/site:0.3.0' = {
  name: 'example'
  params: {
    name: resourceName
    location: location
    // Additional parameters
  }
}

// Outputs for integration
output resourceId string = exampleResource.outputs.resourceId
output resourceName string = exampleResource.outputs.name
```

### Azure Developer CLI (azd) Configuration

**azure.yaml Structure**:

- **Metadata Section**: Template information and version
- **Services Configuration**: Container apps with proper language and host settings
- **Environment Variables**: Centralized configuration for all services
- **Docker Configuration**: Remote builds enabled for all containerized services
- **Hook Scripts**: Python-based automation for deployment lifecycle

**Hook Scripts Architecture**:

- **Python-based**: All hooks use Python with shared utilities in `infra/scripts/`
- **Dependency Management**: `pyproject.toml` manages hook script dependencies
- **Shared Utilities**: `utils.py` provides common functions for logging, Azure CLI, etc.
- **Environment Validation**: Scripts validate prerequisites and configuration
- **Resource Configuration**: Post-provision hooks configure deployed resources

**Hook Script Execution Order**:

1. **preprovision.py**: Validate environment, check prerequisites, prepare for deployment
2. **Infrastructure Provision**: Azure resources are created via Bicep templates
3. **postprovision.py**: Configure deployed resources, set up RBAC, initialize services
4. **predeploy.py**: Prepare application deployments, validate configurations
5. **Application Deploy**: Container images are built and deployed
6. **postdeploy.py**: Finalize deployment, run smoke tests, output endpoints

**Hook Script Best Practices**:

- **Logging**: Use Python logging module with structured output
- **Error Handling**: Proper exception handling with meaningful error messages
- **Idempotency**: Scripts should be safe to run multiple times
- **Environment Variables**: Access azd environment variables via `os.environ`
- **Azure CLI Integration**: Use subprocess or azure-cli-core for Azure operations
- **Validation**: Check resource states before making changes
- **Documentation**: Clear docstrings and inline comments

**Example Hook Script Pattern**:

```python
#!/usr/bin/env python3
import logging
import os
from utils import setup_logging, run_command, get_azd_env

def main():
    """Post-provision hook to configure deployed resources."""
    setup_logging()
    logger = logging.getLogger(__name__)
    
    try:
        # Get environment variables from azd
        env_vars = get_azd_env()
        resource_group = env_vars.get('AZURE_RESOURCE_GROUP')
        
        # Configure deployed resources
        configure_monitoring(resource_group)
        setup_rbac_permissions(resource_group)
        
        logger.info('Post-provision configuration completed successfully')
        
    except Exception as e:
        logger.error(f'Post-provision hook failed: {e}')
        raise

if __name__ == '__main__':
    main()
```

### Application Development Patterns

**Python Applications**:

- **FastAPI Services**: Production-ready APIs with uvicorn (dev) and gunicorn (production)
- **Gradio Applications**: Interactive AI demos with custom components and authentication
- **Streamlit Applications**: Multi-page data science applications with real-time visualization
- **Agent Framework Applications**: Conversational AI agents, multi-agent workflows, and custom DAG processing
- **Configuration**: pydantic-settings with environment variable management
- **Package Management**: uv for fast dependency installation and virtual environment management

**Node.js/TypeScript Applications**:

- **Express Services**: RESTful APIs with comprehensive middleware and error handling
- **React Applications**: Modern frontends with Vite, Tailwind CSS, and Context API
- **Configuration**: Environment-based configuration with type-safe interfaces
- **Package Management**: npm with proper dependency version management
- **Build Tools**: Vite for fast development and optimized production builds

**.NET Applications**:

- **ASP.NET Core Web APIs**: Production-ready APIs with minimal hosting model and dependency injection
- **Configuration**: Strongly-typed configuration with IOptions pattern and appsettings.json
- **Middleware Pipeline**: Custom middleware for logging, exception handling, and request processing
- **Dependency Injection**: Built-in DI container with service registration and lifecycle management
- **Testing**: Unit and integration testing with xUnit, Test Host, and Web Application Factory

**Common Patterns Across All Applications**:

- **Authentication**: ChainedTokenCredential for seamless local/production authentication
- **Observability**: OpenTelemetry tracing with Azure Monitor integration
- **Configuration**: Environment-based configuration with proper type validation
- **Error Handling**: Structured error responses with appropriate HTTP status codes
- **Health Checks**: Container-ready health endpoints for orchestration
- **API Integration**: HTTPx (Python) or axios (Node.js) with proper retry logic

**AI/ML Integration Patterns**:

- **Azure OpenAI**: Consistent client configuration across all application types
- **Microsoft Agent Framework**: Chat agents, multi-agent workflows, and custom executors
- **Agent Tools**: Function calling, file search, code interpretation, and custom tools
- **Agent Middleware**: Security, logging, telemetry, and custom processing pipelines
- **Streaming Responses**: Real-time AI responses in chat interfaces
- **Context Management**: Conversation state management and history
- **File Processing**: Secure file upload and AI-powered analysis
- **Visualization**: Interactive charts and real-time data updates

### Development Standards

**Code Quality & Type Safety**:

- **Linting & Formatting**: ESLint/Prettier for TypeScript, Ruff/Black for Python
- **Type Safety**: Comprehensive TypeScript usage, Python type hints throughout
- **Testing**: Jest (Node.js/React), pytest (Python), Vitest (Vite), comprehensive coverage
- **Code Structure**: Modular architecture with clear separation of concerns
- **Dependency Management**: Safe version pinning with >= and < operators to prevent major version upgrades

**Security & Authentication**:

- **Azure Authentication**: ChainedTokenCredential pattern (AzureDeveloperCliCredential + ManagedIdentityCredential)
- **Environment Variables**: Always include AZURE_CLIENT_ID for managed identity authentication
- **Input Validation**: Comprehensive validation and sanitization for all user inputs
- **SAST/DAST**: Security scanning and vulnerability assessment
- **Credential Management**: Never hardcode secrets, use Azure Key Vault integration
- **Zero API Keys**: **NEVER use API keys for Azure services** - follow [Azure Best Practices](../.github/azure-bestpractices.md)

**Logging & Observability**:

- **Structured Logging**: Python logging module, Winston for Node.js, never use print() or console.log()
- **Log Levels**: Appropriate use of DEBUG, INFO, WARNING, ERROR, CRITICAL levels
- **JSON Format**: Structured logging for production environments
- **OpenTelemetry**: Distributed tracing with Azure Monitor integration
- **Performance Monitoring**: Application Insights integration for all applications

**Containerization & Deployment**:

- **Multi-stage Builds**: Optimized Dockerfiles with Azure Linux base images
- **Non-root Users**: Security-first container configurations
- **Health Checks**: Proper container health monitoring
- **Port Configuration**: Port 80 for Azure Container Apps deployment
- **Resource Optimization**: Appropriate CPU and memory allocation

**Documentation & Compliance**:

- **Comprehensive README**: Setup, configuration, deployment instructions
- **Inline Documentation**: Clear comments and docstrings
- **Architecture Diagrams**: Visual representation of system design
- **API Documentation**: OpenAPI/Swagger documentation where applicable
- **IP Compliance**: Validation against .github/ip-metadata.schema.json

## Agent Collaboration Patterns

### Infrastructure + Application Development

- Infrastructure Architect designs the foundation
- Application Developer implements business logic
- Coordination through shared configuration files

### DevOps + All Agents

- DevOps Engineer provides automation frameworks
- All agents contribute to deployment configurations
- Shared responsibility for CI/CD pipeline maintenance

### AI Solutions + Infrastructure

- AI Solutions Architect defines AI service requirements
- Infrastructure Architect implements the underlying platform
- Collaborative optimization of AI workload performance

## Fine-Tuning Objectives

### Primary Goals

1. **Template Optimization**: Improve reusability and maintainability
2. **Security Enhancement**: Strengthen security configurations and practices
3. **Performance Tuning**: Optimize resource allocation and cost efficiency
4. **AI Integration**: Enhance AI service integration patterns
5. **Developer Experience**: Streamline development workflows

### Success Metrics

- Deployment success rate (target: >95%)
- Security scan pass rate (target: 100%)
- Developer onboarding time (target: <30 minutes)
- Infrastructure cost optimization (target: 20% reduction)
- AI service response time (target: <2 seconds)

### Feedback Mechanisms

- Automated testing and validation
- Security compliance checks
- Performance monitoring and alerting
- Developer feedback collection
- Usage analytics and optimization

## Agent Training Data

### Preferred Patterns

- Modern cloud-native architectures
- Infrastructure as Code best practices
- Security-first design principles
- AI-powered application patterns
- Multi-language development approaches
- Structured logging with Python logging module
- Proper exception handling with stack traces

### Anti-Patterns to Avoid

- Hard-coded credentials or secrets
- Over-provisioned resources
- Monolithic architectures
- Insecure network configurations
- Manual deployment processes
- Using print() statements instead of logging module
- Unstructured or missing error logging

### Learning Sources

- Azure Well-Architected Framework
- Azure Verified Modules documentation
- Microsoft Learn content
- Community best practices
- Security benchmarks and standards

---

*This AGENTS.md file enables AI agents to understand the repository structure, collaborate effectively, and contribute to the continuous improvement of the Azure Template Project.*
