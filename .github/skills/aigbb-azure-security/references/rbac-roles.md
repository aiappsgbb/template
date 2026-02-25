# RBAC Role Assignments — Quick Reference

## Common Azure Built-in Roles

### Identity & Access

| Role | Role ID | Use For |
|------|---------|---------|
| Key Vault Secrets User | `4633458b-17de-408a-b874-0445c86b69e6` | Read secrets from Key Vault |
| Key Vault Crypto User | `12338af0-0e69-4776-bea7-57ae8d297424` | Encrypt/decrypt with Key Vault keys |
| Key Vault Certificates Officer | `a4417e6f-fecd-4de8-b567-7b0420556985` | Manage Key Vault certificates |

### Storage

| Role | Role ID | Use For |
|------|---------|---------|
| Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` | Read/write/delete blobs |
| Storage Blob Data Reader | `2a2b9908-6ea1-4ae2-8e65-a410df84e7d1` | Read-only blob access |
| Storage Queue Data Contributor | `974c5e8b-45b9-4653-ba55-5f855dd0fb88` | Read/write/delete queue messages |
| Storage Table Data Contributor | `0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3` | Read/write/delete table entities |

### AI Services

| Role | Role ID | Use For |
|------|---------|---------|
| Cognitive Services User | `a97b65f3-24c7-4388-baec-2e87135dc908` | Use Cognitive Services (read-only) |
| Cognitive Services OpenAI User | `5e0bd9bd-7b93-4f28-af87-19fc36ad61bd` | Use Azure OpenAI deployments |
| Cognitive Services OpenAI Contributor | `a001fd3d-188f-4b5d-821b-7da978bf7442` | Manage OpenAI deployments |

### Search

| Role | Role ID | Use For |
|------|---------|---------|
| Search Service Contributor | `7ca78c08-252a-4471-8644-bb5ff32d4ba0` | Manage search service |
| Search Index Data Contributor | `8ebe5a00-799e-43f5-93ac-243d3dce84a7` | Read/write search index data |
| Search Index Data Reader | `1407120a-92aa-4202-b7e9-c0e197c71c8f` | Read-only search index data |

### Containers

| Role | Role ID | Use For |
|------|---------|---------|
| AcrPull | `7f951dda-4ed3-4680-a7ca-43fe172d538d` | Pull images from ACR |
| AcrPush | `8311e382-0749-4cb8-b61a-304f252e45ec` | Push images to ACR |

### Databases

| Role | Role ID | Use For |
|------|---------|---------|
| Cosmos DB Built-in Data Contributor | `00000000-0000-0000-0000-000000000002` | CRUD on Cosmos DB items |
| Cosmos DB Built-in Data Reader | `00000000-0000-0000-0000-000000000001` | Read-only Cosmos DB access |

---

## Bicep Assignment Template

```bicep
// RBAC role assignment with principal guard
var roleName = 'descriptive-role-name'
var roleId = 'role-definition-id-from-table-above'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(targetResource.id, principalId, roleId)
  scope: targetResource
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions', roleId
    )
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

### Multiple Roles for One Identity

```bicep
// Give managed identity access to multiple Azure services
var roles = {
  keyVaultSecretsUser: '4633458b-17de-408a-b874-0445c86b69e6'
  storageBlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  cognitiveServicesOpenAiUser: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  searchIndexDataContributor: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
}

resource kvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(keyVault.id, principalId, roles.keyVaultSecretsUser)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roles.keyVaultSecretsUser)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(storageAccount.id, principalId, roles.storageBlobDataContributor)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roles.storageBlobDataContributor)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
```

---

## ❌ Forbidden Roles

**NEVER assign these overly broad roles:**

| Role | Why Forbidden | Use Instead |
|------|---------------|-------------|
| Owner | Full access + RBAC mgmt | Specific data-plane roles |
| Contributor | Full access (no RBAC mgmt) | Specific data-plane roles |
| Key Vault Administrator | Full Key Vault access | Key Vault Secrets User |
| Storage Account Contributor | Management plane | Storage Blob Data Contributor |

---

## Developer vs Service Principal RBAC

For local development with `azd`, the developer's identity also needs roles:

```bicep
// principalId comes from main.parameters.json → ${AZURE_PRINCIPAL_ID}
// It is the developer's Entra ID for local dev, or the CI/CD service principal

resource devKvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(keyVault.id, principalId, roles.keyVaultSecretsUser)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roles.keyVaultSecretsUser)
    principalId: principalId
    principalType: principalType   // 'User' for devs, 'ServicePrincipal' for CI/CD
  }
}
```

**Tip**: Use `principalType` parameter to distinguish User vs ServicePrincipal assignments.
