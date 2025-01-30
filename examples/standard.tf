locals {
  azure_tags = {
    wid                     = 000001
    SSC_CBRID               = 0001
    ConfigurationSource     = "https://github.com/gccloudone-aurora/infrastructure/dev"
    Environment             = "dev"
    PrimaryTechnicalContact = "william.hearn@ssc-spc.gc.ca"
    PrimaryProjectContact   = "albertabdullah.kouri@ssc-spc.gc.ca"
  }

  cluster_ssh_key = "ssh-rsa ArandomstuffhereEAw== ex-dev-cc-00"
}

#####################
### Prerequisites ###
#####################

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-vnet-rg"
  location = "Canada Central"
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.canadacentral.azmk8s.io"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "keyvault" {
  name                 = "vault"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "system" {
  name                 = "system"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "general" {
  name                 = "general"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "loadbalancer" {
  name                 = "loadbalancer"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "apiserver" {
  name                 = "apiserver"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.6.0/24"]
}

##########################################
### Infrastructure Module #######
##########################################

# Deploys Azure Kubernetes Service and its related infrastructure.
#
# https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-infrastructure
#
module "infrastructure" {
  source = "../"

  azure_resource_attributes = {
    project     = "aur"
    environment = "dev"
    location    = "Canada Central"
    instance    = 0
  }

  kubernetes_version = "1.23.12"
  cluster_vnet_id    = azurerm_virtual_network.example.id

  node_pools = {
    system = {
      vm_size            = "Standard_D2s_v3"
      node_count         = 1
      availability_zones = []
      vnet_subnet_id     = azurerm_subnet.system.id
    },
    general = {
      vm_size        = "Standard_D2s_v3"
      node_count     = 3
      vnet_subnet_id = azurerm_subnet.general.id
    },
    gateway = {
      vm_size        = "Standard_D2s_v3"
      node_count     = 1
      vnet_subnet_id = azurerm_subnet.gateway.id
    }
  }
  cluster_linux_profile_ssh_key = local.cluster_ssh_key

  networking_ids = {
    dns_zones = {
      azmk8s   = azurerm_private_dns_zone.aks.id
      keyvault = azurerm_private_dns_zone.keyvault.id
    }
    subnets = {
      api_server     = azurerm_subnet.apiserver.id
      infrastructure = azurerm_subnet.keyvault.id
    }
  }

  tags = local.azure_tags
}
