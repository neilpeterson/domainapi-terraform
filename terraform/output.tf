output "_1_Run_this_command_to_login_to_the_Azure_Contianer_Registry" {
  value = "az acr login --name ${azurerm_container_registry.acr.name}"
}

output "_2_Run_this_command_to_build_and_stage_container_image" {
  value = "az acr build --registry ${azurerm_container_registry.acr.name} -f src/Services/DomainAPI/Dockerfile --image domainapi:v1 ."
}

output "_3_Run_this_command_to_login_connect_with_kubernetes_cluster" {
  value = "az aks get-credentials --name ${azurerm_kubernetes_cluster.aks.name} --resource-group ${azurerm_resource_group.resourceGroup.name}"
}

output "_4_Run_this_command_to_run_helm_chart" {
  value = "helm install ./domain-api --set SqlServer=${azurerm_sql_server.sql.fully_qualified_domain_name} --set SqlUser=${var.sqlServerAdminName} --set SqlPassword=${var.sqlServerAdminPassword} --set Image=${azurerm_container_registry.acr.login_server}/domainapi:v1 --generate-name"
}