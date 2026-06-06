
// modRBACKeyVault.bicep
metadata description = 'Modulo para la asginacion de permisos RBAC'

@description('Nombre del Resource Group donde se creó el Key Vault') 
param keyVaultResourceGroupName string
@description('Nombre de key vault')
param keyVaultName string

type roleAssignmentConfig = {
  principalId: string
  roleDefinitionId: string
  principalType: string
}
@description('Lista de asignaciones RBAC')
param roleAssignments array

resource kvResourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: keyVaultResourceGroupName
  scope: subscription()
}


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
  scope:kvResourceGroup
}

resource roleAssignmentsResource 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
    properties: {
      principalId: assignment.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalType: assignment.principalType
    }
  }
]


