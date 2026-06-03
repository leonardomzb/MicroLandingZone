
//privateDNSZone.bicep
metadata description = 'Modulo de creacion de zona DNS privada'

@description('ID de la VNet a la que se asociarán las zonas DNS privadas')
param vnetId string

// DNS para Key Vault
module kvPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'kvPrivateDnsZoneDeployment'
  params: {
    name: 'privatelink${environment().suffixes.keyvaultDns}'
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: vnetId
      }
    ]
  }
}

// DNS para Key Vault
module sqlPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'sqlPrivateDnsZoneDeployment'
  params: {
    name: 'privatelink${environment().suffixes.sqlServerHostname}'
    location: 'global'
    virtualNetworkLinks: [
      {
        virtualNetworkResourceId: vnetId
      }
    ]
  }
}

output kvPrivateDnsZoneId string = kvPrivateDnsZone.outputs.resourceId
output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.outputs.resourceId
