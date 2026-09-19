variable "subscription_id" {
  description = "Azure subscription ID to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group holding all lab resources"
  type        = string
  default     = "rg-deid-lab"
}