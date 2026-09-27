# Grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-shoes-dev"
  location = "eastus" # Servidores en EE.UU, para limitaciones de regiones
}

# Cluster de Kubernetes (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-shoes-cluster"
  location            = azurerm_resource_group.rg.location
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksshoes"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v7" # Tamaño de maquina virtual basico
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
    Project     = "App Shoes"
    ManagedBy   = "Terraform"
  }
}

# Registro de contenedores privado
resource "azurerm_container_registry" "acr" {
  name                = "acrshoesedu2026" 
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false # Buenas prácticas: acceso solo mediante identidades, sin contraseñas de admin
}

# Permiso para que AKS pueda descargar imagenes del ACR sin credenciales estáticas
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
