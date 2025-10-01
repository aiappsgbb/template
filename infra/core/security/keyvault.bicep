@description('The name for the Key Vault')
param name string

@description('The Azure region where the Key Vault will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the Key Vault')
param tags object = {}

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention days')
param softDeleteRetentionInDays int = 90

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('User Assigned Managed Identity Client ID')
param managedIdentityClientId string = ''

@description('User Assigned Managed Identity Resource ID')
param managedIdentityResourceId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

// Use AVM Key Vault module
module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'keyVault'
  params: {
    name: name
    location: location
    tags: tags
    sku: 'standard'
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Key Vault Secrets User' // Built-in role for reading secrets
        principalType: principalType
      }
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'Key Vault Certificate User' // Built-in role for reading certificates
        principalType: principalType
      }
    ] : []
  }
}

output id string = keyVault.outputs.resourceId
output name string = keyVault.outputs.name
output vaultUri string = keyVault.outputs.uri
