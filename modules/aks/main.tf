resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-deid-lab"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "deidlab"

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_D2s_v6"
    node_count     = 1
    vnet_subnet_id = var.aks_subnet_id
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    service_cidr        = "10.240.0.0/16"
    dns_service_ip      = "10.240.0.10"
  }
}

