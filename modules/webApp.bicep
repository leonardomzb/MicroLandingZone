
// webApp.bicep
metadata description = 'Modulo de creacion de Web App'

param location string
param webAppName string
param appServicePlanId string
param vnetIntegrationSubnetId string?
param appiId string
param kvName string

module webApp 'br/public:avm/res/web/site:0.23.1' = {
  name: '${webAppName}-deployment'
  params: {
    name: webAppName
    kind: 'app'
    serverFarmResourceId: appServicePlanId
    virtualNetworkSubnetResourceId: vnetIntegrationSubnetId
    location: location
    managedIdentities: {
      systemAssigned: true
    }
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
            properties: {
              SQL_ADMIN_PASSWORD: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sqlAdminPassword)'
            }
          }
        ]
      : []    
  }  
}

output webAppId string = webApp.outputs.resourceId
output webAppDefaultHostname string = webApp.outputs.defaultHostname
output webAppPrincipalId string = webApp.outputs.systemAssignedMIPrincipalId!

