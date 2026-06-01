
// modAppServicePlan.bicep
metadata description = 'Modulo de creacion de Vnet'

param location string
param environment string
param appServicePlanName string

module appServicePlan 'br/public:avm/res/web/serverfarm:0.7.0' = {
  name: '${appServicePlanName}-deployment'
  params: {
    name: appServicePlanName
    location: location
    kind: 'linux'
    skuCapacity: environment == 'prod' ? 3 : 1
    skuName: environment == 'prod' ? 'P1v3' : 'B1'
    zoneRedundant: environment == 'prod' ? true : false
  }
}

output appServicePlanId string = appServicePlan.outputs.resourceId

