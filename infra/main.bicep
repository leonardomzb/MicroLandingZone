
// main.bicep
metadata description = 'Main.bicep - Landing Zone'

targetScope= 'resourceGroup'

@description('Código o identificador del proyecto utilizado en la nomenclatura de recursos')
param projectCode string

@description('Región de Azure donde se desplegarán los recursos')
param location string 

@description('Nombre de key vault dedicada al ambiente')
param keyVaultName string

param keyVaultResourceGroupName string

@description('Entorno de despliegue')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Datos de configuracion de vnets')
param vnetConfig array

@description('Convención de nomenclatura base para los recursos')
var namingConvention = replace(toLower('${environment}-${projectCode}'),  ' ',  '')

//  VNET HUB
module vnetshub 'modules/Vnet.bicep' = {
  name:'vnet-hub'
  params: {
    location: location
    addressSpace: vnetConfig[0].addressPrefix
    subnets: vnetConfig[0].subnets
    vnetName: '${vnetConfig[0].name}-${namingConvention}-001'
    environment: environment
  }
}

//  VNET SPOKE
module vnetsspoke 'modules/Vnet.bicep' = {
  dependsOn: [
    vnetshub
  ]
  name: 'vnet-spoke'
  params: {
    location: location
    addressSpace: vnetConfig[1].addressPrefix
    subnets: vnetConfig[1].subnets
    vnetName: '${vnetConfig[1].name}-${namingConvention}-001'
    environment: environment
  }
}


//  VNET PEERING HUB-SPOKE
module peering 'modules/peerHubSpoke.bicep' = {
  name: 'vnet-peering-hub-spoke' 
  params: {
    vnetHubName: vnetshub.outputs.vnetName
    vnetSpokeName: vnetsspoke.outputs.vnetName
  }
}

//  ZONAS DNS PRIVADAS
module dnsPZone './modules/privateDNSZone.bicep' = {
  name: 'private-dns-zones'
  params: {
    vnetIds: [
      vnetshub.outputs.vnetId
      vnetsspoke.outputs.vnetId
    ]
    environment: environment
  }
}

//  LOG ANALYTICS WORKSPACE
module logAnalytics './modules/LogAnalytics.bicep' = {
  name: 'log-analytics'
  params: {
    location: location
    environment: environment
    logAnalyticsName: 'law-${namingConvention}-001'
  }
}

//  APPLICATION INSIGHTS
module appInsights './modules/AppInsights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
    appiName: 'appi-${namingConvention}-001'
    workspaceResourceId: logAnalytics.outputs.logAnalyticsId
    environment: environment
  }
}

//  APP SERVICE PLAN
module appServicePlan './modules/AppServicePlan.bicep' = {
  name: 'app-service-plan'
  params: {
    location: location
    appServicePlanName: 'asp-${namingConvention}-001'
    environment: environment
  }
}

//  WEB APP
module webApp './modules/webApp.bicep' = {
  name: 'web-app'
  params: {
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    webAppName: take('web${environment}${uniqueString(resourceGroup().id)}', 50)
    vnetIntegrationSubnetId: '${vnetsspoke.outputs.vnetId}/subnets/snet-web-app'
    appiId: appInsights.outputs.appiId
    keyVaultName: keyVaultName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    environment: environment
  }
}


//  SQL SERVER
module sqlServer './modules/sqlServer.bicep' = {
  name: 'sql-server'
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

//  RBACK KEY VAULT
module rbacKeyVault './modules/RBACKeyVault.bicep' = {
  name: 'rbac-key-vault'
  scope: resourceGroup(keyVaultResourceGroupName) 
   dependsOn: [
    vnetshub
  ]
  params: {
    keyVaultName: keyVaultName    
    roleAssignments: [
      {
        principalId: webApp.outputs.webAppPrincipalId
        roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}


// PRIVATE ENDPOINT KEYVAULT
module privateEndpointKeyVault './modules/privateEndpoint.bicep' = {
  name: 'private-endpoint-keyvault'  
  params: {
    location: location
    groupIds: [
      'vault'
    ]
    privateEndpointName: 'pep-kv-${namingConvention}-001'
    privateEndpointSubnetId: '${vnetshub.outputs.vnetId}/subnets/snet-hub-private-endpoints'
    privateLinkName: 'kvLink-${namingConvention}-001'
    privateLinkServiceId: keyVault.id
    privateDnsZoneId: dnsPZone.outputs.kvPrivateDnsZoneId
    environment: environment
  }
}


// PRIVATE ENDPOINT SERVIDOR SQL
module privateEndpointSqlServer './modules/privateEndpoint.bicep' = {
  name: 'private-endpoint-sql-server'
  params: {
    location: location
    groupIds: [
      'sqlServer'
    ]
    privateEndpointName: 'pep-sql-${namingConvention}-001'
    privateEndpointSubnetId: '${vnetsspoke.outputs.vnetId}/subnets/snet-spoke-private-endpoints'
    privateLinkName: 'sqlLink-${namingConvention}-001'
    privateLinkServiceId: sqlServer.outputs.sqlServerResourceId
    privateDnsZoneId: dnsPZone.outputs.sqlPrivateDnsZoneId
    environment: environment
  }
}


// PRIVATE ENDPOINT WEB APP
module privateEndpointWebApp './modules/privateEndpoint.bicep' = {
  name: 'private-endpoint-web-app'  
  params: {
    location: location
    groupIds: [
      'sites'
    ]
    privateEndpointName: 'pep-web-${namingConvention}-001'
    privateEndpointSubnetId: '${vnetsspoke.outputs.vnetId}/subnets/snet-spoke-private-endpoints'
    privateLinkName: 'webLink-${namingConvention}-001'
    privateLinkServiceId: webApp.outputs.webAppResourceId
    privateDnsZoneId: dnsPZone.outputs.webPrivateDnsZoneID
    environment: environment
  }
}


// APPLICATION GATEWAY WAF V2
module appGateway 'modules/AppGateway.bicep' = {
  name: 'app-gateway-deployment'
  params: {
    location: location
    agwName: 'agw-${namingConvention}-001'
    environment: environment
    webAppName: webApp.outputs.webAppName
    appGatewaySubnet: '${vnetshub.outputs.vnetId}/subnets/snet-app-gateway'
  }
}
