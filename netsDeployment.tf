terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0" # Usa la versión compatible que prefieras
    }
  }
}

provider "azurerm" {
  subscription_id = "ce449b18-5f10-4724-9ab7-4b2aaae0b4dd"
  features {}
}

data "azurerm_resource_group" "IaC-Developers" {
  name = "IaC-Developers"
}


resource "azurerm_virtual_network" "main-vnet" {
  name                = "main-vnet"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  address_space       = ["10.0.0.0/15"]
}

resource "azurerm_subnet" "front-subnet" {
  name                 = "front-subnet"
  resource_group_name  = "IaC-Developers"
  virtual_network_name = azurerm_virtual_network.main-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "back-subnet" {
  name                 = "back-subnet"
  resource_group_name  = "IaC-Developers"
  virtual_network_name = azurerm_virtual_network.main-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "storage-subnet" {
  name                 = "storage-subnet"
  resource_group_name  = "IaC-Developers"
  virtual_network_name = azurerm_virtual_network.main-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}
