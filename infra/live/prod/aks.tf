resource "random_string" "aks_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-azproj-${random_string.aks_suffix.result}"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  dns_prefix          = "azproj-${random_string.aks_suffix.result}"

  oidc_issuer_enabled = true

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    project = "azure-project"
    env     = "prod"
  }
}