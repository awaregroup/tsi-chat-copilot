param location string
param resourcePrefix string

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
    siteConfig: {
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
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output appServiceFrontendName string = appServiceFrontend.name
// output appServiceAppSettings array = appServiceFrontend.properties.siteConfig.appSettings
