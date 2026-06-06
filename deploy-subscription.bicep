
// deploy-subscription.bicep
metadata description = 'Despliegue a nivel de suscripción para Micro Landing Zone'

targetScope = 'subscription'

@description('Región de Azure donde se desplegarán los recursos')
param location string 

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

@description('Configuración de subredes de la VNet')
param subnets array

var namingConvention = replace(toLower('${projectCode}-${environment}'),  ' ',  '')

//Creacion de Resource Group para Key Vault
resource kvResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'existingKvRG'
  location: location
}

//Creacion de Key Vault para simular existencia de secretos
module keyVault './modules/KeyVault.bicep' = {
  name:'key-vault-deployment'
  scope: kvResourceGroup
  params: {
    location: location
    environment: environment
    keyVaultName: take('kv-${namingConvention}-${uniqueString(kvResourceGroup.id)}', 24)
  }
}

//Creacion de Resource Group para Landing Zone
resource landingZoneResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-${namingConvention}-001'
  location: location
}

module landingZone './main.bicep' = {
  name: 'landing-zone-deployment'
  scope: landingZoneResourceGroup
  params:{
    location: location
    environment: environment
    namingConvention: namingConvention
    keyVaultName: keyVault.outputs.keyVaultName
    keyVaultResourceId: keyVault.outputs.kvResourceId
    keyVaultResourceGroupName: keyVault.outputs.kvResourceGroupName
    subnets: subnets
    vnetAddressSpace: vnetAddressSpace
  }
}
