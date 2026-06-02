
// modRBACKeyVault.bicep
metadata description = 'Modulo para la asginacion de permisos RBAC'

@description('Nombre de key vault')
param keyVaultName string
@description('Arreglo con Id de identidad junto con Id de rol a asignar')
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource roleAssignmentsResource 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    scope: keyVault
    name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
    properties: {
      principalId: assignment.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalType: 'ServicePrincipal'
    }
  }
]


