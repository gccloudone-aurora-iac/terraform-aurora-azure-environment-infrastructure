# Manages a Resource Group.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
#
resource "azurerm_resource_group" "aks" {
  name     = module.azure_resource_names.resource_group_name
  location = var.azure_resource_attributes.location
  tags     = local.tags

  lifecycle {
    ignore_changes = [tags.DateCreatedModified]
  }
}

##############################
### User Assigned Identity ###
##############################

# Manages a User Assigned Identity.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
#
resource "azurerm_user_assigned_identity" "aks" {
  name                = module.azure_resource_names.managed_identity_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = var.azure_resource_attributes.location
  tags                = local.tags

}

# Manages a User Assigned Identity.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
#
resource "azurerm_user_assigned_identity" "aks_kubelet" {
  name                = "${module.azure_resource_names.managed_identity_name}-kubelet"
  resource_group_name = azurerm_resource_group.aks.name
  location            = var.azure_resource_attributes.location
  tags                = local.tags
}

############
### RBAC ###
############

# Allow the cluster identity to create & delete an A record in the Private DNS Zone used.
resource "azurerm_role_assignment" "aks_msi_dns_zone" {
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = var.networking_ids.dns_zones.azmk8s
}

# Required for the BYO CNI as indicated by https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli
resource "azurerm_role_assignment" "aks_msi_vnet" {
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = var.cluster_vnet_id
}

# Grant the AKS MSI the ability to read and assign User Assigned Managed Identity for the kubelet MSI.
resource "azurerm_role_assignment" "aks_msi_kubelet_operator" {
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = azurerm_user_assigned_identity.aks_kubelet.id
}

#################################
### Kubernetes Cluster Module ###
#################################

# Manages a Managed Kubernetes Cluster.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
#
module "cluster" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster.git?ref=v2.0.2"

  azure_resource_attributes = var.azure_resource_attributes
  naming_convention         = var.naming_convention
  user_defined              = var.user_defined

  resource_group_name = azurerm_resource_group.aks.name
  sku_tier            = var.cluster_sku_tier
  support_plan        = var.cluster_support_plan

  kubernetes_version         = var.kubernetes_version
  node_os_channel_upgrade    = var.node_os_upgrade.channel
  maintenance_window_node_os = var.node_os_upgrade.maintenance_window

  # Identity / RBAC
  user_assigned_identity_ids = [azurerm_user_assigned_identity.aks.id]
  kubelet_identity = {
    client_id                 = azurerm_user_assigned_identity.aks_kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.aks_kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet.id
  }
  admin_group_object_ids       = var.cluster_admins
  linux_profile_public_ssh_key = var.cluster_linux_profile_ssh_key

  # Custom CA
  custom_ca = var.custom_ca

  # Networking
  private_cluster_enabled = true
  private_dns_zone_id     = var.networking_ids.dns_zones.azmk8s
  dns_prefix              = module.azure_resource_names.kubernetes_service_name
  api_server = {
    subnet_id                = var.networking_ids.subnets.api_server
    vnet_integration_enabled = true
  }

  network_plugin = "none"
  network_policy = null
  network_mode   = null

  service_cidr   = var.cluster_service_cidr
  dns_service_ip = var.cluster_dns_service_ip

  # Custom-Manager Encryption
  disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption.id

  # System Node Pool
  default_node_pool = local.system_node_pool
  auto_scaler_profile = {
    balance_similar_node_groups = true
    skip_nodes_with_system_pods = false
  }

  tags = local.tags

  depends_on = [
    azurerm_role_assignment.aks_msi_dns_zone,
    azurerm_role_assignment.aks_msi_vnet,
    azurerm_role_assignment.aks_msi_kubelet_operator
  ]
}
