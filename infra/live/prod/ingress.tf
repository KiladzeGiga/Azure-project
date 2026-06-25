resource "azurerm_public_ip" "ingress" {
  name                = "pip-azproj-ingress"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    project     = "azure-project"
    environment = "prod"
    managed_by  = "terraform"
  }
}