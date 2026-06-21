
// sqlServer.bicep
metadata description = 'Modulo de creacion de Azure SQL Server y base de datos'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Entorno de despliegue')
param environment string
@description('Nombre del servidor SQL a crear')
param sqlServerName string
@description('Nombre de la base de datos SQL a crear')
param databaseName string
@description('Nombre del Azure Key Vault que contiene el secreto sqlAdminPassword')
param keyVaultName string
@description('Nombre del Resource Group donde se creó el Key Vault') 
param keyVaultResourceGroupName string
@description('Nombre de usuario administrador del SQL Server')
param sqlAdminLogin string = 'sqlAdmin'
@description('Resource ID del Log Analytics Workspace para configurar diagnósticos')
param logAnalyticsId string

resource kvResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: keyVaultResourceGroupName
  scope: subscription()
}

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
  scope: kvResourceGroup
}

module server 'br/public:avm/res/sql/server:0.21.2' = {
  name: '${sqlServerName}-deployment'
  params: {
    location: location
    name: sqlServerName
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: keyVault.getSecret('sqlAdminPassword')
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
    databases: [
      {
        name: databaseName
        availabilityZone: environment == 'prod' ? 3 : -1
        zoneRedundant: false
        maxSizeBytes: environment == 'prod' ? 34359738368 : 2147483648
        sku: {
          name: environment == 'prod' ? 'S0' : 'Basic'
          tier: environment == 'prod' ? 'Standard' : 'Basic'
          capacity: environment == 'prod' ? 10 : 5
        }
        diagnosticSettings: [
          {
            name: 'diag-${sqlServerName}'
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
      }
    ]
    tags: {
      Environment: environment
    }
  }
}

@description('Resource ID del SQL Server creado')
output sqlServerResourceId string = server.outputs.resourceId
@description('Nombre del SQL Server creado')
output sqlServerName string = server.outputs.name
