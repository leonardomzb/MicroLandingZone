
using '../../main.bicep'

param projectCode = 'hubspoke' //Solo letras
param environment = 'dev'
param location = 'centralus'
param keyVaultName = 'kv-dev-hubspoke-001'
param keyVaultResourceGroupName = 'rg-kv-dev-hubspoke-001'

param vnetConfig = [
  {
    name: 'vnethub'
    addressPrefix: '10.10.0.0/16'
    subnets: [
      {
        name: 'snet-app-gateway'
        ipAddressRange: '10.10.1.0/24'
        delegation: null
      }
      {
        name: 'snet-hub-private-endpoints'
        ipAddressRange: '10.10.2.0/24'
        delegation: null
      }
    ]
  }

  {
    name: 'vnetspoke'
    addressPrefix: '10.20.0.0/16'
    subnets: [
      {
        name: 'snet-web-app'
        ipAddressRange: '10.20.1.0/24'
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-spoke-private-endpoints'
        ipAddressRange: '10.20.2.0/24'
        delegation: null
      }
    ]
  }
]
