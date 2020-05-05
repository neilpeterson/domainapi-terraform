provider "azurerm" {
  version = "=2.8.0"
  features {}
}

resource "azurerm_resource_group" "resourceGroup" {
  name                = "${var.resourceGroupName}-${var.identifier}"
  location            = var.location
}

# Identity used for deployment script resource
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  name                = "identity"
}

resource "azurerm_role_assignment" "identity" {
  scope                = azurerm_resource_group.resourceGroup.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

data "azurerm_client_config" "current" {}