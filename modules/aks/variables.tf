variable "resource_group_name" {
  description = "Resource group the AKS cluster deploys into"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}