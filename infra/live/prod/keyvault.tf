resource "random_string" "kv_suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "kv-azproj-${random_string.kv_suffix.result}"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  enable_rbac_authorization = true

  tags = {
    project = "azure-project"
    env     = "prod"
  }
}

resource "azurerm_key_vault_secret" "marketplace_connection" {
  name         = "marketplace-connection"
  value        = "demo-secret-value"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.kv_admin_current
  ]
}

resource "azurerm_role_assignment" "kv_admin_current" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_csi_secret_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
}