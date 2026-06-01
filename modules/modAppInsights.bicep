
// modAppInsights.bicep
metadata description = 'Modulo de creacion de App Insights'

param location string
param appiName string
param workspaceResourceId string

module component 'br/public:avm/res/insights/component:0.7.2' = {
  name: '${appiName}-deployment'
  params: {
    name: appiName
    location: location
    workspaceResourceId: workspaceResourceId
    applicationType: 'web'
  }
}

output appiId string = component.outputs.resourceId
