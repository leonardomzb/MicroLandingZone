
// peering.bicep
metadata description = 'Modulo de creacion peering'

@description('Nombre de vnet Hub')
param vnetHubName string
@description('Nombre de vnet Spoke')
param vnetSpokeName string

resource vnetHub 'Microsoft.Network/virtualNetworks@2025-07-01' existing = {
  name: vnetHubName
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2025-07-01' existing = {
  name: vnetSpokeName
}

resource peerHubSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  parent: vnetHub
  name: 'hub-to-${vnetSpokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpoke.id
    }
  }
}

resource peerSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  parent: vnetSpoke
  name: '${vnetSpokeName}-to-Hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}
