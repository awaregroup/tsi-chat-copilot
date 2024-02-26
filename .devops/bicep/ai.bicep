param resourcePrefix string
param location string
param useExternalAzureOpenAIEndpoint bool

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

resource ocrAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
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

output ocrAccountName string = ocrAccount.name

resource azureOpenAIAccount 'Microsoft.CognitiveServices/accounts@2021-10-01' = if (useExternalAzureOpenAIEndpoint == false) {
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

output azureOpenAIAccountName string = azureOpenAIAccount.name

resource azureSearchAccount 'Microsoft.Search/searchServices@2022-09-01' = {
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

output azureSearchAccountName string = azureSearchAccount.name
