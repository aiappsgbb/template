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
│   └── abbreviations.json # Azure resource naming abbreviations
├── azure.yaml             # Azure Developer CLI project configuration
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
