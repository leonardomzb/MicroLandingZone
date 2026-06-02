
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

var namingConvention = '${projectCode}-${environment}'

//Key Vault para simular existencia previa de secretos
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

//Asignación de rol en Key Vault
module rbacKeyVault './modules/RBACKeyVault.bicep' = {
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    roleAssignments: [
      {
        principalId: webApp.outputs.webAppPrincipalId
        roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
      }
    ]
  }
}

