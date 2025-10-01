@description('The name for the storage account')
param name string

@description('The Azure region where the storage account will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the storage account')
param tags object = {}

@description('The storage account SKU')
param sku object = {
  name: 'Standard_LRS'
}

@description('Allow blob public access')
param allowBlobPublicAccess bool = false

@description('Allow shared key access')
param allowSharedKeyAccess bool = true

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: sku
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output id string = storageAccount.id
output name string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
