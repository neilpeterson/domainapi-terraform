# # NEW NEW NEW
# # https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-existing#set-up-aad-pod-identity
# # Pod Identity reader access to the resource group
# resource "azurerm_role_assignment" "pod-identity-assignment" {
#   scope                = < APP Gateway ID >
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.pod-identity.principal_id
# }


resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_aks" {
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "aks-subnet"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "subnet_app_gateway" {
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "agw-subnet"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "agw" {
  name                = "${var.appGatewayName}-${var.identifier}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }

  #   ssl_certificate {
  #     name     = var.certificate_name
  #     data     = filebase64(var.certificate_path)
  #     password = var.certificate_pwd
  #   }

  gateway_ip_configuration {
    name      = azurerm_subnet.subnet_app_gateway.name
    subnet_id = azurerm_subnet.subnet_app_gateway.id
  }

  frontend_port {
    name = "${azurerm_virtual_network.vnet.name}-feport"
    port = 80
  }

  frontend_port {
    name = "https_port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${azurerm_virtual_network.vnet.name}-feip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = "${azurerm_virtual_network.vnet.name}-beap"
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet.name}-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${azurerm_virtual_network.vnet.name}-httplstn"
    frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
    frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
    protocol                       = "http"
  }

  request_routing_rule {
    name                       = "${azurerm_virtual_network.vnet.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${azurerm_virtual_network.vnet.name}-httplstn"
    backend_address_pool_name  = "${azurerm_virtual_network.vnet.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-be-htst"
  }
}
