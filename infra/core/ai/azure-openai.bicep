targetScope = 'resourceGroup'

@description('Name of the Azure OpenAI resource')
param openAiName string

@description('Location for the Azure OpenAI resource (only used when creating new resource)')
param location string = resourceGroup().location

@description('Resource ID of existing Azure OpenAI resource (leave empty to create new resource)')
param existingOpenAiResourceId string = ''

@description('Principal ID of the managed identity that needs access to Azure OpenAI')
param managedIdentityPrincipalId string

@description('Principal type of the managed identity (User or ServicePrincipal)')
@allowed(['User', 'ServicePrincipal'])
param principalType string = 'ServicePrincipal'

@description('Tags to apply to the Azure OpenAI resource')
param tags object = {}

@description('SKU for the Azure OpenAI resource')
param sku object = {
  name: 'S0'
}

@description('Whether to enable public network access')
param publicNetworkAccess string = 'Enabled'

@description('Array of model deployments to create')
param modelDeployments array = []

// Role definition IDs
var cognitiveServicesOpenAiUserRoleId = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
// var cognitiveServicesContributorRoleId = '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68' // Uncomment if using Contributor role

// Determine if we should create a new resource (when no existing resource ID is provided)
var createNewResource = empty(existingOpenAiResourceId)

// Create new Azure OpenAI resource if specified
resource newOpenAiAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = if (createNewResource) {
  name: openAiName
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: sku
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Reference existing Azure OpenAI resource if specified
resource existingOpenAiAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = if (!createNewResource) {
  name: last(split(existingOpenAiResourceId, '/'))
  scope: resourceGroup(split(existingOpenAiResourceId, '/')[2], split(existingOpenAiResourceId, '/')[4])
}

// Get the actual resource reference based on creation mode
var openAiResource = createNewResource ? newOpenAiAccount : existingOpenAiAccount

// Model deployments for new resource only
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = [for deployment in modelDeployments: if (createNewResource) {
  name: deployment.name
  parent: newOpenAiAccount
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.model.name
      version: deployment.model.version
    }
    versionUpgradeOption: deployment.versionUpgradeOption ?? 'OnceNewDefaultVersionAvailable'
    raiPolicyName: deployment.raiPolicyName ?? null
  }
  sku: deployment.sku ?? {
    name: 'Standard'
    capacity: 20
  }
}]

// Assign Azure OpenAI User role to the managed identity
resource openAiUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAiResource.id, managedIdentityPrincipalId, cognitiveServicesOpenAiUserRoleId)
  scope: openAiResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAiUserRoleId)
    principalId: managedIdentityPrincipalId
    principalType: principalType
  }
}

// Optional: Assign Contributor role for management operations (uncomment if needed)
// resource openAiContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(openAiResource.id, managedIdentityPrincipalId, cognitiveServicesContributorRoleId)
//   scope: openAiResource
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesContributorRoleId)
//     principalId: managedIdentityPrincipalId
//     principalType: principalType
//   }
// }

// Outputs
@description('The resource ID of the Azure OpenAI account')
output id string = openAiResource.id

@description('The name of the Azure OpenAI account')
output name string = openAiResource.name

@description('The endpoint URL of the Azure OpenAI account')
output endpoint string = openAiResource.properties.endpoint

@description('The location of the Azure OpenAI account')
output location string = openAiResource.location

@description('The resource group name containing the Azure OpenAI account')
output resourceGroupName string = createNewResource ? resourceGroup().name : split(existingOpenAiResourceId, '/')[4]

@description('The subscription ID containing the Azure OpenAI account')
output subscriptionId string = createNewResource ? subscription().subscriptionId : split(existingOpenAiResourceId, '/')[2]

@description('Information about deployed models')
output deployedModels array = [for (deployment, i) in modelDeployments: if (createNewResource) {
  name: deployment.name
  model: deployment.model
  endpoint: '${openAiResource.properties.endpoint}openai/deployments/${deployment.name}'
}]
