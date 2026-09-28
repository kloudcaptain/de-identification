resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
}
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  aks_subnet_id       = module.network.aks_subnet_id
}

module "data" {
  source = "./modules/data"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  pe_subnet_id        = module.network.pe_subnet_id
  vnet_id             = module.network.vnet_id
}