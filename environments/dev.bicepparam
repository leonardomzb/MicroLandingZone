
//dev.bicepparam
using '../main.bicep'

param location = 'centralus'
param projectCode = 'MicroLZ'
param environment = 'dev'

param vnetAddressSpace = '10.0.0.0/16'

param subnets = [
  {
    name: 'app-subnet'
    addressPrefix: '10.0.1.0/24'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: 'data-subnet'
    addressPrefix: '10.0.2.0/24'
    delegation: null
  }
]

