# Resource Group for AKS
resource "azurerm_resource_group" "weather_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.weather_rg.location
  resource_group_name = azurerm_resource_group.weather_rg.name
  dns_prefix          = var.dns_prefix

  # Default Node Pool Configuration
  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = var.vm_size

    # Enable auto-scaling (optional)
    min_count = 1
    max_count = 5

    # Enable cluster autoscaler
    enable_auto_scaling = true
  }

  # Managed Identity for AKS
  identity {
    type = "SystemAssigned"
  }

  # Network Configuration
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Enable RBAC
  role_based_access_control_enabled = true

  # API Server Access
  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  tags = {
    Environment = "Production"
    Project     = "WeatherApp"
    ManagedBy   = "Terraform"
  }
}

# Kubernetes Provider Configuration (for future app deployments)
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}
