param resourcePrefix string
param location string
param aiSpeechAccountName string

param azureOpenAIKey string

resource aiSpeechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: aiSpeechAccountName
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

// =================================================================================================
// document intelligence
//=================================================================================================

resource aiSpeechSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: '${resourcePrefix}-aispeech-apikey'
  properties: {
    value: aiSpeechAccount.listKeys().key1
  }
}

output aiSpeechAccountKeySecretName string = aiSpeechSecret.name
