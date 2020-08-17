terraform {
  backend "azurerm" {
    resource_group_name  = RESOURCE_GROUP_NAME
    storage_account_name = STORAGE_ACCOUNT_NAME
    container_name       = CONTAINER_NAME
    key                  = KEY # e.g. "prod.terraform.tfstate"
  }
}

# Resource group to hold Azure resources
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.aks_name}-rg-${var.env}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name               = "${var.aks_name}-cluster"
  location           = var.location
  dns_prefix         = var.env
  kubernetes_version = var.aks_kubernetes_version
  resource_group_name = azurerm_resource_group.aks_rg.name

  linux_profile {
    admin_username = var.vm_user_name

    ssh_key {
      key_data = tls_private_key.ssh_key.public_key_openssh
    }
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

  default_node_pool {
    name                = substr(var.default_node_pool.name, 0, 12)
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    type                = "VirtualMachineScaleSets"
    max_pods            = 110
    os_disk_size_gb     = 128
    vnet_subnet_id      = azurerm_subnet.k8subnet.id
    enable_auto_scaling = var.default_node_pool.cluster_auto_scaling
    min_count           = var.default_node_pool.cluster_auto_scaling_min_count
    max_count           = var.default_node_pool.cluster_auto_scaling_max_count
  }

  service_principal {
    client_id     = azuread_service_principal.spn.application_id
    client_secret = azuread_service_principal_password.spn.value
  }

  network_profile {
    load_balancer_sku  = "standard"
    network_plugin     = "azure"
    network_policy     = "calico"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.0.0/16"
  }

  tags = {
    Environment = var.env
  }
}


