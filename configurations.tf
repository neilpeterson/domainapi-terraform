resource "azurerm_key_vault_secret" "sqlServerEndpoint" {
  name         = "SERVERNAME"
  value        = azurerm_sql_server.sql.fully_qualified_domain_name
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "sqlServerAdminName" {
  name         = "USERNAME"
  value        = var.sqlServerAdminName
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "sqlServerAdminPassword" {
  name         = "PASSWORD"
  value        = var.sqlServerAdminPassword
  key_vault_id = azurerm_key_vault.keyvault.id
}

# No Terraform support for deploymnet script, using ARM template
# Deployment script is used to create the domaindata table in the Azure SQL DB and boot strap AKS pod identity
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
        },
        "aksCluster": {
            "type": "string"
        },
        "aksResourceGroup": {
            "type": "string"
        }
    },
    "variables": {
        "script": "https://gist.githubusercontent.com/neilpeterson/d6e4d7104ed8a016470aaed01c558652/raw/1e8ca5e5c652f14ad63e3e2001cef33be60b24dd/gistfile1.ps1"
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
                "arguments": "[concat('-sqlServer ', parameters('sqlServer'), ' -sqlAdmin ', parameters('sqlAdmin'), ' -sqlPassword ', parameters('sqlPassword'), ' -aksCluster ', parameters('aksCluster'), ' -aksResourceGroup ', parameters('aksResourceGroup'))]",
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
    "identity"         = azurerm_user_assigned_identity.script-identity.id,
    "sqlServer"        = azurerm_sql_server.sql.fully_qualified_domain_name,
    "sqlAdmin"         = var.sqlServerAdminName,
    "sqlPassword"      = var.sqlServerAdminPassword,
    "aksResourceGroup" = azurerm_resource_group.resourceGroup.name,
    "aksCluster"       = azurerm_kubernetes_cluster.aks.name
  }

  deployment_mode = "Incremental"
}
