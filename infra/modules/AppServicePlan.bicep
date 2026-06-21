
// modAppServicePlan.bicep
metadata description = 'Modulo de creacion de Vnet'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Entorno de despliegue')
param environment string
@description('Nombre del plan de servicio de aplicación')
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
    tags: {
      Environment: environment
    }
  }
}

output appServicePlanId string = appServicePlan.outputs.resourceId

