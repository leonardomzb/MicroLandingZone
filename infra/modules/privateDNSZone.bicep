
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

// DNS PARA KEY VAULT
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

// DNS SERVER SQL
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

// DNS WEB APP
module webAppPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'webAppDnsZoneDeployment'
  params: {
    name: 'privatelink.azurewebsites.net'
    location: 'global'
    virtualNetworkLinks: networkLinks
    tags: {
      Environment: environment
    }
  }
}

output kvPrivateDnsZoneId string = kvPrivateDnsZone.outputs.resourceId
output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.outputs.resourceId
output webPrivateDnsZoneID string = webAppPrivateDnsZone.outputs.resourceId
