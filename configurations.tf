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

# The Terraform provider does not yet support the deployment script resource type.
# Here I am embedding an ARM Template
# Deployment script is used to create the domaindata table in the Azure SQL DB
resource "azurerm_template_deployment" "domaindata" {
  name                = "domaindata"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "identity": {
           "type": "securestring"
        },
        "sqlServer": {
           "type": "string"
        },
        "sqlAdmin": {
            "type": "string"
        },
        "sqlPassword": {
            "type": "securestring"
        }
    },
    "variables": {
        "script": "https://gist.githubusercontent.com/neilpeterson/d6e4d7104ed8a016470aaed01c558652/raw/ca8c010ee0c28a2fa7c9d4f27cf5a5fb4992bb5c/gistfile1.ps1"
    },
    "resources": [
        {
            "type": "Microsoft.Resources/deploymentScripts",
            "apiVersion": "2019-10-01-preview",
            "name": "runPowerShellInline",
            "location": "[resourceGroup().location]",
            "kind": "AzurePowerShell",
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {"[parameters('identity')]": {}}
            },
            "properties": {
                "forceUpdateTag": "1",
                "azPowerShellVersion": "3.0",
                "arguments": "[concat('-sqlServer ', parameters('sqlServer'), ' -sqlAdmin ', parameters('sqlAdmin'), ' -sqlPassword ', parameters('sqlPassword'))]",
                "primaryScriptUri": "[variables('script')]",
                "timeout": "PT30M",
                "cleanupPreference": "OnSuccess",
                "retentionInterval": "P1D"
            }
        }
    ]
}
DEPLOY

parameters = {
  "identity" = azurerm_user_assigned_identity.identity.id,
  "sqlServer" = azurerm_sql_server.sql.fully_qualified_domain_name,
  "sqlAdmin" = var.sqlServerAdminName,
  "sqlPassword" = var.sqlServerAdminPassword
}

  deployment_mode = "Incremental"
}