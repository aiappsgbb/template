# Azure Developer CLI Template

This is a generic Azure Developer CLI (azd) template that can be customized for various Azure projects.

## Getting Started

### Prerequisites

- [Azure Developer CLI](https://aka.ms/azd-install)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Azure subscription

### Initialize the project

1. Clone this repository or use it as a template
1. Navigate to the project directory
1. Initialize a new azd environment:

```bash
azd init
```

1. Set your environment variables by copying the example file:

```bash
cp .env.example .env
```

Edit the `.env` file with your specific configuration.

### Deploy to Azure

1. Provision the Azure resources:

```bash
azd provision
```

1. Deploy your application (if applicable):

```bash
azd deploy
```

1. Or do both in one command:

```bash
azd up
```

## GitHub Actions Setup

This template includes automated CI/CD workflows for Azure deployment. To enable them:

### 1. Configure Repository Secrets

Add these secrets in your GitHub repository settings:

- `AZURE_CLIENT_ID` - Service Principal Client ID
- `AZURE_TENANT_ID` - Azure Tenant ID  
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
- `AZURE_PRINCIPAL_ID` - Service Principal Object ID

### 2. Configure Environment Variables

For each environment (dev, staging, prod), set these variables:

- `AZURE_ENV_NAME` - Environment name
- `AZURE_LOCATION` - Azure region (e.g., eastus2)
- `AZD_INITIAL_ENVIRONMENT_CONFIG` - (Optional) Additional azd configuration as JSON

### 3. Service Principal Setup

```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac --name "gh-actions-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --json-auth

# Configure federated identity for GitHub Actions
az ad app federated-credential create \
  --id {client-id} \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:{org}/{repo}:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Available Workflows

- **Azure Deploy**: Full infrastructure + application deployment
- **Azure Infrastructure**: Infrastructure validation and provisioning only

Both workflows support:

- Manual dispatch with environment selection
- Custom AZD configuration via `azd_config` input parameter
- Environment-specific variables and secrets

#### Custom AZD Configuration

You can provide additional configuration during deployment using the `AZD_INITIAL_ENVIRONMENT_CONFIG` environment variable or the `azd_config` workflow input:

```json
{
  "AZURE_OPENAI_RESOURCE_GROUP": "my-openai-rg",
  "AZURE_OPENAI_SERVICE": "my-openai-service",
  "AZURE_SEARCH_SERVICE": "my-search-service",
  "CUSTOM_DOMAIN": "myapp.contoso.com"
}
```

This allows you to customize resource names, configuration values, and other parameters without modifying the Bicep templates.

## GitHub Copilot Prompts

Available automation prompts in `.github/prompts/`:

- `@workspace /newPythonApp` - Create Python FastAPI application
- `@workspace /newNodeApp` - Create Node.js/TypeScript application  
- `@workspace /setupInfra` - Configure infrastructure templates
- `@workspace /newReadme` - Generate comprehensive README
- `@workspace /newIPMetadata` - Create IP metadata file

## Project Structure

```text
├── .azure/                 # Azure Developer CLI environment configuration
├── infra/                  # Infrastructure as Code (Bicep templates)
│   ├── core/              # Reusable Bicep modules
│   │   ├── ai/            # AI services (AI Foundry, AI Search)
│   │   ├── database/      # Database resources (Cosmos DB)
│   │   ├── deployment/    # Deployment utilities (ACR image import)
│   │   ├── host/          # Hosting resources (Container Apps)
│   │   ├── monitor/       # Monitoring (Application Insights, Log Analytics)
│   │   ├── security/      # Security resources (Key Vault, Managed Identity)
│   │   └── storage/       # Storage resources (Storage Account, ACR)
│   ├── main.bicep         # Main infrastructure template
│   ├── main.parameters.json # Bicep parameters file for azd
│   └── abbreviations.json # Azure resource naming abbreviations
├── azure.yaml             # Azure Developer CLI project configuration
├── ip-metadata.json       # Intellectual Property metadata
├── schemas/               # JSON schemas for validation
│   └── ip-metadata.schema.json
├── AGENTS.md              # AI agent configuration for fine-tuning
├── .github/               # GitHub workflows and prompts
│   ├── workflows/         # CI/CD pipelines
│   └── prompts/           # Copilot automation prompts
├── .env.example           # Environment variables template
└── README.md              # This file
```

## Customization

### Adding Services

To add a new service to your project:

1. Update `azure.yaml` to include your service configuration
2. Add the corresponding infrastructure resources in `infra/main.bicep`
3. Create any additional Bicep modules in `infra/core/` as needed

### Example Service Configuration

```yaml
services:
  web:
    project: "./src/web"
    language: js
    host: containerapp
  api:
    project: "./src/api"
    language: python
    host: containerapp
```

### Environment Variables

Add environment-specific configuration in your `.env` file or use azd environment variables:

```bash
azd env set AZURE_LOCATION eastus2
azd env set MY_CUSTOM_SETTING value
```

The template automatically detects:

- **AZURE_PRINCIPAL_ID**: Current executing user/service principal ID
- **GITHUB_ACTIONS**: Whether deployment is running in GitHub Actions (sets deployment tags)
- **AZD_INITIAL_ENVIRONMENT_CONFIG**: Custom configuration parameters as JSON

## Available Infrastructure Modules

The template includes several modern Azure services in `infra/core/`:

### **Hosting & Compute**

- **Container Apps Environment**: Serverless container hosting platform
- **Container App**: Deploy containerized applications with auto-scaling
- **Container Registry**: Store and manage container images

### **AI & Machine Learning**

- **AI Foundry**: Complete AI development platform with AI Hub and Projects
- **AI Search**: Intelligent search service with semantic capabilities
- **Application Insights**: Application performance monitoring

### **Data & Storage**

- **Cosmos DB**: Globally distributed NoSQL database
- **Storage Account**: Blob storage, queues, tables with security best practices
- **Log Analytics**: Centralized logging and monitoring

### **Security & Identity**

- **Key Vault**: Secure secret, key, and certificate management with RBAC
- **User Assigned Managed Identity**: Secure identity for Azure resources

### **Deployment Utilities**

- **Import Images to ACR**: Automated container image import functionality

## IP Metadata Management

The template includes intellectual property tracking via `ip-metadata.json`:

```json
{
  "name": "Azure Template Project",
  "description": "Comprehensive Azure Developer CLI template",
  "maturity": "Bronze",
  "industry": "Technology",
  "region": "AMER",
  "services": ["Azure Container Apps", "Azure AI Foundry"]
}
```

Schema validation is provided through `schemas/ip-metadata.schema.json` for consistent metadata management.

## AI Agent Configuration

The `AGENTS.md` file defines specialized AI agents for this repository:

- **Azure Infrastructure Architect**: Infrastructure design and deployment
- **Application Developer**: Multi-language application development  
- **DevOps Engineer**: Automation and deployment pipelines
- **AI Solutions Architect**: AI/ML integration and optimization

This enables fine-tuning operations for improved development assistance.

## Commands

| Command | Description |
|---------|-------------|
| `azd init` | Initialize a new azd environment |
| `azd provision` | Provision Azure resources |
| `azd deploy` | Deploy application code |
| `azd up` | Provision and deploy |
| `azd down` | Delete Azure resources |
| `azd env list` | List environments |
| `azd env new` | Create new environment |
| `azd env select` | Switch environments |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
