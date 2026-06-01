
// main.bicep
metadata description = 'Main.bicep - Micro Landing Zone'

param location string = resourceGroup().location
@allowed(['dev', 'test', 'prod'])
param environment string
param projectCode string

param vnetAddressSpace string
param subnets array

var namingConvention = '${projectCode}-${environment}'

module vnet './modules/modVnet.bicep' = {
  params: {
    location: location
    addressSpace: vnetAddressSpace
    subnets: subnets
    vnetName: 'vnet-${namingConvention}-001'
  }
}

module appServicePlan './modules/modAppServicePlan.bicep' = {
  params: {
    location: location
    appServicePlanName: 'asp-${namingConvention}-001'
    environment: environment
  }
}

module webApp './modules/webApp.bicep' = {
  params: {
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    webAppName: take('web${environment}${uniqueString(resourceGroup().id)}', 50)
    //environment: environment
    //vnetIntegrationSubnetId: vnet.outputs.subnetIds[0]
  }
}

module logAnalytics './modules/modLogAnalytics.bicep' = {
  params: {
    location: location
    environment: environment
    logAnalyticsName: 'law-${namingConvention}-001'
  }
}

