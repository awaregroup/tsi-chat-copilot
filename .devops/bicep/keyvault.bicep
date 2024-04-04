param resourcePrefix string
param location string
param appServiceFrontendName string
param documentIntelligenceAccountName string
param cosmosAccountName string
param speechAccountName string
param aiSearchAccountName string
param storageAccountName string

param azureOpenAIKey string

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

resource aiSearchAccount 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: aiSearchAccountName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

resource documentIntelligenceAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: documentIntelligenceAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

//=================================================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: '${resourcePrefix}-kv'
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output keyVaultName string = keyVault.name

//=================================================================================================
// cosmos db
//=================================================================================================

resource cosmosDbSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-cosmosdb-connection-string'
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

output cosmosDbSecretName string = cosmosDbSecret.name

//=================================================================================================
// ai search
//=================================================================================================

resource aiSearchSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-aisearch-apikey'
  properties: {
    value: aiSearchAccount.listAdminKeys().primaryKey
  }
}

output aiSearchSecretName string = aiSearchSecret.name

//=================================================================================================
// storage account
//=================================================================================================

resource storageAccountSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-storage-connection-string'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[1].value}'
  }
}

output storageAccountSecretName string = storageAccountSecret.name

//=================================================================================================
// document intelligence
//=================================================================================================

resource documentIntelligenceSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-documentintelligence-apikey'
  properties: {
    value: documentIntelligenceAccount.listKeys().key1
  }
}

output documentIntelligenceSecretName string = documentIntelligenceSecret.name

//=================================================================================================
// openAI
//=================================================================================================

resource openAISecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-openai-apikey'
  properties: {
    value: azureOpenAIKey
  }
}

output openAISecretName string = openAISecret.name
