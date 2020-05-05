resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.keyvaultName}${var.identifier}"
  location                    = azurerm_resource_group.resourceGroup.location
  resource_group_name         = azurerm_resource_group.resourceGroup.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # Do we need this access policy long term?
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete"
    ]
  }
}

# Create keyvault access for user assigned identity
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.keyvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.identity.client_id

  secret_permissions = [
    "get",
    "list"
  ]
}

resource "azurerm_key_vault_secret" "sqlServerEndpoint" {
  name         = "sqlServerEndpoint"
  value        = azurerm_sql_server.sql.fully_qualified_domain_name
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "sqlServerAdminName" {
  name         = "sqlServerAdminName"
  value        = var.sqlServerAdminName
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "sqlServerAdminPassword" {
  name         = "sqlServerAdminPassword"
  value        = var.sqlServerAdminPassword
  key_vault_id = azurerm_key_vault.keyvault.id
}