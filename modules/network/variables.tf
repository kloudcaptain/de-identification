variable "resource_group_name" {
  description = "Resource group the network resources deploy into"
  type        = string
}

variable "location" {
  description = "Azure region for the network"
  type        = string
}

variable "vnet_cidr" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "Address prefix for the AKS cluster subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pe_subnet_cidr" {
  description = "Address prefix for the private endpoint subnet"
  type        = string
  default     = "10.0.2.0/24"
}
