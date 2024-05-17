@description('Organisation Code')
@minLength(2)
@maxLength(8)
param organisationCode string = 'AWARE'

@description('Environment')
@minLength(3)
@maxLength(4)
param environment string = 'prod'

@description('Application Name')
@minLength(3)
@maxLength(11)
param applicationName string = 'chatcopilot'

@description('Include random hash in resource name?')
param includeHashInResourceName bool = false

param azureAdBackendClientId string
param azureAdFrontendClientId string
param azureAdInstance string = 'https://login.microsoftonline.com'
param azureAdTenantId string

@description('Location for application code to deploy')
param appServiceFrontendPackageUri string = 'https://aware.to/tsi/frontendpackageuri'

//azure open ai settings
param externalAzureOpenAIEndpoint string = ''
param externalAzureOpenAIKey string = ''
param externalAzureOpenAICompletionDeploymentName string = 'gpt-4-turbo'
param externalAzureOpenAIEmbeddingDeploymentName string = 'text-embedding-ada-002'

@description('Hash for the deployment')
var uniqueStr = uniqueString(subscription().id, resourceGroup().id, 'chatcopilot')
var resourcePrefix = toLower('${organisationCode}-${environment}-${applicationName}${(includeHashInResourceName ? '-${substring(uniqueStr, 0, 4)}' : '')}')

var location = resourceGroup().location

module storageResources './storage.bicep' = {
  name: 'Storage_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}

module aiResources './aiservices.bicep' = {
  name: 'AI_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}

module cosmosResources './cosmos.bicep' = {
  name: 'Cosmos_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}

module webResources './appservice.bicep' = {
  name: 'Web_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}

module logResources './appinsight.bicep' = {
  name: 'Log_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
    appServiceFrontendName: webResources.outputs.appServiceFrontendName
  }
}

//only deploy keyvault if its an external resource
module keyVault './keyvault.bicep' = {
  name: 'KeyVault_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
    aiSpeechAccountName: aiResources.outputs.aiSpeechAccountName

    //select openAI properties based on input param
    azureOpenAIKey: externalAzureOpenAIKey
  }
}

module codeDeployResources './codedeployandconfig.bicep' = {
  name: 'Code_Deploy'
  params: {
    azureAdBackendClientId: azureAdBackendClientId
    azureAdFrontendClientId: azureAdFrontendClientId
    azureAdInstance: azureAdInstance
    azureAdTenantId: azureAdTenantId

    keyVaultName: keyVault.outputs.keyVaultName
    appServiceFrontendName: webResources.outputs.appServiceFrontendName
    appServiceFrontendPackageUri: appServiceFrontendPackageUri
    // appServiceAppSettings: webResources.outputs.appServiceAppSettings
    storageAccountName: storageResources.outputs.storageAccountName
    aiSearchAccountName: aiResources.outputs.aiSearchAccountName
    appInsightsName: logResources.outputs.appInsightsName
    documentIntelligenceAccountName: aiResources.outputs.documentIntelligenceAccountName
    cosmosAccountName: cosmosResources.outputs.cosmosAccountName
    aiSpeechAccountName: aiResources.outputs.aiSpeechAccountName
    aiSpeechAccountKeySecretName: keyVault.outputs.aiSpeechAccountKeySecretName

    azureOpenAIEmbeddingDeploymentName: externalAzureOpenAIEmbeddingDeploymentName
    azureOpenAICompletionDeploymentName: externalAzureOpenAICompletionDeploymentName
    azureOpenAIPlannerDeploymentName: externalAzureOpenAICompletionDeploymentName

    azureOpenAIEndpoint: externalAzureOpenAIEndpoint
    azureOpenAIKeySecretName: keyVault.outputs.openAISecretName
  }
}

module managedIdentityResources './managedidentity.bicep' = {
  name: 'Managed_Identity'
  params: {
    appServiceFrontendName: webResources.outputs.appServiceFrontendName
    cosmosAccountName: cosmosResources.outputs.cosmosAccountName
    aiSearchAccountName: aiResources.outputs.aiSearchAccountName

    storageAccountName: storageResources.outputs.storageAccountName
    azureDocumentIntelligenceAccountName: aiResources.outputs.documentIntelligenceAccountName
    azureSpeechAccountName: aiResources.outputs.aiSpeechAccountName
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

//outputs
output uniqueStr string = uniqueStr
output resourcePrefix string = resourcePrefix
