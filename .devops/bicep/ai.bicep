param location string
param resourcePrefix string
param useExternalAzureOpenAIEndpoint bool

//========================================================
//Azure AI Speech Service
//========================================================
resource speechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: '${resourcePrefix}-speech'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'SpeechServices'
  properties: {
    customSubDomainName: '${resourcePrefix}-speech'
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
  }
}

output speechAccountName string = speechAccount.name

//========================================================
//Azure AI Document Intelligence
//========================================================
resource documentIntelligenceAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: '${resourcePrefix}-ocr'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: '${resourcePrefix}-ocr'
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
  }
}

output documentIntelligenceAccountName string = documentIntelligenceAccount.name

//========================================================
//Azure AI Search
//========================================================
resource aiSearchAccount 'Microsoft.Search/searchServices@2022-09-01' = {
  name: '${resourcePrefix}-search'
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
  }
}

output aiSearchAccountName string = aiSearchAccount.name

//========================================================
//Azure OpenAI Service
//========================================================
resource azureOpenAIAccount 'Microsoft.CognitiveServices/accounts@2021-10-01' =
  if (useExternalAzureOpenAIEndpoint == false) {
    name: '${resourcePrefix}-oai'
    location: location
    sku: {
      name: 'S0'
    }
    kind: 'OpenAI'
    properties: {
      customSubDomainName: '${resourcePrefix}-oai'
      networkAcls: {
        defaultAction: 'Allow'
      }
      publicNetworkAccess: 'Enabled'
      apiProperties: {
        statisticsEnabled: false
      }
    }
  }

var completionModel = 'gpt-35-turbo'
resource azureOpenAICompletionDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' =
  if (useExternalAzureOpenAIEndpoint == false) {
    parent: azureOpenAIAccount
    name: completionModel
    sku: {
      name: 'Standard'
      capacity: 30
    }
    properties: {
      model: {
        format: 'OpenAI'
        name: completionModel
      }
    }
  }

var embeddingModel = 'text-embedding-ada-002'
resource azureOpenAIEmbeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' =
  if (useExternalAzureOpenAIEndpoint == false) {
    parent: azureOpenAIAccount
    name: embeddingModel
    sku: {
      name: 'Standard'
      capacity: 30
    }
    properties: {
      model: {
        format: 'OpenAI'
        name: embeddingModel
      }
    }
    dependsOn: [
      // This "dependency" is to create models sequentially because the resource
      azureOpenAICompletionDeployment // provider does not support parallel creation of models properly.
    ]
  }

output azureOpenAIAccountName string = useExternalAzureOpenAIEndpoint ? '' : azureOpenAIAccount.name
output azureOpenAIEndpoint string = useExternalAzureOpenAIEndpoint ? '' : azureOpenAIAccount.properties.endpoint
output azureOpenAIKey string = useExternalAzureOpenAIEndpoint ? '' : azureOpenAIAccount.listKeys().key1
output azureOpenAIDeploymentName string = useExternalAzureOpenAIEndpoint ? '' : azureOpenAICompletionDeployment.name
output azureOpenAIEmbeddingDeploymentName string = useExternalAzureOpenAIEndpoint
  ? ''
  : azureOpenAIEmbeddingDeployment.name
