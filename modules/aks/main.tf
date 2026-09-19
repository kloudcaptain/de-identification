resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-deid-lab"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "deidlab"

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D2s_v6"
    node_count = 1
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type = "SystemAssigned"
  }
}
