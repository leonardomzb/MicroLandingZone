
// webApp.bicep
metadata description = 'Modulo de creacion de Web App'

param location string
//param environment string
param webAppName string
param appServicePlanId string
param vnetIntegrationSubnetId string?
param appiId string

module webApp 'br/public:avm/res/web/site:0.23.1' = {
  name: '${webAppName}-deployment'
  params: {
    name: webAppName
    kind: 'app'
    serverFarmResourceId: appServicePlanId
    virtualNetworkSubnetResourceId: vnetIntegrationSubnetId
    location: location
    siteConfig: {
      linuxFxVersion: 'NODE|20'
      vnetRouteAllEnabled: true
      minTlsVersion: '1.2'      
    }
    configs: !empty(appiId)
      ? [
          {
            name: 'appsettings'
            applicationInsightResourceId: appiId
          }
        ]
      : []    
  }  
}

output webAppId string = webApp.outputs.resourceId
output webAppSefaultHostname string = webApp.outputs.defaultHostname

