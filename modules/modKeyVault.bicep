
// modKeyVault.bicep
metadata description = 'Modulo de creacion de Key Vault (Simulando una keyVault con secretos ya existente)'

param location string
param kvName string
param environment string

var sqlAdminPassword = '${uniqueString(resourceGroup().id, deployment().name)}${kvName}'

module vault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: '${kvName}-deployment'
  params: {
    name: kvName
    location: location
    enablePurgeProtection: environment == 'prod' ? true : false
    enableSoftDelete: true
    softDeleteRetentionInDays: environment == 'prod' ? 90 : 7    
    enableRbacAuthorization: true
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

output kvName string = vault.outputs.name
output kvUri string = vault.outputs.uri

