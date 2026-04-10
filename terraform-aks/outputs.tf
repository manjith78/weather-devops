output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  description = "Kubernetes configuration file (sensitive)"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_config_context" {
  description = "Kubernetes context name"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.name
}

output "client_certificate" {
  description = "Client certificate for kubectl (sensitive)"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for kubectl (sensitive)"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (sensitive)"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "AKS API server URL"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.weather_rg.name
}

output "aks_managed_identity_id" {
  description = "Principal ID of the managed identity for AKS"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
