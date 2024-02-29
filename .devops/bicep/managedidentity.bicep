param cosmosAccountName string
param appServiceFrontendName string
param appServiceMemoryPipelineName string
param storageAccountName string
param azureSearchAccountName string

resource azureSearchAccount 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: azureSearchAccountName
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

resource appServiceMemoryPipeline 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceMemoryPipelineName
}

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

//========================================================
//cosmos db managed identity role assignments
//========================================================

resource cosmosDbAccountContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: cosmosAccount
  name: '5bd9cd88-fe45-4216-938b-f97437e15450'
}

resource cosmosDbAccountContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosAccount.id, cosmosDbAccountContributor.id, appServiceFrontend.id)
  scope: cosmosAccount
  properties: {
    roleDefinitionId: cosmosDbAccountContributor.id
    principalId: appServiceFrontend.identity.principalId
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
  scope: azureSearchAccount
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
}

resource searchServiceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, searchServiceContributor.id, appServiceFrontend.id)
  scope: azureSearchAccount
  properties: {
    roleDefinitionId: searchServiceContributor.id
    principalId: appServiceFrontend.identity.principalId
  }
}
