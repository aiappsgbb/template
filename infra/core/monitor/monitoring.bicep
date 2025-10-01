@description('The name for the Log Analytics Workspace')
param logAnalyticsName string

@description('The name for the Application Insights instance')
param applicationInsightsName string

@description('The Azure region where the resources will be deployed')
param location string = resourceGroup().location

@description('Tags to apply to the resources')
param tags object = {}

@description('Log Analytics retention in days')
param retentionInDays int = 30

@description('Application Insights kind')
param applicationInsightsKind string = 'web'

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

// Use AVM Log Analytics Workspace module
module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.12.0' = {
  name: 'logAnalyticsWorkspace'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
    dataRetention: retentionInDays
    skuName: 'PerGB2018'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Use AVM Application Insights module
module applicationInsights 'br/public:avm/res/insights/component:0.6.0' = {
  name: 'applicationInsights'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    applicationType: applicationInsightsKind
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// RBAC assignments for managed identity
var roleAssignments = !empty(managedIdentityPrincipalId) ? [
  {
    principalId: managedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893') // Log Analytics Reader
    principalType: principalType
  }
  {
    principalId: managedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ae349356-3a1b-4a5e-921d-050484c6347e') // Application Insights Component Contributor
    principalType: principalType
  }
] : []

// Assign RBAC roles to Log Analytics
module logAnalyticsRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = [for (assignment, index) in roleAssignments: if (!empty(managedIdentityPrincipalId)) {
  name: 'logAnalyticsRbac-${index}'
  params: {
    resourceId: logAnalyticsWorkspace.outputs.resourceId
    principalId: assignment.principalId
    roleDefinitionId: assignment.roleDefinitionId
    principalType: assignment.principalType
  }
}]

// Assign RBAC roles to Application Insights
module appInsightsRbac 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = [for (assignment, index) in roleAssignments: if (!empty(managedIdentityPrincipalId)) {
  name: 'appInsightsRbac-${index}'
  params: {
    resourceId: applicationInsights.outputs.resourceId
    principalId: assignment.principalId
    roleDefinitionId: assignment.roleDefinitionId
    principalType: assignment.principalType
  }
}]

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.resourceId
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name
output applicationInsightsId string = applicationInsights.outputs.resourceId
output applicationInsightsName string = applicationInsights.outputs.name
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
