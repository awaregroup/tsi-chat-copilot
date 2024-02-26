param resourcePrefix string
param location string
param appServiceFrontendName string
param appServiceMemoryPipelineName string

resource appServiceFrontend 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceFrontendName
}

resource appServiceMemoryPipeline 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceMemoryPipelineName
}

resource appInsightExtensionWeb 'Microsoft.Web/sites/siteextensions@2022-09-01' = {
  parent: appServiceFrontend
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
}

resource appInsightExtensionMemory 'Microsoft.Web/sites/siteextensions@2022-09-01' = {
  parent: appServiceMemoryPipeline
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${resourcePrefix}-la'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourcePrefix}-ai'
  location: location
  kind: 'string'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output appInsightsName string = appInsights.name
