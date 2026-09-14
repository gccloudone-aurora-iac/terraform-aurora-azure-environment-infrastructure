locals {
  tags = merge(
    var.tags,
    {
      ModuleName    = "terraform-aurora-azure-environment-infrastructure",
      ModuleVersion = "v1.0.0",
    }
  )

  spn_object_ids = length(var.spn_object_ids) > 0 ? var.spn_object_ids : [data.azurerm_client_config.current.object_id]

  node_pool_zone_balance_fields = flatten([
    for nodepool_name, nodepool in var.node_pools :
    length(nodepool.availability_zones) > 0 ? [for zone in nodepool.availability_zones : {
      name               = "${nodepool_name}-${zone}"
      availability_zones = [zone]
      }] : [{
      name               = nodepool_name
      availability_zones = []
    }]
  ])

  node_pool_zone_balance = {
    for pool in local.node_pool_zone_balance_fields :
    replace(pool.name, "-", "") => merge(var.node_pools[split("-", pool.name)[0]], { availability_zones = pool.availability_zones })
  }

  node_pools = {
    for nodepool_name, nodepool in local.node_pool_zone_balance :
    nodepool_name => nodepool.kubernetes_version != null ? nodepool : merge(nodepool, { kubernetes_version = var.kubernetes_version })
  }

  # System-mode pools after zone expansion (e.g. ["system2"], or ["system1","system2","system3"]).
  # Selected by mode so the zone number is never hardcoded.
  system_pool_keys = sort([
    for nodepool_name, nodepool in local.node_pools : nodepool_name
    if try(nodepool.mode, "User") == "System"
  ])

  # Promote the first system-zone pool to be the cluster's default node pool.
  system_default_key = local.system_pool_keys[0]

  system_node_pool = merge(
    local.node_pools[local.system_default_key],
    { name = local.system_default_key }
  )
}
