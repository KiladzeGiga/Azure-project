resource "random_string" "sql_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "sql_admin_password" {
  length      = 24
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

resource "azurerm_mssql_server" "main" {
  name                         = "sql-azproj-${random_string.sql_suffix.result}"
  resource_group_name          = azurerm_resource_group.prod.name
  location                     = azurerm_resource_group.prod.location
  version                      = "12.0"
  administrator_login          = "azprojadmin"
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"

  tags = {
    project = "azure-project"
    env     = "prod"
  }
}

resource "azurerm_mssql_database" "marketplace" {
  name      = "sqldb-azproj-marketplace"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "Basic"

  short_term_retention_policy {
    retention_days = 7
  }

  tags = {
    project = "azure-project"
    env     = "prod"
  }
}

resource "azurerm_mssql_database" "marketplace_restore_drill" {
  count = var.enable_restore_drill ? 1 : 0

  name                        = "sqldb-azproj-marketplace-restore-drill"
  server_id                   = azurerm_mssql_server.main.id
  sku_name                    = "Basic"
  create_mode                 = "PointInTimeRestore"
  creation_source_database_id = azurerm_mssql_database.marketplace.id
  restore_point_in_time       = var.restore_point_in_time

  tags = {
    project = "azure-project"
    env     = "prod"
    purpose = "restore-drill"
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_key_vault_secret" "marketplace_db_connection" {
  name         = "marketplace-db-connection"
  key_vault_id = azurerm_key_vault.main.id

  value = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.marketplace.name};Persist Security Info=False;User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  depends_on = [
    azurerm_role_assignment.kv_apply_secret_officer
  ]
}