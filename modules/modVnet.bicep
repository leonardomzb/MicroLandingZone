
// modVnet.bicep
metadata description = 'Modulo de creacion de Vnet'

param location string
param vnetName string
param addressSpace string
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
        addressPrefix: subnet.addressPrefix
        delegation: subnet.delegation
      }
    ]
  }
}

output vnetId string = virtualNetwork.outputs.resourceId
output subnetResourceIds array = virtualNetwork.outputs.subnetResourceIds

