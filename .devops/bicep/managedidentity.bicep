param cosmosAccountName string
param appServiceFrontendName string
param storageAccountName string
param aiSearchAccountName string
param azureSpeechAccountName string
param azureDocumentIntelligenceAccountName string
param keyVaultName string

resource azureDocumentIntelligence 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: azureDocumentIntelligenceAccountName
}

resource azureSpeechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: azureSpeechAccountName
}

resource aiSearchAccount 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: aiSearchAccountName
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

//========================================================
//cosmos db managed identity role assignments
//========================================================

var cosmosDbBuiltInDataContributorRoleId = '00000000-0000-0000-0000-000000000002'
resource cosmosDbBuiltInDataContributorAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: guid(cosmosAccount.id, cosmosDbBuiltInDataContributorRoleId, appServiceFrontend.id)
  parent: cosmosAccount
  properties: {
    principalId: appServiceFrontend.identity.principalId
    roleDefinitionId: '${cosmosAccount.id}/sqlRoleDefinitions/${cosmosDbBuiltInDataContributorRoleId}'
    scope: cosmosAccount.id
  }
}

//========================================================
//storage managed identity role assignments
//========================================================
resource storageBlobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource storageBlobQueueDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

resource blobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, storageBlobDataContributorRoleDefinition.id, appServiceFrontend.id)
  scope: storage
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinition.id
    principalId: appServiceFrontend.identity.principalId
  }
}

resource queueRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, storageBlobQueueDataContributor.id, appServiceFrontend.id)
  scope: storage
  properties: {
    roleDefinitionId: storageBlobQueueDataContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}

//========================================================
//azure search managed identity role assignments
//========================================================

resource searchServiceContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: aiSearchAccount
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
}

resource searchIndexDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: aiSearchAccount
  name: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
}

resource searchIndexDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, searchIndexDataContributor.id, appServiceFrontend.id)
  scope: aiSearchAccount
  properties: {
    roleDefinitionId: searchIndexDataContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}

resource searchServiceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, searchServiceContributor.id, appServiceFrontend.id)
  scope: aiSearchAccount
  properties: {
    roleDefinitionId: searchServiceContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}

//========================================================
//speech managed identity role assignments
//========================================================

resource speechServiceContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureSpeechAccount
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
}

resource speechServiceContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, speechServiceContributor.id, appServiceFrontend.id)
  scope: azureSpeechAccount
  properties: {
    roleDefinitionId: speechServiceContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}

//========================================================
//speech managed identity role assignments
//========================================================

resource documentIntelligenceServiceContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureDocumentIntelligence
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
}

resource documentIntelligenceServiceContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, documentIntelligenceServiceContributor.id, appServiceFrontend.id)
  scope: azureDocumentIntelligence
  properties: {
    roleDefinitionId: documentIntelligenceServiceContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}

//========================================================
//keyvault managed identity role assignments
//========================================================

@description('This is the built-in Key Vault Secrets User role. See https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: keyVault
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource keyVaultSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, keyVault.id, appServiceFrontend.id)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: appServiceFrontend.identity.principalId
  }
}
