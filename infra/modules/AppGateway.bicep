
//AppGateway.bicep
metadata description = 'Modulo de creacion de Application Gateway'

@description('Nombre de App Gateway')
param agwName string
@description('Región de Azure donde se desplegarán los recursos')
param location string
@description('Entorno de despliegue')
param environment string
@description('Nombre de la Web App que se expondrá a través del Application Gateway')
param webAppName string
@description('Resource ID de la subnet donde se desplegará el Application Gateway')
param appGatewaySubnet string

// IP PUBLICA PARA APP GATEWAY
module pipAppGateway 'br/public:avm/res/network/public-ip-address:0.12.0' = {
  name: 'pip-AppGateway-deployment'
  params: {
    location: location
    name: 'pip-${agwName}'
  }
}

// WAF POLICY
module wafPolicy 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.3.0' = {
  name: 'waf-pol-${agwName}-deployment'
  params: {
    name: 'waf-pol-${agwName}'
    location: location
    managedRules: {
      managedRuleSets: [
        {
          ruleGroupOverrides: []
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
        }
      ]
    }
    policySettings: {
      fileUploadLimitInMb: environment == 'prod' ? 100 : 10
      mode: environment == 'prod' ? 'Prevention' : 'Detection'
      state: 'Enabled'
    }
    tags: {
      Environment: environment
    }
  }
}

// APP GATEWAY SOLO HTTP POR SER LABORATORIO
module appGateway 'br/public:avm/res/network/application-gateway:0.9.0' = {
  name: '${agwName}-deployment'
  params: {
    name: agwName
    location: location
    sku: 'WAF_v2'
    enableHttp2: true
    firewallPolicyResourceId: wafPolicy.outputs.resourceId
    gatewayIPConfigurations: [
      {
        name: 'agw-ip-configuration'
        properties: {
          subnet: {
            id: appGatewaySubnet
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'public'
        properties: {
          publicIPAddress: {
            id: pipAppGateway.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port80'
        properties: {
          port: 80 // POR SER LABORATORIO
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener80'
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/frontendIPConfigurations/public'
          }
          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/frontendPorts/port80'
          }
          protocol: 'Http'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'webAppBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${webAppName}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'webAppProbe'
        properties: {
          protocol: 'Https'
          path: '/'
          pickHostNameFromBackendHttpSettings: true
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'webAppBackendHttpsSetting'
        properties: {
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          port: 443
          protocol: 'Https'
          requestTimeout: 30
          probe: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/probes/webAppProbe'
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'RoutingRule80'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/httpListeners/httpListener80'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/backendAddressPools/webAppBackendPool'
          }
          backendHttpSettings: {
            id: '${resourceId('Microsoft.Network/applicationGateways', agwName)}/backendHttpSettingsCollection/webAppBackendHttpsSetting'
          }
        }
      }
    ]
    tags: {
      Environment: environment
    }
  }
}
