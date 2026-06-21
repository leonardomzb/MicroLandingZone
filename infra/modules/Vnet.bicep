
// modVnet.bicep
metadata description = 'Modulo de creacion de Vnet'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Nombre de la VNet a crear')
param vnetName string
@description('Espacio de direcciones CIDR asignado a la red virtual')
param addressSpace string
@description('Lista de subredes a crear')
param subnets array

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.9.0' = {
  name: '${vnetName}-deployment'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [addressSpace]
    subnets: [
      for (subnet, index) in subnets: {
        name: subnet.name
        addressPrefix: subnet.ipAddressRange
        delegation: subnet.delegation
      }
    ]
  }
}


@description('Resource ID de la VNet creada')
output vnetId string = virtualNetwork.outputs.resourceId
@description('Nombre de la VNet creada')
output vnetName string = virtualNetwork.outputs.name
@description('IDs de recurso de las subredes creadas')
output subnetResourceIds array = virtualNetwork.outputs.subnetResourceIds

