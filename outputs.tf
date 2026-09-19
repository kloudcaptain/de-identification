output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "cluster_name" {
  value = module.aks.cluster_name
}