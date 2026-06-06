
// main.bicep
metadata description = 'Main.bicep - Micro Landing Zone'

@description('Región de Azure donde se desplegarán los recursos')
param location string 

@description('Entorno de despliegue')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Espacio de direcciones CIDR asignado a la red virtual')
param vnetAddressSpace string

type subnetConfig = {
  name: string
  addressPrefix: string
  delegation: string
}
@description('Configuración de subredes de la VNet')
param subnets array

@description('Nombre del Key Vault creado en el módulo de simulación')
param keyVaultName string
@description('ID del recurso del Key Vault creado en el módulo de simulación') 
param keyVaultResourceId string
@description('Nombre del Resource Group donde se creó el Key Vault')
param keyVaultResourceGroupName string

@description('Convención de nomenclatura base para los recursos')
param namingConvention string

//Vnet con Subnets
module vnet './modules/Vnet.bicep' = {
  params: {
    location: location
    addressSpace: vnetAddressSpace
    vnetName: 'vnet-${namingConvention}-001'
    subnets: subnets
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

//App Service Plan
module appServicePlan './modules/AppServicePlan.bicep' = {
  params: {
    location: location
    appServicePlanName: 'asp-${namingConvention}-001'
    environment: environment
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
    keyVaultName: keyVaultName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
  }
}

//SQL Server
module sqlServer './modules/sqlServer.bicep' = {
  params: {
    location: location
    sqlServerName: take('sql-${namingConvention}-${uniqueString(resourceGroup().id)}-001', 63)
    databaseName: 'sqldb-${namingConvention}-001'
    environment: environment
    keyVaultName: keyVaultName
    keyVaultResourceGroupName: keyVaultResourceGroupName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
  }
}


//Asignación de roles a Key Vault
module rbacKeyVault './modules/RBACKeyVault.bicep' = {
  params: {
    keyVaultName: keyVaultName
    keyVaultResourceGroupName: keyVaultResourceGroupName
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
    privateLinkServiceId: keyVaultResourceId
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
