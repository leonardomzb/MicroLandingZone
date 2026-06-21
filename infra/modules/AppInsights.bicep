
// modAppInsights.bicep
metadata description = 'Modulo de creacion de App Insights'

@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Nombre del componente de App Insights')
param appiName string
@description('ID del recurso del área de trabajo de App Insights')
param workspaceResourceId string
@description('Entorno de despliegue')
param environment string

module component 'br/public:avm/res/insights/component:0.7.2' = {
  name: '${appiName}-deployment'
  params: {
    name: appiName
    location: location
    workspaceResourceId: workspaceResourceId
    applicationType: 'web'
    tags: {
      Environment: environment
    }
  }
}

@description('Resource ID del componente de App Insights')
output appiId string = component.outputs.resourceId
