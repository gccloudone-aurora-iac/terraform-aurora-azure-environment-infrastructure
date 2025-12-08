##################################
### Kubernetes Nodepool Module ###
##################################

# Manages a Node Pool within a Kubernetes Cluster
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
#
module "node_pool" {
  for_each = { for nodepool_name, nodepool in local.node_pools : nodepool_name => nodepool if nodepool_name != "system1" && nodepool_name != "system" }

  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster-nodepool.git?ref=v2.0.2"

  name                  = each.key
  kubernetes_cluster_id = module.cluster.kubernetes_cluster_id

  node_count         = each.value.node_count
  kubernetes_version = each.value.kubernetes_version
  availability_zones = each.value.availability_zones

  # Node Configuration
  vm_size     = each.value.vm_size
  node_labels = each.value.node_labels
  node_taints = each.value.node_taints
  max_pods    = each.value.max_pods

  # Node priority configuration
  vm_priority     = each.value.vm_priority
  eviction_policy = each.value.eviction_policy
  spot_max_price  = each.value.spot_max_price

  # Disk configuration
  enable_host_encryption = each.value.enable_host_encryption
  os_disk_size_gb        = each.value.os_disk_size_gb
  os_disk_type           = each.value.os_disk_type
  os_sku                 = each.value.os_sku
  os_type                = each.value.os_type

  # Network configuration
  vnet_subnet_id = each.value.vnet_subnet_id

  # Upgrade configuration
  upgrade_settings = {
    drain_timeout_in_minutes      = each.value.upgrade_settings.drain_timeout_in_minutes
    node_soak_duration_in_minutes = each.value.upgrade_settings.node_soak_duration_in_minutes
    max_surge                     = each.value.upgrade_settings.max_surge
  }

  # Autoscaling
  enable_auto_scaling    = each.value.enable_auto_scaling
  auto_scaling_min_nodes = each.value.enable_auto_scaling ? each.value.auto_scaling_min_nodes : null
  auto_scaling_max_nodes = each.value.enable_auto_scaling ? each.value.auto_scaling_max_nodes : null

  # Mode
  mode = each.value.mode

  tags = local.tags
}
