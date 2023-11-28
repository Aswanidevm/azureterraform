terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "blob_storage" {
  name     = "blob_storage-resources"
  location = "East Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "Vnet" {
  name                = "blob_storage-network"
  resource_group_name = azurerm_resource_group.blob_storage.name
  location            = azurerm_resource_group.blob_storage.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "SubNet1" {
  name                 = "blob_storage-sub_network"
  resource_group_name  = azurerm_resource_group.blob_storage.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.1.0/24"]

#  delegation {
#    name = "delegation"
#
#    service_delegation {
#      name    = "Microsoft.ContainerInstance/containerGroups"
#      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#    }
#  }
}

resource "azurerm_network_security_group" "NsecurityG" {
  name                = "blob_storageSecurityGroup1"
  location            = azurerm_resource_group.blob_storage.location
  resource_group_name = azurerm_resource_group.blob_storage.name

  security_rule {
    name                       = "Allowall"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet_network_security_group_association" "NsecurityG" {
  subnet_id                 = azurerm_subnet.SubNet1.id
  network_security_group_id = azurerm_network_security_group.NsecurityG.id
}