resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-azproj-prod"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    project = "azure-project"
    env     = "prod"
  }
}