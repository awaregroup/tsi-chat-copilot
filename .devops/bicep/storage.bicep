param resourcePrefix string
param location string

var proposedStorageName = '${replace(resourcePrefix, '-', '')}storage'
resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: length(proposedStorageName) > 24 ? substring(proposedStorageName, 0, 24) : proposedStorageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false //disable public access at the storage account level
    // allowSharedKeyAccess: false //disable access keys
    allowSharedKeyAccess: true //disable access keys
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
