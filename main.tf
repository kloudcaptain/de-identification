resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.lab.name
  location             = azurerm_resource_group.lab.location
}