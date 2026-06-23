
// webApp.bicep
metadata description = 'Modulo de creacion de Web App'

param location string
@description('Nombre de la Web App')
param webAppName string
@description('Resource ID del App Service Plan donde se hospedará la Web App')
param appServicePlanId string
@description('Resource ID de la subnet utilizada para VNet Integration. Opcional')
param vnetIntegrationSubnetId string?
@description('Resource ID de Application Insights')
param appiId string
@description('Nombre del Azure Key Vault utilizado por la aplicación')
param keyVaultName string
@description('Resource ID del Log Analytics Workspace para configurar diagnósticos')
param logAnalyticsId string
@description('Entorno de despliegue')
param environment string

module webApp 'br/public:avm/res/web/site:0.23.1' = {
  name: '${webAppName}-deployment'
  params: {
    name: webAppName
    kind: 'app'
    serverFarmResourceId: appServicePlanId
    virtualNetworkSubnetResourceId: vnetIntegrationSubnetId
    location: location
    publicNetworkAccess: 'Disabled'
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
              SQL_ADMIN_PASSWORD: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=sqlAdminPassword)'
            }
          }
        ]
      : []
    diagnosticSettings: [
      {
        name: 'diag-${webAppName}'
        workspaceResourceId: logAnalyticsId
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    tags: {
      Environment: environment
    }
  }
}

@description('Resource ID de la Web App creada')
output webAppResourceId string = webApp.outputs.resourceId
@description('Hostname predeterminado de la Web App')
output webAppDefaultHostname string = webApp.outputs.defaultHostname
@description('ID del principal de identidad administrada de la Web App')
output webAppPrincipalId string = webApp.outputs.systemAssignedMIPrincipalId!
@description('Nombre de la Web App creada')
output webAppName string = webApp.outputs.name
