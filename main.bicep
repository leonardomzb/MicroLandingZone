
// main.bicep
metadata description = 'Main.bicep - Micro Landing Zone'

param location string = resourceGroup().location
@allowed(['dev', 'test', 'prod'])
param environment string
param projectCode string

param vnetAddressSpace string
param subnets array

var namingConvention = '${projectCode}-${environment}'

module keyVault './modules/modKeyVault.bicep' = {
  params: {
    location: location
    environment: environment
    kvName: 'kv-${namingConvention}-001'
  }
}

module vnet './modules/modVnet.bicep' = {
  params: {
    location: location
    addressSpace: vnetAddressSpace
    vnetName: 'vnet-${namingConvention}-001'
    subnets: subnets
  }
}

module appServicePlan './modules/modAppServicePlan.bicep' = {
  params: {
    location: location
    appServicePlanName: 'asp-${namingConvention}-001'
    environment: environment
  }
}

module logAnalytics './modules/modLogAnalytics.bicep' = {
  params: {
    location: location
    environment: environment
    logAnalyticsName: 'law-${namingConvention}-001'
  }
}

module appInsights './modules/modAppInsights.bicep' = {
  params: {
    location: location
    appiName: 'appi-${namingConvention}-001'
    workspaceResourceId: logAnalytics.outputs.logAnalyticsId
  }
}

module webApp './modules/webApp.bicep' = {
  params: {
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    webAppName: take('web${environment}${uniqueString(resourceGroup().id)}', 50)
    vnetIntegrationSubnetId: vnet.outputs.subnetResourceIds[0]
    appiId: appInsights.outputs.appiId
    kvName: keyVault.outputs.kvName
  }
}

module rbacKeyVault './modules/modRBACKeyVault.bicep' = {
  params: {
    keyVaultName: keyVault.outputs.kvName
    roleAssignments: [
      {
        principalId: webApp.outputs.webAppPrincipalId
        roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
      }
    ]
  }
}

