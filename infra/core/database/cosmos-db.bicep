@description('The name for the Cosmos DB account')
param name string

@description('The Azure region where the account will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the account')
param tags object = {}

@description('Cosmos DB API type')
@allowed(['Sql', 'MongoDB', 'Cassandra', 'Gremlin', 'Table'])
param databaseAccountOfferType string = 'Sql'

@description('Consistency level for the account')
@allowed(['Eventual', 'ConsistentPrefix', 'Session', 'BoundedStaleness', 'Strong'])
param defaultConsistencyLevel string = 'Session'

@description('Enable automatic failover')
param enableAutomaticFailover bool = false

@description('Enable multiple write locations')
param enableMultipleWriteLocations bool = false

@description('Locations for the Cosmos DB account')
param locations array = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

@description('Database name (for SQL API)')
param databaseName string = 'main'

@description('Container name (for SQL API)')
param containerName string = 'items'

// Cosmos DB Account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: name
  location: location
  tags: tags
  kind: databaseAccountOfferType == 'MongoDB' ? 'MongoDB' : 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
    }
    locations: locations
    capabilities: databaseAccountOfferType == 'Sql' ? [] : [
      {
        name: databaseAccountOfferType == 'MongoDB' ? 'EnableMongo' : 'Enable${databaseAccountOfferType}'
      }
    ]
    enableAutomaticFailover: enableAutomaticFailover
    enableMultipleWriteLocations: enableMultipleWriteLocations
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    ipRules: []
    enableCassandraConnector: false
    enableAnalyticalStorage: false
  }
}

// SQL Database (only for SQL API)
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = if (databaseAccountOfferType == 'Sql') {
  parent: cosmosDbAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

// SQL Container (only for SQL API)
resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = if (databaseAccountOfferType == 'Sql') {
  parent: cosmosDbDatabase
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
  }
}

output id string = cosmosDbAccount.id
output name string = cosmosDbAccount.name
output endpoint string = cosmosDbAccount.properties.documentEndpoint
