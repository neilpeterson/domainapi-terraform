# Managed Identity (Deployment Script)
resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  name                = "aks-pod-identity"
}

# Managed Identity Access (Resource Group for Deployment Script)
# Check / Modify Access for this one
resource "azurerm_role_assignment" "identity" {
  scope                = azurerm_resource_group.resourceGroup.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

# AKS (SystemAssigned Identity) > ACR Pull Access
resource "azurerm_role_assignment" "aks-acr-access" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# AKS (SystemAssigned Identity) Pod Identity
# https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.role-assignment.md
resource "azurerm_role_assignment" "aks-pod-identity-mio-access" {
  scope                = azurerm_resource_group.resourceGroup.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# AKS (SystemAssigned Identity) Pod Identity
# https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.role-assignment.md
resource "azurerm_role_assignment" "aks-pod-identity-vm-access" {
  scope                = azurerm_resource_group.resourceGroup.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# AKS (SystemAssigned Identity) > Key Vault for Pod Identity Access
resource "azurerm_key_vault_access_policy" "aks_pod_identity" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  secret_permissions = [
    "get", "list"
  ]
}