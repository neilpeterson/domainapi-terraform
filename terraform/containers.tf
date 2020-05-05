resource "azurerm_container_registry" "acr" {
  name                     = "${var.continerRegistryName}${var.identifier}"
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  location                 = azurerm_resource_group.resourceGroup.location
  sku                      = "Premium"
  admin_enabled            = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.aksName}${var.identifier}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = var.aksClisntId
    client_secret = var.aksClientSecret
  }

  # identity {
  #   type = "SystemAssigned"
  # }
}

# resource "azurerm_role_assignment" "acrpull" {
#   scope                            = azurerm_resource_group.resourceGroup.id
#   role_definition_name             = "Contributor"
#   principal_id                     = azurerm_kubernetes_cluster.aks.identity[0].principal_id
#   skip_service_principal_aad_check = true
# }

# Install Managed Identity Controller and Node Managed Identity
# kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment.yaml