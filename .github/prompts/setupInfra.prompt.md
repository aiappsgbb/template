---
mode: 'agent'
model: Auto (copilot)
tools: ['githubRepo', 'search/codebase', 'edit', 'changes', 'runCommands']
description: 'Setup Azure infrastructure with Bicep'
---
Configure the main.bicep file to set up a comprehensive Azure infrastructure using all available modules in the infra/core directory.

**Critical**: Follow [Bicep Deployment Best Practices](../bicep-deployment-bestpractices.md) for all infrastructure components.

1. Update the main.bicep file to include all modern Azure services:

2. Uncomment and configure the following modules with proper dependencies:
   - User Assigned Managed Identity (foundational security)
   - Key Vault (secure secret management)
   - Storage Account (general purpose storage)
   - Log Analytics Workspace & Application Insights (monitoring)
   - Container Registry (container image storage)
   - Container Apps Environment (container hosting platform)
   - Container App (application deployment)
   - AI Search (intelligent search capabilities)
   - Cosmos DB (NoSQL database)
   - AI Foundry (AI development platform)

3. Set up proper dependencies between modules:
   - Managed Identity should be created first
   - Monitoring (Log Analytics) before Container Apps Environment
   - Key Vault and Storage Account before AI Foundry
   - Container Registry before Container Apps

4. Configure role assignments:
   - Grant Container App managed identity access to Container Registry
   - Grant managed identity Key Vault access
   - Grant AI services access to Storage and Key Vault

5. Add comprehensive outputs including:
   - All resource IDs and names
   - Connection strings (where appropriate)
   - Service endpoints
   - Resource group information

6. Include proper parameter validation and descriptions

7. Use the resource naming convention with abbreviations and resource tokens

8. Ensure all modules use consistent tagging

9. Add comments explaining the purpose of each module and dependencies

The infrastructure should be production-ready with proper security, monitoring, and resource organization.