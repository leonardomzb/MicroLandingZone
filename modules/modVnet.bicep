
// modVnet.bicep
metadata description = 'Modulo de creacion de Vnet'

param location string
param vnetName string
param addressSpace string
param subnets array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ addressSpace ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
      }
    }]
  }
}

output vnetId string = virtualNetwork.id
output subnetIds array = [for subnet in subnets:'${virtualNetwork.id}/subnets/${subnet.name}']

