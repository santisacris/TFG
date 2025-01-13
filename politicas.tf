terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117" # Usa la versión compatible que prefieras
    }
  }
}

provider "azurerm" {
  features {}
}

# POLITICA 1
resource "azurerm_policy_definition" "LocalizacionRecursos" {
  name         = "LocalizacionRecursos"
  display_name = "Pol_LocalizacionRecursos"
  policy_type  = "Custom"
  mode         = "All"
  description  = "No está permitido desplegar recursos fuera de West Europe"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "anyOf": [
            {
              "field": "type",
              "equals": "Microsoft.Compute/virtualMachines"
            },
            {
              "field": "type",
              "equals": "Microsoft.Sql/servers/databases"
            },
            {
              "field": "type",
              "equals": "Microsoft.ContainerService/managedClusters"
            },
            {
              "field": "type",
              "equals": "Microsoft.Compute/servers"
            }
          ]
        },
        {
          "not": {
            "field": "location",
            "in": [
              "West Europe"
            ]
          }
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers1" {
  name                 = "IaC-Developers1"
  display_name         = "Asig_Pol_LocalizacionRecursos"
  policy_definition_id = azurerm_policy_definition.LocalizacionRecursos.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 2
resource "azurerm_policy_definition" "TagsRecursos" {
  name         = "TagsRecursos"
  display_name = "Pol_TagsRecursos"
  policy_type  = "Custom"
  mode         = "All"
  description  = "No está permitido desplegar ningún recurso sin especificar las etiquetas <Owner>, <CostCenter>, <Proyect> y <Environment>"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "anyOf": [
            {
              "field": "type",
              "equals": "Microsoft.Compute/virtualMachines"
            },
            {
              "field": "type",
              "equals": "Microsoft.Sql/servers/databases"
            },
            {
              "field": "type",
              "equals": "Microsoft.ContainerService/managedClusters"
            },
            {
              "field": "type",
              "equals": "Microsoft.Compute/servers"
            }
          ]
        },
        {
          "anyOf": [
            {
              "exists": "false",
              "field": "tags.Owner"
            },
            {
              "exists": "false",
              "field": "tags.CostCenter"
            },
            {
              "exists": "false",
              "field": "tags.Proyect"
            },
            {
              "exists": "false",
              "field": "tags.Application"
            },
            {
              "exists": "false",
              "field": "tags.Environment"
            }
          ]
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers2" {
  name                 = "IaC-Developers2"
  display_name         = "Asig_Pol_TagsRecursos"
  policy_definition_id = azurerm_policy_definition.TagsRecursos.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 3
resource "azurerm_policy_definition" "TipoVM" {
  name         = "TipoVM"
  display_name = "Pol_TipoVM"
  policy_type  = "Custom"
  mode         = "All"
  description  = "No está permitido desplegar máquinas virtuales que no sean Linux"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "not": {
            "field": "Microsoft.Compute/imagePublisher",
            "equals": "Canonical"
          }
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers3" {
  name                 = "IaC-Developers3"
  display_name         = "Asig_Pol_TipoVM"
  policy_definition_id = azurerm_policy_definition.TipoVM.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 4
resource "azurerm_policy_definition" "VMSku" {
  name         = "VMSku"
  display_name = "Pol_VMSku"
  policy_type  = "Custom"
  mode         = "All"
  description  = "No está permitido desplegar maquinas virtuales que no sean de los tipos indicados"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "not": {
            "field": "Microsoft.Compute/virtualMachines/sku.name",
            "in": [
              "Standard_DS1_v2",
              "Standard_B1s",
              "Standard_B2s"
            ]
          }
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers4" {
  name                 = "IaC-Developers4"
  display_name         = "Asig_Pol_VMSku"
  policy_definition_id = azurerm_policy_definition.VMSku.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 5
resource "azurerm_policy_definition" "NumNodePools" {
  name         = "NumNodePools"
  display_name = "Pol_NumNodePools"
  policy_type  = "Custom"
  mode         = "All"
  description  = "No está permitido desplegar clusteres con mas de 1 node pool"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.ContainerService/managedClusters"
        },
        {
          "count": {
          "field": "Microsoft.ContainerService/managedClusters/agentPoolProfiles[*]"
        },
        "greater": 1
      }
    ]
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers5" {
  name                 = "IaC-Developers5"
  display_name         = "Asig_Pol_NumNodePools"
  policy_definition_id = azurerm_policy_definition.NumNodePools.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 7
resource "azurerm_policy_definition" "NombradoVM" {
  name         = "NombradoVM"
  display_name = "Pol_NombradoVM"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Se obliga a que el nombre de las maquinas virtuales empiece por <b-vm-> o <f-vm->"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "not": {
            "anyOf": [
              {
              "field": "name",
              "like": "b-vm-*"
              },
              {
              "field": "name",
              "like": "f-vm-*"
              }
            ]
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers7" {
  name                 = "IaC-Developers7"
  display_name         = "Asig_Pol_NombradoVM"
  policy_definition_id = azurerm_policy_definition.NombradoVM.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 8
resource "azurerm_policy_definition" "NombradoBBDD" {
  name         = "NombradoBBDD"
  display_name = "Pol_NombradoBBDD"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Se obliga a que el nombre de las bases de datos empiece por <s-db->"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Sql/servers/databases"
        },
        {
          "not": {
            "field": "name",
            "like": "s-db-*"
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers8" {
  name                 = "IaC-Developers8"
  display_name         = "Asig_Pol_NombradoBBDD"
  policy_definition_id = azurerm_policy_definition.NombradoBBDD.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 9
resource "azurerm_policy_definition" "NombradoNP" {
  name         = "NombradoNP"
  display_name = "Pol_NombradoNP"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Se obliga a que el nombre de las node pools empiece por <backnodepool->."

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.ContainerService/managedClusters/agentPools"
        },
        {
          "not": {
            "field": "name",
            "like": "bnp*"
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}

# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers9" {
  name                 = "IaC-Developers9"
  display_name         = "Asig_Pol_NombradoNP"
  policy_definition_id = azurerm_policy_definition.NombradoNP.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 10
resource "azurerm_policy_definition" "NombradoAKS" {
  name         = "NombradoAKS"
  display_name = "Pol_NombradoAKS"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Se obliga a que el nombre de los clusteres empiece por <b-aks->"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.ContainerService/managedClusters"
        },
        {
          "not": {
            "field": "name",
            "like": "b-aks-*"
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers10" {
  name                 = "IaC-Developers10"
  display_name         = "Asig_Pol_NombradoAKS"
  policy_definition_id = azurerm_policy_definition.NombradoAKS.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 11
resource "azurerm_policy_definition" "NombradoServer" {
  name         = "NombradoServer"
  display_name = "Pol_NombradoServer"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Se obliga a que el nombre de los servidores empiece por <f-sv->"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/servers"
        },
        {
          "not": {
            "field": "name",
            "like": "f-sv-*"
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers11" {
  name                 = "IaC-Developers11"
  display_name         = "Asig_Pol_NombradoServer"
  policy_definition_id = azurerm_policy_definition.NombradoServer.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA 12
resource "azurerm_policy_definition" "FrontSubnet" {
  name         = "FrontSubnet"
  display_name = "Pol_FrontSubnet"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Es obligatorio que los recursos de la capa front se desplieguen en la subnet 10.0.0.0/24"

  parameters = jsonencode({
    allowedSubnet = {
      type = "String"
      defaultValue = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers/providers/Microsoft.Network/virtualNetworks/vnetFront/subnets/front-subnet"
      metadata = {
        description = "Subnet indicada para los recursos de la capa front"
        displayName = "Subnet Permitida para la capa Front"
      }
    }
  })

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "equals": "Microsoft.Web/sites",
          "field": "type"
        },
        {
          "not": {
            "field": "Microsoft.Web/sites/virtualNetworkSubnetId",
            "equals": "[parameters('allowedSubnet')]"
          }
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}
# Asignar la política al grupo de recursos IaC
resource "azurerm_resource_group_policy_assignment" "IaC-Developers12" {
  name                 = "IaC-Developers12"
  display_name         = "Asig_Pol_FrontSubnet"
  policy_definition_id = azurerm_policy_definition.FrontSubnet.id
  resource_group_id = "/subscriptions/ce449b18-5f10-4724-9ab7-4b2aaae0b4dd/resourceGroups/IaC-Developers"
}

# POLITICA  DE COMUNICACIÓN MEDIANTE AZURE NETWORK SECURITY GROUPS
resource "azurerm_network_security_group" "front_nsg" {
  name                = "front-nsg"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "10.0.0.4" # IP del servidor de la capa Front
  }
}

resource "azurerm_network_security_group" "back_nsg" {
  name                = "back-nsg"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  security_rule {
    name                       = "deny-public-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "10.0.1.0/24"
  }

  # Permitir comunicación desde el servidor al Load Balancer
  security_rule {
    name                       = "allow-server-to-lb"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.4"   # Dirección del servidor web en la capa front
    destination_address_prefix = "10.0.1.8"   # Dirección del Load Balancer en la capa back
    destination_port_range     = "80" # Puerto HTTP (web)
    source_port_range          = "*"
  }

  # Permitir tráfico del Load Balancer hacia las máquinas virtuales en el Backend Pool
  security_rule {
    name                       = "allow-lb-to-vm1"
    priority                   = 250
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.8"
    destination_address_prefix = "10.0.1.5"
    destination_port_range     = "*"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "allow-lb-to-vm2"
    priority                   = 255
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.8"
    destination_address_prefix = "10.0.1.4"
    destination_port_range     = "*"
    source_port_range          = "*"
  }

  # Denegar comunicación desde el servidor hacia las máquinas virtuales
  security_rule {
    name                       = "deny-server-to-vm1-tcp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.4"   # Dirección del servidor web
    destination_address_prefix = "10.0.1.5" # IP de la máquina virtual 1 del nodepool
    destination_port_range     = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "deny-server-to-vm2-tcp"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.4"   # Dirección del servidor web
    destination_address_prefix = "10.0.1.4" # IP de la máquina virtual 2 del nodepool
    destination_port_range     = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "deny-server-to-vm1-icmp"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Icmp"
    source_address_prefix      = "10.0.0.4"
    destination_address_prefix = "10.0.1.5"
    destination_port_range     = "*"
    source_port_range          = "*"
  }
  security_rule {
    name                       = "deny-server-to-vm2-icmp"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Icmp"
    source_address_prefix      = "10.0.0.4"
    destination_address_prefix = "10.0.1.4"
    destination_port_range     = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_network_security_group" "storage_nsg" {
  name                = "storage-nsg"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"

  security_rule {
    name                       = "deny-public-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "10.1.1.0/24"
  }

  security_rule {
    name                       = "deny-front-to-storage"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.4"   # Servidor web
    destination_address_prefix = "10.1.1.4"   # Base de datos SQL
    destination_port_range     = "*"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "allow-back-to-storage"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.0/24" # Capa back (AKS y Nodepool)
    destination_address_prefix = "10.1.1.4"   # Base de datos SQL
    destination_port_range     = "1433"
    source_port_range          = "*"
  }
}
