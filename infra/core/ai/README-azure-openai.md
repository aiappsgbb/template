# Azure OpenAI Bicep Template

This Bicep template provides a versatile solution for Azure OpenAI resources that supports both creating new resources and reusing existing ones from different resource groups, with proper RBAC permissions.

## Features

- **Dual Mode Operation**: Create new Azure OpenAI resource or reference existing one
- **Cross-Resource Group Support**: Reference existing resources from different resource groups
- **Automatic RBAC**: Assigns appropriate permissions to managed identities
- **Model Deployments**: Supports deploying multiple models (for new resources)
- **Comprehensive Outputs**: Returns all necessary information for integration

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `openAiName` | string | Yes | Name of the Azure OpenAI resource |
| `location` | string | No | Location (default: resource group location) |
| `existingOpenAiResourceId` | string | No | Resource ID of existing OpenAI (leave empty to create new) |
| `managedIdentityPrincipalId` | string | Yes | Principal ID of managed identity needing access |
| `principalType` | string | No | Type of principal: 'User' or 'ServicePrincipal' (default: 'ServicePrincipal') |
| `tags` | object | No | Resource tags |
| `sku` | object | No | SKU configuration (default: S0) |
| `publicNetworkAccess` | string | No | Network access setting (default: 'Enabled') |
| `modelDeployments` | array | No | Array of model deployments to create |

## Integration with main.bicep

Add the Azure OpenAI module to your `main.bicep` file:

### Create New Azure OpenAI Resource

```bicep
// Azure OpenAI (create new)
module openai './core/ai/azure-openai.bicep' = {
  name: 'openai'
  scope: rg
  params: {
    openAiName: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    managedIdentityPrincipalId: managedIdentity.outputs.principalId
    modelDeployments: [
      {
        name: 'gpt-4'
        model: {
          name: 'gpt-4'
          version: '1106-Preview'
        }
        sku: {
          name: 'Standard'
          capacity: 10
        }
      }
      {
        name: 'text-embedding-ada-002'
        model: {
          name: 'text-embedding-ada-002'
          version: '2'
        }
        sku: {
          name: 'Standard'
          capacity: 120
        }
      }
    ]
  }
}
```

### Use Existing Azure OpenAI Resource

```bicep
// Azure OpenAI (use existing from another resource group)
module openai './core/ai/azure-openai.bicep' = {
  name: 'openai'
  scope: rg
  params: {
    openAiName: 'shared-openai-instance'
    existingOpenAiResourceId: '/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/shared-ai-rg/providers/Microsoft.CognitiveServices/accounts/shared-openai-instance'
    managedIdentityPrincipalId: managedIdentity.outputs.principalId
  }
}
```

### Add Outputs to main.bicep

```bicep
// Azure OpenAI Outputs
output AZURE_OPENAI_ENDPOINT string = openai.outputs.endpoint
output AZURE_OPENAI_NAME string = openai.outputs.name
output AZURE_OPENAI_RESOURCE_ID string = openai.outputs.id
```

### Usage in Container Apps

Reference the OpenAI outputs in your container app environment variables:

```bicep
module containerApp './core/host/container-app.bicep' = {
  name: 'containerApp'
  scope: rg
  params: {
    // ... other parameters
    environmentVariables: [
      {
        name: 'AZURE_OPENAI_ENDPOINT'
        value: openai.outputs.endpoint
      }
      {
        name: 'AZURE_OPENAI_RESOURCE_ID'  
        value: openai.outputs.id
      }
      // ... other environment variables
    ]
  }
}
### Getting Existing Resource ID

To find the resource ID of an existing Azure OpenAI resource:

```bash
# Using Azure CLI
az cognitiveservices account show \
  --name "your-openai-name" \
  --resource-group "your-resource-group" \
  --query "id" \
  --output tsv

# Using Azure PowerShell
(Get-AzCognitiveServicesAccount -ResourceGroupName "your-resource-group" -Name "your-openai-name").Id
```

## Model Deployment Configuration

When creating a new resource, you can specify model deployments:

```bicep
modelDeployments: [
  {
    name: 'gpt-4-turbo'
    model: {
      name: 'gpt-4'
      version: '1106-Preview'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: null
  }
]
```

## RBAC Permissions

The template automatically assigns the following role:

- **Cognitive Services OpenAI User** (`5e0bd9bd-7b93-4f28-af87-19fc36ad61bd`): Allows the managed identity to make API calls to Azure OpenAI

### Optional Contributor Role

Uncomment the `openAiContributorRoleAssignment` resource if you need management permissions:

```bicep
resource openAiContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAiResource.id, managedIdentityPrincipalId, cognitiveServicesContributorRoleId)
  scope: openAiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesContributorRoleId)
    principalId: managedIdentityPrincipalId
    principalType: principalType
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `id` | string | Resource ID of the Azure OpenAI account |
| `name` | string | Name of the Azure OpenAI account |
| `endpoint` | string | Endpoint URL for API calls |
| `location` | string | Resource location |
| `resourceGroupName` | string | Resource group containing the resource |
| `subscriptionId` | string | Subscription ID containing the resource |
| `deployedModels` | array | Information about deployed models |

## Integration Example

Use the outputs in your main template:

```bicep
// Reference the OpenAI resource
module openai './core/ai/azure-openai.bicep' = {
  // ... parameters
}

Use the outputs in other resources
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  // ... other configuration
  properties: {
    template: {
      containers: [{
        env: [
          {
            name: 'AZURE_CLIENT_ID'
            value: userAssignedIdentity.outputs.clientId
          }
          {
            name: 'AZURE_OPENAI_ENDPOINT'
            value: openai.outputs.endpoint
          }
          {
            name: 'AZURE_OPENAI_RESOURCE_ID'
            value: openai.outputs.id
          }
        ]
      }]
    }
  }
}
```

## Deployment Commands

Deploy the template using Azure CLI:

```bash
# Deploy with new OpenAI resource
az deployment sub create \
  --location "East US" \
  --template-file main.bicep \
  --parameters environmentName="dev" location="East US"

# Deploy referencing existing OpenAI resource
az deployment sub create \
  --location "East US" \
  --template-file main.bicep \
  --parameters environmentName="dev" location="East US" \
  --parameters existingOpenAiResourceId="/subscriptions/.../resourceGroups/.../providers/Microsoft.CognitiveServices/accounts/shared-openai"
```

## Security Considerations

1. **Least Privilege**: Only assigns necessary permissions (OpenAI User role by default)
2. **Cross-Subscription Support**: Handles resources in different subscriptions/resource groups
3. **Managed Identity**: Uses managed identity for secure, credential-free authentication
4. **Network Security**: Supports network access controls and custom domain configuration
5. **AZURE_CLIENT_ID**: Always set this environment variable in Azure Container Apps to specify which managed identity to use

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure the deployment principal has permissions on the target resource group
2. **Invalid Resource ID**: Verify the existing resource ID format and accessibility
3. **Model Deployment Conflicts**: Check for existing model deployments with the same name

### Validation

Test the deployment with whatif:

```bash
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file azure-openai.bicep \
  --parameters @parameters.json
```

## Best Practices

1. **Use Existing Resources for Shared Scenarios**: Reference shared OpenAI instances to avoid duplication
2. **Implement Proper Tagging**: Use consistent tags for cost tracking and governance
3. **Monitor Usage**: Implement monitoring for token usage and costs
4. **Regular Access Reviews**: Periodically review and audit RBAC assignments
5. **Version Management**: Use specific model versions for production workloads