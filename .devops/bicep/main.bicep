@description('Organisation Code')
@minLength(2)
@maxLength(5)
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

@description('Location for application code to deploy')
param appServiceMemoryPipelinePackageUri string = 'https://aware.to/tsi/memorypipelinepackageuri'

@description('Resource location')
param location string = resourceGroup().location

param useExternalAzureOpenAIEndpoint bool = false
param externalAzureOpenAIEndpoint string = ''
param externalAzureOpenAIDeploymentName string = ''
param externalAzureOpenAIEmbeddingDeploymentName string = ''
param externalAzureOpenAIKey string = ''

@description('Hash for the deployment')
var uniqueStr = uniqueString(subscription().id, resourceGroup().id, 'chatcopilot')
var resourcePrefix = toLower('${organisationCode}-${environment}-${applicationName}${(includeHashInResourceName ? '-${substring(uniqueStr, 0, 4)}' : '')}')

module storageResources './storage.bicep' = {
  name: 'Storage_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}

// AI resources
module aiResources './ai.bicep' = {
  name: 'AI_Resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
    useExternalAzureOpenAIEndpoint: useExternalAzureOpenAIEndpoint
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
    appServiceMemoryPipelineName: webResources.outputs.appServiceMemoryPipelineName
  }
}

module codeDeployResources './codedeploy.bicep' = {
  name: 'Code_Deploy'
  params: {
    location: location
    azureAdBackendClientId: azureAdBackendClientId
    azureAdFrontendClientId: azureAdFrontendClientId
    azureAdInstance: azureAdInstance
    azureAdTenantId: azureAdTenantId

    appServiceFrontendName: webResources.outputs.appServiceFrontendName
    appServiceMemoryPipelineName: webResources.outputs.appServiceMemoryPipelineName
    appServiceFrontendPackageUri: appServiceFrontendPackageUri
    appServiceMemoryPipelinePackageUri: appServiceMemoryPipelinePackageUri
    storageAccountName: storageResources.outputs.storageAccountName
    azureSearchAccountName: aiResources.outputs.azureSearchAccountName
    // azureOpenAIAccountName: aiResources.outputs.azureOpenAIAccountName
    appInsightsName: logResources.outputs.appInsightsName
    azureOcrAccountName: aiResources.outputs.ocrAccountName
    cosmosAccountName: cosmosResources.outputs.cosmosAccountName
    speechAccountName: aiResources.outputs.speechAccountName

    useExternalAzureOpenAIEndpoint: useExternalAzureOpenAIEndpoint
    externalAzureOpenAIDeploymentName: externalAzureOpenAIDeploymentName
    externalAzureOpenAIEmbeddingDeploymentName: externalAzureOpenAIEmbeddingDeploymentName
    externalAzureOpenAIEndpoint: externalAzureOpenAIEndpoint
    externalAzureOpenAIKey: externalAzureOpenAIKey
  }
}

//outputs
output uniqueStr string = uniqueStr
output resourcePrefix string = resourcePrefix
