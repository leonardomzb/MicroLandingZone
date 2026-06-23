# Landing Zone Simple

Proyecto personal de practica. Despliegue de infraestructura en Azure mediante una Landing Zone simple utilizando IaC (Bicep).

## Componentes implementados

  - Application Gateway
  - Virtual Network
  - Virtual Network Peering
  - Private DNS Zone
  - App Service (Web App)
  - App Service Plan
  - Azure RBAC
  - Log Analytics Workspace
  - Application Insights
  - SQL Server
  - Private Endpoint
  - Diagnostic Settings

## Características
  
  - Arquitectura Hub & Spoke
  - 100% Bicep con el uso de Azure Verified Modules
  - Web App y Servidor SQL sin acceso público
  - Unico Acceso publico a traves de Application Gateway
  - WAF para protección de Web App.
  - Uso de Managed Identity
  - Secretos en Key Vault
  - Conectividad privada mediante Private Link
  - GitHub Actions Workflows
