# Crear una dirección IP pública
resource "azurerm_public_ip" "front-public-ip" {
  name                = "front-public-ip"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  allocation_method   = "Static"
  sku                 = "Basic" # Puedes cambiarlo a "Standard" si es necesario

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_network_interface" "front-nic" {
  name                = "front-nic"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  ip_configuration {
    name                          = "front-ip-config"
    subnet_id                     = azurerm_subnet.front-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.front-public-ip.id
  }
}

# Crear un NSG para permitir acceso SSH desde tu IP pública
resource "azurerm_network_security_group" "frontPublic-nsg" {
  name                = "frontPublic-nsg"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  security_rule {
    name                       = "Allow-SSH-From-My-IP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "46.25.202.6/32" # Mi IP
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Production"
  }
}

# Asociar el NSG con la subred
resource "azurerm_subnet_network_security_group_association" "front-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.front-subnet.id
  network_security_group_id = azurerm_network_security_group.frontPublic-nsg.id
}

resource "azurerm_virtual_machine" "front-vm" {
  name                  = "f-vm-1"
  location              = "westeurope"
  resource_group_name   = "IaC-Developers"
  network_interface_ids = [azurerm_network_interface.front-nic.id]
  vm_size               = "Standard_B1s"

  os_profile {
    computer_name  = "front-vm"
    admin_username = "adminuser"
    admin_password = "AdminPassword123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "front-os-disk"
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
    Application = "FrontendServer"
    Environment = "Production"
  }
}