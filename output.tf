output "_1_auth_aks" {
  value = "az aks get-credentials --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${azurerm_resource_group.resourceGroup.name}"
}

output "_2_auth_container_registry" {
  value = "az acr login --name ${azurerm_container_registry.acr.name}"
}

output "_3_build_image_push_acr" {
  value = "az acr build --registry ${azurerm_container_registry.acr.name} -f src/Services/DomainAPI/Dockerfile --image domainapi:v1 ."
}

output "_4_run_app_helm" {
  value = "helm install ./domain-api --set SubscriptionId=${data.azurerm_client_config.current.subscription_id} --set ResourceGroupName=${azurerm_resource_group.resourceGroup.name} --set IdentityName=${azurerm_user_assigned_identity.pod-identity.name} --set IdentityClientId=${azurerm_user_assigned_identity.pod-identity.client_id} --set KeyVaultName=${azurerm_key_vault.keyvault.name} --set Image=${azurerm_container_registry.acr.login_server}/domainapi:v1 --generate-name"
}