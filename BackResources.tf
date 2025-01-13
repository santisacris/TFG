resource "azurerm_kubernetes_cluster" "back-aks" {
  name                = "b-aks-clusterIaC1"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  dns_prefix          = "back-aks-cluster"

  default_node_pool {
    name       = "bnpiac"
    vm_size    = "Standard_B2s"
    node_count = 2 # Número de máquinas virtuales en la node pool
    vnet_subnet_id = azurerm_subnet.back-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.2.0.0/16" # Nuevo rango para el Service CIDR
    dns_service_ip = "10.2.0.10"   # Dirección IP dentro del nuevo Service CIDR
  }

  tags = {
    Owner       = "Santi"
    CostCenter  = "CC1"
    Proyect     = "WebAppDeployment"
    Application = "BackendDistribution"
    Environment = "Production"
  }
}

# Crear las Interfaces de Red para las dos máquinas virtuales
resource "azurerm_network_interface" "back-nic1" {
  name                = "back-nic1"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  ip_configuration {
    name                          = "back-ip-config"
    subnet_id                     = azurerm_subnet.back-subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address            = "10.0.1.5"
  }
}

resource "azurerm_network_interface" "back-nic2" {
  name                = "back-nic2"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  ip_configuration {
    name                          = "back-ip-config"
    subnet_id                     = azurerm_subnet.back-subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address            = "10.0.1.4"
  }
}

# Definir las máquinas virtuales después de crear las NICs
resource "azurerm_virtual_machine" "back1-vm" {
  name                  = "b-vm-1"
  location              = "westeurope"
  resource_group_name   = "IaC-Developers"
  network_interface_ids = [azurerm_network_interface.back-nic1.id]
  vm_size               = "Standard_B1s"

  os_profile {
    computer_name  = "back-vm1"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "back-os-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" 
  }

  tags = {
    Owner       = "Santi"
    CostCenter  = "CC12345"
    Proyect     = "WebAppDeployment"
    Application = "BackendDistribution"
    Environment = "Production"
  }
}

resource "azurerm_virtual_machine" "back2-vm" {
  name                  = "b-vm-2"
  location              = "westeurope"
  resource_group_name   = "IaC-Developers"
  network_interface_ids = [azurerm_network_interface.back-nic2.id]
  vm_size               = "Standard_B1s"

  os_profile {
    computer_name  = "back-vm2"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "back-os-disk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest" 
  }

  tags = {
    Owner       = "Santi"
    CostCenter  = "CC12345"
    Proyect     = "WebAppDeployment"
    Application = "BackendDistribution"
    Environment = "Production"
  }
}

# Definir el Load Balancer
resource "azurerm_lb" "back-lb" {
  name                = "back-lb"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "back-lb-frontend"
    subnet_id            = azurerm_subnet.back-subnet.id
    private_ip_address   = "10.0.1.8"
    private_ip_address_allocation = "Static"
  }
}

# Definir el Backend Pool del Load Balancer
resource "azurerm_lb_backend_address_pool" "back-lb-pool" {
  name                = "back-lb-pool"
  loadbalancer_id     = azurerm_lb.back-lb.id
}

# Asociar las NICs al Backend Pool después de que todo esté creado
resource "azurerm_network_interface_backend_address_pool_association" "back_vm1_association" {
  network_interface_id    = azurerm_network_interface.back-nic1.id
  ip_configuration_name   = "back-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.back-lb-pool.id
}

# Asociar las NICs al Backend Pool después de que todo esté creado
resource "azurerm_network_interface_backend_address_pool_association" "back_vm2_association" {
  network_interface_id    = azurerm_network_interface.back-nic2.id
  ip_configuration_name   = "back-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.back-lb-pool.id
}

# Crear un NSG para permitir acceso desde el Load Balancer al NodePool
resource "azurerm_network_security_group" "backLb-Np-nsg" {
  name                = "backLb-Np-nsg"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  security_rule {
    name                       = "allow-lb-to-backend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_lb.back-lb.frontend_ip_configuration[0].private_ip_address
    destination_address_prefix = "*"
    destination_port_range     = "*"
    source_port_range          = "*"
  }

  tags = {
    Environment = "Production"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.back-aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.back-aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.back-aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.back-aks.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name      = "nginx-app"
    namespace = "default"
    labels = {
      App = "nginx"
    }
  }

  spec {
    replicas = 2 # Se va a crear un Pod en cada nodo del cluster
    selector {
      match_labels = {
        App = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          App = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    external_traffic_policy = "Cluster" # Asegura que el balanceo sea a nivel de cluster
    type = "LoadBalancer"
  }
}