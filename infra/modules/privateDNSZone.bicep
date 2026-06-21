
//privateDNSZone.bicep
metadata description = 'Modulo de creacion de zona DNS privada'

@description('ID de la VNet a la que se asociarán las zonas DNS privadas')
param vnetIds array
@description('Entorno de despliegue')
param environment string

// Vnets id a formato AVM
var networkLinks = [for id in vnetIds: {
  virtualNetworkResourceId: id
}]

// DNS para Key Vault
module kvPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'kvPrivateDnsZoneDeployment'
  params: {
    name: 'privatelink${az.environment().suffixes.keyvaultDns}'
    location: 'global'
    virtualNetworkLinks: networkLinks
    tags: {
      Environment: environment
    }
  }
}

// DNS para Key Vault
module sqlPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'sqlPrivateDnsZoneDeployment'
  params: {
    name: 'privatelink${az.environment().suffixes.sqlServerHostname}'
    location: 'global'
    virtualNetworkLinks: networkLinks
    tags: {
      Environment: environment
    }
  }
}

output kvPrivateDnsZoneId string = kvPrivateDnsZone.outputs.resourceId
output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.outputs.resourceId
