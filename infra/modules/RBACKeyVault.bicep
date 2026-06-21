
// modRBACKeyVault.bicep
metadata description = 'Modulo para la asginacion de permisos RBAC'


@description('Nombre de key vault')
param keyVaultName string

type roleAssignmentConfig = {
  principalId: string
  roleDefinitionId: string
  principalType: string
}
@description('Lista de asignaciones RBAC')
param roleAssignments array


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource roleAssignmentsResource 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
    scope: keyVault
    properties: {
      principalId: assignment.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalType: assignment.principalType
    }
  }
]


