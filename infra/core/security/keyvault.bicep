@description('The name for the Key Vault')
param name string

@description('The Azure region where the Key Vault will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the Key Vault')
param tags object = {}

@description('The Azure Active Directory tenant ID')
param tenantId string = tenant().tenantId

@description('Access policies for the Key Vault')
param accessPolicies array = []

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention days')
param softDeleteRetentionInDays int = 90

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: true
    accessPolicies: accessPolicies
  }
}

output id string = keyVault.id
output name string = keyVault.name
output vaultUri string = keyVault.properties.vaultUri
