param resourcePrefix string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${resourcePrefix}-asp'
  location: location
  kind: 'app'
  sku: {
    name: 'P1V3'
  }
}

output appServicePlanId string = appServicePlan.id

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' = {
  name: '${resourcePrefix}-web'
  location: location
  kind: 'app'
  tags: {
    skweb: '1'
    applicationRole: 'frontend'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appServiceFrontendName string = appServiceFrontend.name

resource appServiceMemoryPipeline 'Microsoft.Web/sites@2022-09-01' = {
  name: '${resourcePrefix}-memorypipeline'
  location: location
  kind: 'app'
  tags: {
    skweb: '1'
    applicationRole: 'memorypipeline'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    // virtualNetworkSubnetId: memoryStore == 'Qdrant' ? virtualNetwork.properties.subnets[0].id : null
    siteConfig: {
      healthCheckPath: '/healthz'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appServiceMemoryPipelineName string = appServiceMemoryPipeline.name
