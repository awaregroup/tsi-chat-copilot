param resourcePrefix string
param location string

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: substring('${replace(resourcePrefix, '-', '')}storage', 0, 24) //no hyphens and max length 24 chars
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false //disable public access at the storage account level
    allowSharedKeyAccess: false //disable access keys
  }
}

output storageAccountName string = storage.name

resource storageBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storage
}

resource chatMemoryContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'chatmemory'
  parent: storageBlobServices
}

resource storageBlobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

// resource blobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, webApp.id, storageBlobDataContributorRoleDefinition.id)
//   scope: storageAccount
//   properties: {
//     roleDefinitionId: storageBlobDataContributorRoleDefinition.id
//     principalId: webApp.identity.principalId
//   }
// }
