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