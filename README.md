# Landing Zone Simple

Proyecto personal de practica. Despliegue de infraestructura en Azure mediante una Landing Zone simple utilizando IaC (Bicep).

## Componentes implementados
  - Virtual Network
  - App Service
  - App Service Plan
  - Key Vault (Se despliega en un RG independiente para simular un recurso corporativo preexistente.)
  - Azure RBAC
  - Log Analytics Workspace
  - Application Insights
  - SQL Server
  - Private Endpoint
  - Diagnostic Settings

## Características

  - 100% Bicep con el uso de Azure Verified Modules
  - Key Vault y servidor SQL sin acceso público
  - Uso de Managed Identity
  - Secretos en Key Vault
  - Conectividad privada mediante Private Link

## Deployment

  -El despliegue es a nivel de subscripcion.
  -El despliegue crea los Resource Groups necesarios, seguido por el recurso Key Vault en un RG independiente para simular preexistencia de secretos administrados por el equipo de seguridad, y posteriormente invoca la Landing Zone principal (main.bicep) a nivel de Resource Group.

  ## Deploy

    $paramFile=".\environments\dev.bicepparam"
    $today = Get-Date -Format "dd-MM-yyyy"
    $deploymentName="sub-scope-$today"

    az deployment sub create --name $deploymentName --location centralus --parameters $paramFile --verbose