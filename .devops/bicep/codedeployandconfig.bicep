param location string
param appServiceFrontendName string
param appServiceMemoryPipelineName string
param appServiceFrontendPackageUri string
param appServiceMemoryPipelinePackageUri string
param storageAccountName string
param azureSearchAccountName string
// param azureOpenAIAccountName string
param appInsightsName string
param azureOcrAccountName string
param cosmosAccountName string
param speechAccountName string

param azureAdInstance string
param azureAdTenantId string
param azureAdFrontendClientId string
param azureAdBackendClientId string

param useExternalAzureOpenAIEndpoint bool
param externalAzureOpenAIEndpoint string
param externalAzureOpenAIDeploymentName string
param externalAzureOpenAIEmbeddingDeploymentName string
param externalAzureOpenAIKey string = ''

resource speechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: speechAccountName
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource ocrAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: azureOcrAccountName
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource azureSearchAccount 'Microsoft.Search/searchServices@2022-09-01' existing = {
  name: azureSearchAccountName
}

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

resource appServiceMemoryPipeline 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceMemoryPipelineName
}

resource appServiceWebDeployFrontend 'Microsoft.Web/sites/extensions@2022-09-01' = {
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

resource appServiceWebDeployMemoryPipeline 'Microsoft.Web/sites/extensions@2022-09-01' = {
  name: 'onedeploy'
  parent: appServiceMemoryPipeline
  dependsOn: [
    appServiceMemoryPipelineConfig
  ]
  properties: {
    type: 'zip'
    clean: true
    packageUri: appServiceMemoryPipelinePackageUri
  }
}

var aiService = 'AzureOpenAI'
var memoryStore = 'AzureCognitiveSearch'
resource appServiceMemoryPipelineConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appServiceMemoryPipeline
  name: 'web'
  properties: union(
    appServiceFrontend.properties,

    {
      http20Enabled: true
      alwaysOn: true
      detailedErrorLoggingEnabled: true
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v6.0'
      use32BitWorkerProcess: false
      vnetRouteAllEnabled: true
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'KernelMemory:ContentStorageType'
          value: 'AzureBlobs'
        }
        {
          name: 'KernelMemory:TextGeneratorType'
          value: aiService
        }
        {
          name: 'KernelMemory:ImageOcrType'
          value: 'AzureFormRecognizer'
        }
        {
          name: 'KernelMemory:DataIngestion:OrchestrationType'
          value: 'Distributed'
        }
        {
          name: 'KernelMemory:DataIngestion:DistributedOrchestration:QueueType'
          value: 'AzureQueue'
        }
        {
          name: 'KernelMemory:DataIngestion:EmbeddingGeneratorTypes:0'
          value: aiService
        }
        {
          name: 'KernelMemory:DataIngestion:VectorDbTypes:0'
          value: memoryStore
        }
        {
          name: 'KernelMemory:Retrieval:VectorDbType'
          value: memoryStore
        }
        {
          name: 'KernelMemory:Retrieval:EmbeddingGeneratorType'
          value: aiService
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:Auth'
          value: 'ConnectionString'
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:ConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[1].value}'
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:Container'
          value: 'chatmemory'
        }
        {
          name: 'KernelMemory:Services:AzureQueue:Auth'
          value: 'ConnectionString'
        }
        {
          name: 'KernelMemory:Services:AzureQueue:ConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[1].value}'
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:Endpoint'
          value: memoryStore == 'AzureCognitiveSearch' ? 'https://${azureSearchAccount.name}.search.windows.net' : ''
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:APIKey'
          value: memoryStore == 'AzureCognitiveSearch' ? azureSearchAccount.listAdminKeys().primaryKey : ''
        }
        // {
        //   name: 'KernelMemory:Services:Qdrant:Endpoint'
        //   value: memoryStore == 'Qdrant' ? 'https://${appServiceQdrant.properties.defaultHostName}' : ''
        // }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Endpoint'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEndpoint : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Deployment'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIDeploymentName : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Endpoint'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEndpoint : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Deployment'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEmbeddingDeploymentName : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:AzureFormRecognizer:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureFormRecognizer:Endpoint'
          value: ocrAccount.properties.endpoint
        }
        {
          name: 'KernelMemory:Services:AzureFormRecognizer:APIKey'
          value: ocrAccount.listKeys().key1
        }
        {
          name: 'KernelMemory:Services:OpenAI:TextModel'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIDeploymentName : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:OpenAI:EmbeddingModel'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEmbeddingDeploymentName : '' //TODO: revisit these
        }
        {
          name: 'KernelMemory:Services:OpenAI:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : '' //TODO: revisit these
        }
        {
          name: 'Logging:LogLevel:Default'
          value: 'Information'
        }
        {
          name: 'Logging:LogLevel:AspNetCore'
          value: 'Warning'
        }
        {
          name: 'Logging:ApplicationInsights:LogLevel:Default'
          value: 'Warning'
        }
        {
          name: 'ApplicationInsights:ConnectionString'
          value: appInsights.properties.ConnectionString
        }
      ]
    })
}

resource appServiceFrontendConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appServiceFrontend
  name: 'web'
  properties: {
    http20Enabled: true
    alwaysOn: false
    cors: {
      allowedOrigins: [
        'http://localhost:3000'
        'https://localhost:3000'
      ]
      supportCredentials: true
    }
    detailedErrorLoggingEnabled: true
    minTlsVersion: '1.2'
    netFrameworkVersion: 'v6.0'
    use32BitWorkerProcess: false
    vnetRouteAllEnabled: true
    webSocketsEnabled: true
    appSettings: concat([
        {
          name: 'Authentication:Type'
          value: 'AzureAd'
        }
        {
          name: 'Authentication:AzureAd:Instance'
          value: azureAdInstance
        }
        {
          name: 'Authentication:AzureAd:TenantId'
          value: azureAdTenantId
        }
        {
          name: 'Authentication:AzureAd:ClientId'
          value: azureAdBackendClientId
        }
        {
          name: 'Frontend:AadClientId'
          value: azureAdFrontendClientId
        }
        {
          name: 'Authentication:AzureAd:Scopes'
          value: 'access_as_user'
        }
        {
          name: 'Planner:Model'
          value: 'gpt-35-turbo'
        }
        {
          name: 'ChatStore:Type'
          value: 'cosmos'
        }
        {
          name: 'ChatStore:Cosmos:Database'
          value: 'CopilotChat'
        }
        {
          name: 'ChatStore:Cosmos:ChatSessionsContainer'
          value: 'chatsessions'
        }
        {
          name: 'ChatStore:Cosmos:ChatMessagesContainer'
          value: 'chatmessages'
        }
        {
          name: 'ChatStore:Cosmos:ChatMemorySourcesContainer'
          value: 'chatmemorysources'
        }
        {
          name: 'ChatStore:Cosmos:ChatParticipantsContainer'
          value: 'chatparticipants'
        }
        {
          name: 'ChatStore:Cosmos:ConnectionString'
          value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'AzureSpeech:Region'
          value: location
        }
        {
          name: 'AzureSpeech:Key'
          value: speechAccount.listKeys().key1
        }
        {
          name: 'AllowedOrigins'
          value: '[*]' // Defer list of allowed origins to the Azure service app's CORS configuration
        }
        {
          name: 'Kestrel:Endpoints:Https:Url'
          value: 'https://localhost:443'
        }

        {
          name: 'Logging:LogLevel:Default'
          value: 'Warning'
        }
        {
          name: 'Logging:LogLevel:CopilotChat.WebApi'
          value: 'Warning'
        }
        {
          name: 'Logging:LogLevel:Microsoft.SemanticKernel'
          value: 'Warning'
        }
        {
          name: 'Logging:LogLevel:Microsoft.AspNetCore.Hosting'
          value: 'Warning'
        }
        {
          name: 'Logging:LogLevel:Microsoft.Hosting.Lifetimel'
          value: 'Warning'
        }
        {
          name: 'Logging:ApplicationInsights:LogLevel:Default'
          value: 'Warning'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'KernelMemory:ContentStorageType'
          value: 'AzureBlobs'
        }
        {
          name: 'KernelMemory:TextGeneratorType'
          value: aiService
        }
        {
          name: 'KernelMemory:DataIngestion:OrchestrationType'
          value: 'InProcess'
        }
        {
          name: 'KernelMemory:DataIngestion:DistributedOrchestration:QueueType'
          value: 'AzureQueue'
        }
        {
          name: 'KernelMemory:DataIngestion:EmbeddingGeneratorTypes:0'
          value: aiService
        }
        {
          name: 'KernelMemory:DataIngestion:VectorDbTypes:0'
          value: memoryStore
        }
        {
          name: 'KernelMemory:Retrieval:VectorDbType'
          value: memoryStore
        }
        {
          name: 'KernelMemory:Retrieval:EmbeddingGeneratorType'
          value: aiService
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:Auth'
          value: 'AzureIdentity'
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:ConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[1].value}'
        }
        {
          name: 'KernelMemory:Services:AzureBlobs:Container'
          value: 'chatmemory'
        }
        {
          name: 'KernelMemory:Services:AzureQueue:Auth'
          value: 'AzureIdentity'
        }
        {
          name: 'KernelMemory:Services:AzureQueue:ConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[1].value}'
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:Auth'
          value: 'AzureIdentity'
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:Endpoint'
          value: 'https://${azureSearchAccount.name}.search.windows.net'
        }
        {
          name: 'KernelMemory:Services:AzureCognitiveSearch:APIKey'
          value: azureSearchAccount.listAdminKeys().primaryKey
        }
        // {
        //   name: 'KernelMemory:Services:Qdrant:Endpoint'
        //   value: memoryStore == 'Qdrant' ? 'https://${appServiceQdrant.properties.defaultHostName}' : ''
        // }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Endpoint'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEndpoint : ''
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : ''
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIText:Deployment'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIDeploymentName : ''
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Auth'
          value: 'ApiKey'
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Endpoint'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEndpoint : ''
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : ''
        }
        {
          name: 'KernelMemory:Services:AzureOpenAIEmbedding:Deployment'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEmbeddingDeploymentName : ''
        }
        {
          name: 'KernelMemory:Services:OpenAI:TextModel'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIDeploymentName : ''
        }
        {
          name: 'KernelMemory:Services:OpenAI:EmbeddingModel'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIEmbeddingDeploymentName : ''
        }
        {
          name: 'KernelMemory:Services:OpenAI:APIKey'
          value: useExternalAzureOpenAIEndpoint ? externalAzureOpenAIKey : ''
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    )
  }
}
