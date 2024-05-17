param location string
param resourcePrefix string

//========================================================
//Azure AI Speech Service
//========================================================
resource aiSpeechAccount 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
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

output aiSpeechAccountName string = aiSpeechAccount.name

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

    //disable api key auth
    disableLocalAuth: true
  }
}

output aiSearchAccountName string = aiSearchAccount.name
