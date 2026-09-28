
output "pe_subnet_id" {
  value = azurerm_subnet.pe.id
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}