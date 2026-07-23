output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_rg" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "ingress_public_ip" {
  description = "Static public IP address for ingress-nginx"
  value       = azurerm_public_ip.ingress.ip_address
}

output "ingress_public_ip_id" {
  description = "Azure resource ID of the ingress public IP"
  value       = azurerm_public_ip.ingress.id
}

output "api_fqdn" {
  description = "Public API DNS name"
  value       = azurerm_dns_a_record.api.fqdn
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "key_vault_name" {
  description = "Azure Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "Azure Key Vault resource ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Azure Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_csi_client_id" {
  description = "Client ID of the AKS Key Vault CSI add-on managed identity"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
}