param appServiceFrontendName string
// param appServiceAppSettings array
param appServiceFrontendPackageUri string
param storageAccountName string
param aiSearchAccountName string
param appInsightsName string
param documentIntelligenceAccountName string
param cosmosAccountName string
param aiSpeechAccountName string
param keyVaultName string
param aiSpeechAccountKeySecretName string

param azureAdInstance string
param azureAdTenantId string
param azureAdFrontendClientId string
param azureAdBackendClientId string

param azureOpenAIEndpoint string
param azureOpenAICompletionDeploymentName string
param azureOpenAIPlannerDeploymentName string
param azureOpenAIEmbeddingDeploymentName string
param azureOpenAIKeySecretName string

resource aiSpeechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: aiSpeechAccountName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource documentIntelligenceAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: documentIntelligenceAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource aiSearchAccount 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: aiSearchAccountName
}

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

resource appServiceFrontendDeployment 'Microsoft.Web/sites/extensions@2022-09-01' = {
  name: 'onedeploy'
  parent: appServiceFrontend
  dependsOn: [
    appServiceFrontendConfig
  ]
  properties: {
    type: 'zip'
    clean: true
    packageUri: appServiceFrontendPackageUri
  }
}

var aiService = 'AzureOpenAI'
var memoryStore = 'AzureAISearch'

resource appServiceFrontendConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appServiceFrontend
  name: 'web'
  properties: {
    appSettings: union([], [
      //azure ad
      {
        name: 'Authentication__Type'
        value: 'AzureAd'
      }
      {
        name: 'Authentication__AzureAd__Instance'
        value: azureAdInstance
      }
      {
        name: 'Authentication__AzureAd__TenantId'
        value: azureAdTenantId
      }
      {
        name: 'Authentication__AzureAd__ClientId'
        value: azureAdBackendClientId
      }
      {
        name: 'Frontend__AadClientId'
        value: azureAdFrontendClientId
      }
      {
        name: 'Authentication__AzureAd__Scopes'
        value: 'access_as_user'
      }

      //planner/chatstore
      {
        name: 'Planner__Model'
        value: azureOpenAIPlannerDeploymentName
      }
      {
        name: 'ChatStore__Type'
        value: 'cosmos'
      }

      //TODO: update these settings to use the outputs from the cosmos bicep file
      {
        name: 'ChatStore__Cosmos__Auth'
        value: 'AzureIdentity'
      }
      {
        name: 'ChatStore__Cosmos__Endpoint'
        value: cosmosAccount.properties.documentEndpoint
      }
      {
        name: 'ChatStore__Cosmos__Database'
        value: 'CopilotChat'
      }
      {
        name: 'ChatStore__Cosmos__ChatSessionsContainer'
        value: 'chatsessions'
      }
      {
        name: 'ChatStore__Cosmos__ChatMessagesContainer'
        value: 'chatmessages'
      }
      {
        name: 'ChatStore__Cosmos__ChatMemorySourcesContainer'
        value: 'chatmemorysources'
      }
      {
        name: 'ChatStore__Cosmos__ChatParticipantsContainer'
        value: 'chatparticipants'
      }

      //azure speech
      {
        name: 'AzureSpeech__Region'
        value: aiSpeechAccount.location
      }
      {
        name: 'AzureSpeech__Key'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${aiSpeechAccountKeySecretName})'
      }

      //kestrel (internal .net webserver)
      {
        name: 'AllowedOrigins'
        value: '[*]' // Defer list of allowed origins to the Azure service app's CORS configuration
      }
      {
        name: 'Kestrel__Endpoints__Https__Url'
        value: 'https://localhost:443'
      }

      //logging
      {
        name: 'Logging__LogLevel__Default'
        value: 'Warning'
      }
      {
        name: 'Logging__LogLevel__CopilotChat.WebApi'
        value: 'Warning'
      }
      {
        name: 'Logging__LogLevel__Microsoft.SemanticKernel'
        value: 'Warning'
      }
      {
        name: 'Logging__LogLevel__Microsoft.AspNetCore.Hosting'
        value: 'Warning'
      }
      {
        name: 'Logging__LogLevel__Microsoft.Hosting.Lifetimel'
        value: 'Warning'
      }
      {
        name: 'Logging__ApplicationInsights__LogLevel__Default'
        value: 'Warning'
      }

      //kernel memory
      {
        name: 'KernelMemory__ContentStorageType'
        value: 'AzureBlobs'
      }
      {
        name: 'KernelMemory__TextGeneratorType'
        value: aiService
      }
      {
        name: 'KernelMemory__DataIngestion__OrchestrationType'
        value: 'InProcess'
      }
      {
        name: 'KernelMemory__DataIngestion__DistributedOrchestration__QueueType'
        value: 'AzureQueue'
      }
      {
        name: 'KernelMemory__DataIngestion__EmbeddingGeneratorTypes__0'
        value: aiService
      }
      {
        name: 'KernelMemory__DataIngestion__MemoryDbTypes__0'
        value: memoryStore
      }
      {
        name: 'KernelMemory__Retrieval__MemoryDbType'
        value: memoryStore
      }
      {
        name: 'KernelMemory__Retrieval__EmbeddingGeneratorType'
        value: aiService
      }
      {
        name: 'KernelMemory__Services__AzureBlobs__Auth'
        value: 'AzureIdentity'
      }
      {
        name: 'KernelMemory__Services__AzureBlobs__Account'
        value: storageAccount.name
      }
      {
        name: 'KernelMemory__Services__AzureBlobs__Container'
        value: 'chatmemory'
      }
      {
        name: 'KernelMemory__Services__AzureQueue__Auth'
        value: 'AzureIdentity'
      }
      {
        name: 'KernelMemory__Services__AzureAISearch__Auth'
        value: 'AzureIdentity'
      }
      {
        name: 'KernelMemory__Services__AzureAISearch__Endpoint'
        value: 'https://${aiSearchAccount.name}.search.windows.net'
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIText__Auth'
        value: 'APIKey'
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIText__Endpoint'
        value: azureOpenAIEndpoint
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIText__APIKey'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${azureOpenAIKeySecretName})'
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIText__Deployment'
        value: azureOpenAICompletionDeploymentName
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIEmbedding__Auth'
        value: 'APIKey'
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIEmbedding__Endpoint'
        value: azureOpenAIEndpoint
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIEmbedding__APIKey'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${azureOpenAIKeySecretName})'
      }
      {
        name: 'KernelMemory__Services__AzureOpenAIEmbedding__Deployment'
        value: azureOpenAIEmbeddingDeploymentName
      }
      {
        name: 'KernelMemory__Services__AzureAIDocIntel__Auth'
        value: 'AzureIdentity'
      }
      {
        name: 'KernelMemory__Services__AzureAIDocIntel__Endpoint'
        value: documentIntelligenceAccount.properties.endpoint
      }
      {
        name: 'KernelMemory__ImageOcrType'
        value: 'AzureAIDocIntel'
      }

      //document upload limits
      {
        name: 'DocumentMemory__FileSizeLimit'
        value: '50000000'
      }
      {
        name: 'DocumentMemory__FileCountLimit'
        value: '50'
      }

      //appinsights / misc
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
        value: '~2'
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
    ])
  }
}
