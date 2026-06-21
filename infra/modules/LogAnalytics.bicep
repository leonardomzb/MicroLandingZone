
// modLogAnalytics.bicep
metadata description = 'Modulo de creacion de Log Analytics'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Entorno de despliegue')
param environment string
@description('Nombre de Log Analytics Workspace')
param logAnalyticsName string

module workspace 'br/public:avm/res/operational-insights/workspace:0.15.1' = {
  name: '${environment}-deployment'
  params: {
    name: logAnalyticsName
    location:location
    dailyQuotaGb: environment == 'prod' ? '90' : '60'
    tags: {
      Environment: environment
    }
  }
}

output logAnalyticsId string = workspace.outputs.resourceId

