@description('The name for the Cosmos DB account')
param name string

@description('The Azure region where the account will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the account')
param tags object = {}

@description('Consistency level for the account')
@allowed(['Eventual', 'ConsistentPrefix', 'Session', 'BoundedStaleness', 'Strong'])
param defaultConsistencyLevel string = 'Session'

@description('User Assigned Managed Identity Principal ID')
param managedIdentityPrincipalId string = ''

@description('Whether the deployment is running in GitHub Actions')
param githubActions bool = false

@description('Database name (for SQL API)')
param databaseName string = 'main'

// Determine principal type based on deployment context
var principalType = githubActions ? 'ServicePrincipal' : 'User'

@description('Container name (for SQL API)')
param containerName string = 'items'

// Use AVM Cosmos DB module
module cosmosDbAccount 'br/public:avm/res/document-db/database-account:0.16.0' = {
  name: 'cosmosDbAccount'
  params: {
    name: name
    location: location
    tags: tags
    failoverLocations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    defaultConsistencyLevel: defaultConsistencyLevel
    sqlDatabases: [
      {
        name: databaseName
        containers: [
          {
            name: containerName
            paths: ['/id']
          }
        ]
      }
    ]
    roleAssignments: !empty(managedIdentityPrincipalId) ? [
      {
        principalId: managedIdentityPrincipalId
        roleDefinitionIdOrName: 'DocumentDB Account Contributor'
        principalType: principalType
      }
    ] : []
  }
}

output id string = cosmosDbAccount.outputs.resourceId
output name string = cosmosDbAccount.outputs.name
output endpoint string = cosmosDbAccount.outputs.endpoint
