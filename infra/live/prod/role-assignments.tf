resource "azurerm_role_assignment" "aks_network_contributor_on_prod_rg" {
  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}