variable "resource_group_name" {
  description = "Resource group the data resources deploy into"
  type        = string
}

variable "location" {
  description = "Azure region for the data resources"
  type        = string
}

variable "pe_subnet_id" {
  description = "ID of the private endpoint subnet"
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network, used to link private DNS zones"
  type        = string
}
variable "sql_location" {
  description = "Region for the SQL server, separate from the main location because SQL provisioning is restricted in eastus2 on this subscription"
  type        = string
  default     = "eastus"
}