output "storage_account_name" {
  value = azurerm_storage_account.docs.name
}

output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}