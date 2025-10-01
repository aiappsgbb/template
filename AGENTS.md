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
- `azure.yaml` - Azure Developer CLI configuration
- `.azure/**/*` - Environment configurations
- `schemas/ip-metadata.schema.json` - Metadata schema

**Specializations**:

- Azure Verified Modules (AVM) integration
- Container Apps and serverless architectures
- AI/ML infrastructure patterns
- Security and compliance configurations

### Application Developer

**Role**: Multi-Language Application Development Specialist  

**Capabilities**:

- Create Python applications using modern tooling (uv, FastAPI)
- Develop Node.js/TypeScript applications with Express
- Implement C#/.NET applications following best practices
- Design RESTful APIs and microservices
- Configure CI/CD pipelines and testing frameworks

**Context Files**:

- `src/**/*` - Application source code
- `.github/prompts/**/*.prompt.md` - Development templates
- `pyproject.toml`, `package.json`, `*.csproj` - Project configurations
- `tests/**/*` - Test suites and configurations

**Specializations**:

- FastAPI and modern Python development
- TypeScript and Node.js ecosystem
- Containerized application deployment
- Testing and quality assurance

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
- `azure.yaml` - Deployment configuration
- `infra/core/deployment/**/*` - Deployment utilities

**Specializations**:

- Azure Developer CLI (azd) workflows
- Container orchestration with Azure Container Apps
- Infrastructure as Code automation
- Multi-environment deployment strategies

### AI Solutions Architect

**Role**: AI/ML Integration & Optimization Specialist  

**Capabilities**:

- Design AI Foundry workspaces and projects
- Configure Azure AI Search for intelligent applications
- Implement Azure OpenAI integration patterns
- Set up ML model deployment pipelines
- Optimize AI workloads for performance and cost

**Context Files**:

- `infra/core/ai/**/*.bicep` - AI infrastructure templates
- `src/**/*ai*/**/*` - AI application code
- `docs/ai-patterns.md` - AI implementation patterns
- `schemas/**/*` - Data and model schemas

**Specializations**:

- Azure AI Foundry platform
- Retrieval Augmented Generation (RAG) patterns
- Large Language Model integration
- AI search and knowledge mining

## Shared Context

### Repository Structure

```text
template/
├── .azure/                 # AZD environment configs
├── .github/               # GitHub workflows & prompts
│   ├── prompts/          # Copilot prompt files
│   └── workflows/        # CI/CD pipelines
├── docs/                 # Documentation
├── infra/                # Infrastructure as Code
│   ├── core/            # Reusable Bicep modules
│   └── main.bicep       # Main infrastructure template
├── schemas/              # JSON schemas
├── src/                 # Application source code
├── tests/               # Test suites
├── azure.yaml           # AZD configuration
└── ip-metadata.json     # IP metadata
```

### Key Technologies

- **Infrastructure**: Azure Bicep, Azure Developer CLI
- **Containers**: Azure Container Apps, Azure Container Registry
- **AI/ML**: Azure AI Foundry, Azure OpenAI, Azure AI Search
- **Data**: Azure Cosmos DB, Azure Storage
- **Security**: Azure Key Vault, Managed Identities
- **Monitoring**: Azure Monitor, Application Insights
- **Development**: Python (uv), Node.js/TypeScript, C#/.NET

### Development Standards

- **Code Quality**: Linting, formatting, type checking
- **Testing**: Unit, integration, and end-to-end tests
- **Security**: SAST/DAST scanning, credential management
- **Documentation**: Inline comments, README files, architecture diagrams

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

### Anti-Patterns to Avoid

- Hard-coded credentials or secrets
- Over-provisioned resources
- Monolithic architectures
- Insecure network configurations
- Manual deployment processes

### Learning Sources

- Azure Well-Architected Framework
- Azure Verified Modules documentation
- Microsoft Learn content
- Community best practices
- Security benchmarks and standards

---

*This AGENTS.md file enables AI agents to understand the repository structure, collaborate effectively, and contribute to the continuous improvement of the Azure Template Project.*
