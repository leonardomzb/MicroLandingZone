
// modKeyVault.bicep
metadata description = 'Modulo de creacion de Key Vault (Simulando una keyVault con secretos ya existente)'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Nombre del Azure Key Vault')
param keyVaultName string
@description('Entorno de despliegue')
param environment string

var sqlAdminPassword = '${uniqueString(resourceGroup().id, deployment().name)}${keyVaultName}'

module vault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: '${keyVaultName}-deployment'
  params: {
    name: keyVaultName
    location: location
    enablePurgeProtection: environment == 'prod' ? true : false
    enableSoftDelete: true
    softDeleteRetentionInDays: environment == 'prod' ? 90 : 7    
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    secrets: [
      {
        name: 'sqlAdminPassword'
        value: sqlAdminPassword
        contentType: 'text/plain'
        attributes: {
          enabled: true
        }
      }
    ]
  }  
}

@description('Nombre del Key Vault creado')
output keyVaultName string = vault.outputs.name
@description('URI del Key Vault creado')
output kvUri string = vault.outputs.uri
@description('ID del recurso del Key Vault creado')
output kvResourceId string = vault.outputs.resourceId

