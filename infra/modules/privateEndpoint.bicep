// modules/privateEndpoint.bicep
metadata description = 'Modulo de creación de Private Endpoint Generico'

@description('Región de Azure donde se desplegará el Private Endpoint')
param location string
@description('Nombre del Private Endpoint a crear')
param privateEndpointName string
@description('Resource ID de la Subnet donde se desplegará el Private Endpoint')
param privateEndpointSubnetId string
@description('Nombre del Private Link a crear')
param privateLinkName string
@description('Resource ID del Private Link Service')
param privateLinkServiceId string
@description('Lista de Group IDs para la conexión del Private Endpoint')
param groupIds array
@description('Resource ID de la zona DNS privada')
param privateDnsZoneId string = ''

module privateEndpoint 'br/public:avm/res/network/private-endpoint:0.12.1' = {
  name: 'pep-${privateEndpointName}-deployment'
  params: {
    name: privateEndpointName
    location: location
    subnetResourceId: privateEndpointSubnetId
    privateLinkServiceConnections: [
      {
        name: privateLinkName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
    privateDnsZoneGroup: !empty(privateDnsZoneId)
      ? {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneId
            }
          ]
        }
      : null
  }
}
