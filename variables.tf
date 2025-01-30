######################
### Azure Resource ###
######################

variable "azure_resource_attributes" {
  description = "Attributes used to describe Azure resources"
  type = object({
    project     = string
    environment = string
    location    = optional(string, "Canada Central")
    instance    = number
  })
  nullable = false
}

variable "tags" {
  description = "Tags attached to Azure resource"
  type        = map(string)
  default     = {}
}

######################
### AKS Networking ###
######################

variable "cluster_vnet_id" {
  description = "The Azure resource ID of the virtual network used for the AKS."
  type        = string
}

variable "cluster_service_cidr" {
  description = "The service is used to assign IP addresses to the nodes and pods in the AKS cluster.This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_dns_service_ip" {
  description = "The IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range."
  type        = string
  default     = "10.0.0.10"
}

###################
### AKS General ###
###################

variable "cluster_sku_tier" {
  description = "SKU Tier for the cluster (\"Standard\" is preferred)"
  type        = string
  default     = "Standard"
}

variable "cluster_admins" {
  description = "List of users/groups who can pull the admin kubeconfig"
  type        = list(string)
  default     = []
}

variable "cluster_linux_profile_ssh_key" {
  description = "SSH public key to access cluster nodes"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "The Kubernetes version used by the control plane & the default version for the agent nodes."
  type        = string
}

variable "node_os_upgrade" {
  description = "The maintenance window for the node OS upgrades. Refer to https://learn.microsoft.com/en-us/azure/aks/planned-maintenance for more information."
  type = object({
    channel = optional(string, "NodeImage")
    maintenance_window = object({
      frequency    = string # Daily, Weekly, AbsoluteMonthly or RelativeMonthly
      interval     = number
      day_of_week  = optional(string) # Friday, Monday, Saturday, Sunday, Thursday, Tuesday or Wednesday
      day_of_month = optional(number) # Value between 0 and 31 (inclusive)
      week_index   = optional(string) # First, Second, Third, Fourth, or Last

      start_time = optional(string) #  Format is HH:mm
      utc_offset = optional(string, "+00:00")
      duration   = string # The duration of the window for maintenance to run in hours

      not_allowed = optional(list(object({
        end   = string
        start = string
      }))),
    })
  })
  default = {
    channel            = "NodeImage"
    maintenance_window = null
  }

  validation {
    condition     = contains(["Unmanaged", "SecurityPatch", "NodeImage", "None"], var.node_os_upgrade.channel)
    error_message = "Invalid OS channel upgrade option. Must be one of 'Unmanaged', 'SecurityPatch', 'NodeImage' or 'None'."
  }
}

##################
### Node Pools ###
##################

variable "node_pools" {
  description = "Node Pools along with their respective configurations."
  type = map(
    object({
      vm_size                = optional(string, "Standard_D16s_v3")
      vnet_subnet_id         = string
      availability_zones     = optional(list(number), [1, 2, 3])
      node_count             = optional(number, 3)
      kubernetes_version     = optional(string, null)
      node_labels            = optional(map(string), {})
      node_taints            = optional(list(string), [])
      max_pods               = optional(number, 60)
      enable_host_encryption = optional(bool, true)
      os_disk_size_gb        = optional(number, 256)
      os_disk_type           = optional(string, "Managed")
      os_type                = optional(string, "Linux")
      vm_priority            = optional(string, "Regular")
      eviction_policy        = optional(string, "Delete")
      spot_max_price         = optional(string)

      upgrade_settings = optional(object({
        max_surge                     = optional(string, "33%")
        drain_timeout_in_minutes      = optional(number, 30)
        node_soak_duration_in_minutes = optional(number, 0)
        }), {
        max_surge                     = "33%"
        drain_timeout_in_minutes      = 30
        node_soak_duration_in_minutes = 0
      })

      enable_auto_scaling    = optional(bool, false)
      auto_scaling_min_nodes = optional(number, 0)
      auto_scaling_max_nodes = optional(number, 3)
      mode                   = optional(string, "User")
    })
  )
  default = {
    system = {
      node_count             = 3
      kubernetes_version     = null
      availability_zones     = [1, 2, 3]
      vm_size                = "Standard_D16s_v3"
      node_labels            = {}
      node_taints            = []
      max_pods               = 60
      enable_host_encryption = false
      os_disk_size_gb        = 256
      os_disk_type           = "Managed"
      os_type                = "Linux"
      vnet_subnet_id         = ""
      enable_auto_scaling    = false
      upgrade_settings = {
        max_surge                     = "33%"
        drain_timeout_in_minutes      = 30
        node_soak_duration_in_minutes = 0
      }
      auto_scaling_min_nodes = 0
      auto_scaling_max_nodes = 3
      mode                   = "System"
    }
    general = {
      node_count             = 3
      kubernetes_version     = null
      availability_zones     = [1, 2, 3]
      vm_size                = "Standard_D16s_v3"
      node_labels            = {}
      node_taints            = []
      max_pods               = 60
      enable_host_encryption = false
      os_disk_size_gb        = 256
      os_disk_type           = "Managed"
      os_type                = "Linux"
      vnet_subnet_id         = ""
      enable_auto_scaling    = false
      upgrade_settings = {
        max_surge                     = "33%"
        drain_timeout_in_minutes      = 30
        node_soak_duration_in_minutes = 0
      }
      auto_scaling_min_nodes = 0
      auto_scaling_max_nodes = 3
      mode                   = "User"
    }
    gateway = {
      node_count             = 3
      kubernetes_version     = null
      availability_zones     = [1, 2, 3]
      vm_size                = "Standard_D16s_v3"
      node_labels            = {}
      node_taints            = []
      max_pods               = 60
      enable_host_encryption = false
      os_disk_size_gb        = 256
      os_disk_type           = "Managed"
      os_type                = "Linux"
      vnet_subnet_id         = ""
      enable_auto_scaling    = false
      upgrade_settings = {
        max_surge                     = "33%"
        drain_timeout_in_minutes      = 30
        node_soak_duration_in_minutes = 0
      }
      auto_scaling_min_nodes = 0
      auto_scaling_max_nodes = 3
      mode                   = "User"
    }
  }

  validation {
    condition = (
      contains(keys(var.node_pools), "system")
    )
    error_message = "The var.node_pools must aleast contain a node pool with the name 'system'"
  }
}

###############################
### Networking Resource IDs ###
###############################

variable "networking_ids" {
  description = "The Azure resource IDs for DNS Zones and subnets."
  type = object({
    dns_zones = object({
      azmk8s   = string
      keyvault = string
    })
    subnets = object({
      api_server     = string
      infrastructure = string
    })
  })
}
