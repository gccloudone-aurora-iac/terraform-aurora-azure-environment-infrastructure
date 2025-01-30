locals {
  tags = merge(
    var.tags,
    {
      ModuleName    = "terraform-aurora-azure-environment-infrastructure",
      ModuleVersion = "v1.0.0",
    }
  )

  node_pool_zone_balance_fields = flatten([
    for nodepool_name, nodepool in var.node_pools :
    length(nodepool.availability_zones) > 0 ? [for zone in nodepool.availability_zones : {
      name               = "${nodepool_name}-${zone}"
      availability_zones = [zone]
      }] : [{
      name               = nodepool_name
      availability_zones = []
    }]
    ]
  )

  node_pool_zone_balance = {
    for pool in local.node_pool_zone_balance_fields :
    replace(pool.name, "-", "") => merge(var.node_pools[split("-", pool.name)[0]], { availability_zones = pool.availability_zones })
  }

  node_pools = {
    for nodepool_name, nodepool in local.node_pool_zone_balance :
    nodepool_name => nodepool.kubernetes_version != null ? nodepool : merge(nodepool, { kubernetes_version = var.kubernetes_version })
  }

  system_node_pool = try(merge(local.node_pools["system"], { name = "system" }), merge(local.node_pools["system1"], { name = "system1" }))
}
