
// main.bicep
metadata description = 'Main.bicep - Micro Landing Zone'

@description('Región de Azure donde se desplegarán los recursos')
param location string = resourceGroup().location

@description('Entorno de despliegue')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Código o identificador del proyecto utilizado en la nomenclatura de recursos')
param projectCode string

@description('Espacio de direcciones CIDR asignado a la red virtual')
param vnetAddressSpace string

type subnetConfig = {
  name: string
  addressPrefix: string
  delegation: string
}
@description('Configuración de subredes de la VNet')
param subnets array

var namingConvention = replace(toLower('${projectCode}-${environment}'),  ' ',  '')

//Key Vault para simular existencia de secretos
module keyVault './modules/KeyVault.bicep' = {
  params: {
    location: location
    environment: environment
    keyVaultName: take('kv-${namingConvention}-${uniqueString(resourceGroup().id)}', 24)
  }
}

//Vnet con Subnets
module vnet './modules/Vnet.bicep' = {
  params: {
    location: location
    addressSpace: vnetAddressSpace
    vnetName: 'vnet-${namingConvention}-001'
    subnets: subnets
  }
}

//App Service Plan
module appServicePlan './modules/AppServicePlan.bicep' = {
  params: {
    location: location
    appServicePlanName: 'asp-${namingConvention}-001'
    environment: environment
  }
}

//Log Analytics Workspace
module logAnalytics './modules/LogAnalytics.bicep' = {
  params: {
    location: location
    environment: environment
    logAnalyticsName: 'law-${namingConvention}-001'
  }
}

//App Insights
module appInsights './modules/AppInsights.bicep' = {
  params: {
    location: location
    appiName: 'appi-${namingConvention}-001'
    workspaceResourceId: logAnalytics.outputs.logAnalyticsId
  }
}

//Web App
module webApp './modules/webApp.bicep' = {
  params: {
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    webAppName: take('web${environment}${uniqueString(resourceGroup().id)}', 50)
    vnetIntegrationSubnetId: vnet.outputs.subnetResourceIds[0]
    appiId: appInsights.outputs.appiId
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

//SQL Server
module sqlServer './modules/sqlServer.bicep' = {
  params: {
    location: location
    sqlServerName: take('sql-${namingConvention}-${uniqueString(resourceGroup().id)}-001', 63)
    databaseName: 'sqldb-${namingConvention}-001'
    environment: environment
    keyVaultName: keyVault.outputs.keyVaultName
  }
}


//Asignación de roles a Key Vault
module rbacKeyVault './modules/RBACKeyVault.bicep' = {
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    roleAssignments: [
      {
        principalId: webApp.outputs.webAppPrincipalId
        roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

//Simulacion de existencia de zonas DNS privadas
module dnsPZone './modules/privateDNSZone.bicep' = {
  name: 'layer-dnspzone-deployment'
  params: {
    vnetId: vnet.outputs.vnetId
  }
}

//Private Endpoint para Key Vault
module privateEndpointKeyVault './modules/privateEndpoint.bicep' = {
  params: {
    location: location
    groupIds: [
      'vault'
    ]
    privateEndpointName: 'pep-kv-${namingConvention}-001'
    privateEndpointSubnetId: vnet.outputs.subnetResourceIds[1]
    privateLinkName: 'kvLink-${namingConvention}-001'
    privateLinkServiceId: keyVault.outputs.kvResourceId
    privateDnsZoneId: dnsPZone.outputs.kvPrivateDnsZoneId
  }
}

//Private Endpoint para SQL Server
module privateEndpointSqlServer './modules/privateEndpoint.bicep' = {
  params: {
    location: location
    groupIds: [
      'sqlServer'
    ]
    privateEndpointName: 'pep-sql-${namingConvention}-001'
    privateEndpointSubnetId: vnet.outputs.subnetResourceIds[1]
    privateLinkName: 'sqlLink-${namingConvention}-001'
    privateLinkServiceId: sqlServer.outputs.sqlServerResourceId
    privateDnsZoneId: dnsPZone.outputs.sqlPrivateDnsZoneId
  }
}
