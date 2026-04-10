variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "weather-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Central India"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "weather-aks"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "weatheraks"
}

variable "node_pool_name" {
  description = "Name of the AKS node pool"
  type        = string
  default     = "nodepool1"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "service_cidr" {
  description = "CIDR range for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address of Kubernetes DNS service"
  type        = string
  default     = "10.1.0.10"
}

variable "authorized_ip_ranges" {
  description = "List of IP ranges authorized to access AKS API server"
  type        = list(string)
  default     = []  # Empty = accessible from anywhere; add IPs for security
}
