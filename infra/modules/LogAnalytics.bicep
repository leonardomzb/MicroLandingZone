
// modLogAnalytics.bicep
metadata description = 'Modulo de creacion de Log Analytics'

param location string
param environment string
param logAnalyticsName string

module workspace 'br/public:avm/res/operational-insights/workspace:0.15.1' = {
  name: '${environment}-deployment'
  params: {
    name: logAnalyticsName
    location:location
    dailyQuotaGb: environment == 'prod' ? '90' : '60'
  }
}

output logAnalyticsId string = workspace.outputs.resourceId

