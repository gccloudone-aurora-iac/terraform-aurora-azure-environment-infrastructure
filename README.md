# terraform-azurerm-environment-infrastructure

This module deploys the Azure infrastructure required for a Cloud Native Environment within the Statistics Canada Azure Enterprise cloud environment.

## Usage

Examples for this module along with various configurations can be found in the [examples/](examples/) folder.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_resource_names"></a> [azure\_resource\_names](#module\_azure\_resource\_names) | git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-names.git | v2.0.0 |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | git::https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster.git | v2.0.3 |
| <a name="module_cluster_key_vault"></a> [cluster\_key\_vault](#module\_cluster\_key\_vault) | git::https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault.git | v2.0.1 |
| <a name="module_node_pool"></a> [node\_pool](#module\_node\_pool) | git::https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster-nodepool.git | v2.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_disk_encryption_set.disk_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) | resource |
| [azurerm_key_vault_access_policy.disk_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.runner_manage_keys](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.disk_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks_msi_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_msi_kubelet_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_msi_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_read_disk_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.aks_kubelet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_attributes"></a> [azure\_resource\_attributes](#input\_azure\_resource\_attributes) | Attributes used to describe Azure resources | <pre>object({<br/>    department_code = string<br/>    owner           = string<br/>    project         = string<br/>    environment     = string<br/>    location        = optional(string, "Canada Central")<br/>    instance        = number<br/>  })</pre> | n/a | yes |
| <a name="input_cluster_admins"></a> [cluster\_admins](#input\_cluster\_admins) | List of users/groups who can pull the admin kubeconfig | `list(string)` | `[]` | no |
| <a name="input_cluster_diag_setting"></a> [cluster\_diag\_setting](#input\_cluster\_diag\_setting) | Manages the diagnostic settings for a Kubernetes cluster. | <pre>map(object({<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    enabled_log_categories         = optional(list(string), ["kube-apiserver", "kube-controller-manager", "cluster-autoscaler"])<br/>    enable_all_metrics             = optional(bool, false)<br/>  }))</pre> | `null` | no |
| <a name="input_cluster_dns_service_ip"></a> [cluster\_dns\_service\_ip](#input\_cluster\_dns\_service\_ip) | The IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. | `string` | `"10.0.0.10"` | no |
| <a name="input_cluster_linux_profile_ssh_key"></a> [cluster\_linux\_profile\_ssh\_key](#input\_cluster\_linux\_profile\_ssh\_key) | SSH public key to access cluster nodes | `string` | `null` | no |
| <a name="input_cluster_service_cidr"></a> [cluster\_service\_cidr](#input\_cluster\_service\_cidr) | The service is used to assign IP addresses to the nodes and pods in the AKS cluster.This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cluster_sku_tier"></a> [cluster\_sku\_tier](#input\_cluster\_sku\_tier) | SKU Tier for the cluster ("Premium" is preferred) | `string` | `"Premium"` | no |
| <a name="input_cluster_support_plan"></a> [cluster\_support\_plan](#input\_cluster\_support\_plan) | Specifies the support plan which should be used for this Kubernetes Cluster. Possible values are KubernetesOfficial and AKSLongTermSupport. Defaults to KubernetesOfficial | `string` | `"KubernetesOfficial"` | no |
| <a name="input_cluster_vnet_id"></a> [cluster\_vnet\_id](#input\_cluster\_vnet\_id) | The Azure resource ID of the virtual network used for the AKS. | `string` | n/a | yes |
| <a name="input_custom_ca"></a> [custom\_ca](#input\_custom\_ca) | Configure a custom Certificate Authority (CA) for the Cluster | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version used by the control plane & the default version for the agent nodes. | `string` | n/a | yes |
| <a name="input_naming_convention"></a> [naming\_convention](#input\_naming\_convention) | Sets which naming convention to use. Accepted values: oss, gc | `string` | `"oss"` | no |
| <a name="input_networking_ids"></a> [networking\_ids](#input\_networking\_ids) | The Azure resource IDs for DNS Zones and subnets. | <pre>object({<br/>    dns_zones = object({<br/>      azmk8s   = string<br/>      keyvault = optional(string)<br/>    })<br/>    subnets = object({<br/>      api_server     = string<br/>      infrastructure = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_node_os_upgrade"></a> [node\_os\_upgrade](#input\_node\_os\_upgrade) | The maintenance window for the node OS upgrades. Refer to https://learn.microsoft.com/en-us/azure/aks/planned-maintenance for more information. | <pre>object({<br/>    channel = optional(string, "NodeImage")<br/>    maintenance_window = object({<br/>      frequency    = string # Daily, Weekly, AbsoluteMonthly or RelativeMonthly<br/>      interval     = number<br/>      day_of_week  = optional(string) # Friday, Monday, Saturday, Sunday, Thursday, Tuesday or Wednesday<br/>      day_of_month = optional(number) # Value between 0 and 31 (inclusive)<br/>      week_index   = optional(string) # First, Second, Third, Fourth, or Last<br/><br/>      start_time = optional(string) #  Format is HH:mm<br/>      utc_offset = optional(string, "+00:00")<br/>      duration   = string # The duration of the window for maintenance to run in hours<br/><br/>      not_allowed = optional(list(object({<br/>        end   = string<br/>        start = string<br/>      }))),<br/>    })<br/>  })</pre> | <pre>{<br/>  "channel": "NodeImage",<br/>  "maintenance_window": null<br/>}</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Node Pools along with their respective configurations. | <pre>map(<br/>    object({<br/>      vm_size                = optional(string, "Standard_D16s_v3")<br/>      vnet_subnet_id         = string<br/>      availability_zones     = optional(list(number), [1, 2, 3])<br/>      node_count             = optional(number, 3)<br/>      kubernetes_version     = optional(string, null)<br/>      node_labels            = optional(map(string), {})<br/>      node_taints            = optional(list(string), [])<br/>      max_pods               = optional(number, 60)<br/>      enable_host_encryption = optional(bool, true)<br/>      os_disk_size_gb        = optional(number, 256)<br/>      os_disk_type           = optional(string, "Managed")<br/>      os_type                = optional(string, "Linux")<br/>      vm_priority            = optional(string, "Regular")<br/>      eviction_policy        = optional(string, "Delete")<br/>      spot_max_price         = optional(string)<br/><br/>      upgrade_settings = optional(object({<br/>        max_surge                     = optional(string, "33%")<br/>        drain_timeout_in_minutes      = optional(number, 30)<br/>        node_soak_duration_in_minutes = optional(number, 0)<br/>        }), {<br/>        max_surge                     = "33%"<br/>        drain_timeout_in_minutes      = 30<br/>        node_soak_duration_in_minutes = 0<br/>      })<br/><br/>      enable_auto_scaling    = optional(bool, false)<br/>      auto_scaling_min_nodes = optional(number, 0)<br/>      auto_scaling_max_nodes = optional(number, 3)<br/>      mode                   = optional(string, "User")<br/>    })<br/>  )</pre> | <pre>{<br/>  "gateway": {<br/>    "auto_scaling_max_nodes": 3,<br/>    "auto_scaling_min_nodes": 0,<br/>    "availability_zones": [<br/>      1,<br/>      2,<br/>      3<br/>    ],<br/>    "enable_auto_scaling": false,<br/>    "enable_host_encryption": false,<br/>    "kubernetes_version": null,<br/>    "max_pods": 60,<br/>    "mode": "User",<br/>    "node_count": 3,<br/>    "node_labels": {},<br/>    "node_taints": [],<br/>    "os_disk_size_gb": 256,<br/>    "os_disk_type": "Managed",<br/>    "os_type": "Linux",<br/>    "upgrade_settings": {<br/>      "drain_timeout_in_minutes": 30,<br/>      "max_surge": "33%",<br/>      "node_soak_duration_in_minutes": 0<br/>    },<br/>    "vm_size": "Standard_D16s_v3",<br/>    "vnet_subnet_id": ""<br/>  },<br/>  "general": {<br/>    "auto_scaling_max_nodes": 3,<br/>    "auto_scaling_min_nodes": 0,<br/>    "availability_zones": [<br/>      1,<br/>      2,<br/>      3<br/>    ],<br/>    "enable_auto_scaling": false,<br/>    "enable_host_encryption": false,<br/>    "kubernetes_version": null,<br/>    "max_pods": 60,<br/>    "mode": "User",<br/>    "node_count": 3,<br/>    "node_labels": {},<br/>    "node_taints": [],<br/>    "os_disk_size_gb": 256,<br/>    "os_disk_type": "Managed",<br/>    "os_type": "Linux",<br/>    "upgrade_settings": {<br/>      "drain_timeout_in_minutes": 30,<br/>      "max_surge": "33%",<br/>      "node_soak_duration_in_minutes": 0<br/>    },<br/>    "vm_size": "Standard_D16s_v3",<br/>    "vnet_subnet_id": ""<br/>  },<br/>  "system": {<br/>    "auto_scaling_max_nodes": 3,<br/>    "auto_scaling_min_nodes": 0,<br/>    "availability_zones": [<br/>      1,<br/>      2,<br/>      3<br/>    ],<br/>    "enable_auto_scaling": false,<br/>    "enable_host_encryption": false,<br/>    "kubernetes_version": null,<br/>    "max_pods": 60,<br/>    "mode": "System",<br/>    "node_count": 3,<br/>    "node_labels": {},<br/>    "node_taints": [],<br/>    "os_disk_size_gb": 256,<br/>    "os_disk_type": "Managed",<br/>    "os_type": "Linux",<br/>    "upgrade_settings": {<br/>      "drain_timeout_in_minutes": 30,<br/>      "max_surge": "33%",<br/>      "node_soak_duration_in_minutes": 0<br/>    },<br/>    "vm_size": "Standard_D16s_v3",<br/>    "vnet_subnet_id": ""<br/>  }<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags attached to Azure resource | `map(string)` | `{}` | no |
| <a name="input_user_defined"></a> [user\_defined](#input\_user\_defined) | A user-defined field that describes the Azure resource. | `string` | n/a | yes |
| <a name="input_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#input\_vnet\_integration\_enabled) | Enable or disable Virtual Network Integration. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_admin_kubeconfig"></a> [cluster\_admin\_kubeconfig](#output\_cluster\_admin\_kubeconfig) | The admin kubeconfig of the created AKS cluster. |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the Azure Kubernetes Managed Cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The Azure resource ID of the created AKS cluster. |
| <a name="output_cluster_identity_object_id"></a> [cluster\_identity\_object\_id](#output\_cluster\_identity\_object\_id) | The identity details of the managed identity assigned to the cluster. Note: when configuring the cluster to use a userAssigned identity, the principal\_id field is empty. |
| <a name="output_cluster_kubeconfig"></a> [cluster\_kubeconfig](#output\_cluster\_kubeconfig) | A Terraform object that contains kubeconfig info. |
| <a name="output_cluster_kubelet_identity"></a> [cluster\_kubelet\_identity](#output\_cluster\_kubelet\_identity) | The identity details of the user-assigned managed indeity assigned to the cluster's kublets. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the AKS cluster. |
| <a name="output_cluster_node_resource_group_id"></a> [cluster\_node\_resource\_group\_id](#output\_cluster\_node\_resource\_group\_id) | The Azure resource ID of the resource group that contains the resources for the AKS cluster. |
| <a name="output_cluster_node_resource_group_name"></a> [cluster\_node\_resource\_group\_name](#output\_cluster\_node\_resource\_group\_name) | The resource group name that contains the resources for the AKS cluster. |
| <a name="output_cluster_resource_group_id"></a> [cluster\_resource\_group\_id](#output\_cluster\_resource\_group\_id) | The resource group ID that the created AKS cluster is in. |
| <a name="output_cluster_resource_group_name"></a> [cluster\_resource\_group\_name](#output\_cluster\_resource\_group\_name) | The resource group name that the created AKS cluster is in. |
| <a name="output_disk_encryption_key_vault_id"></a> [disk\_encryption\_key\_vault\_id](#output\_disk\_encryption\_key\_vault\_id) | The Azure resource ID of the Key Vault used to store the customer managed encryption key for the AKS cluster. |
| <a name="output_disk_encryption_key_vault_key"></a> [disk\_encryption\_key\_vault\_key](#output\_disk\_encryption\_key\_vault\_key) | The Azure resource ID of the key within an Azure Key Vault used as the customer managed encryption key for the AKS cluster. |
| <a name="output_disk_encryption_key_vault_private_endpoint_ids"></a> [disk\_encryption\_key\_vault\_private\_endpoint\_ids](#output\_disk\_encryption\_key\_vault\_private\_endpoint\_ids) | The Azure resource IDs of the private endpoints used on the Azure key vault used to store the customer managed encryption key for the AKS cluster. |
| <a name="output_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#output\_disk\_encryption\_set\_id) | The Azure resource ID of the disk encryption set used for the customer managed encryption key for the AKS cluster. |
| <a name="output_user_assigned_identity_aks_client_id"></a> [user\_assigned\_identity\_aks\_client\_id](#output\_user\_assigned\_identity\_aks\_client\_id) | The ID of the app associated with the AKS identity. |
| <a name="output_user_assigned_identity_aks_id"></a> [user\_assigned\_identity\_aks\_id](#output\_user\_assigned\_identity\_aks\_id) | The resource ID of the aks user-assigned managed identity. |
| <a name="output_user_assigned_identity_aks_principal_id"></a> [user\_assigned\_identity\_aks\_principal\_id](#output\_user\_assigned\_identity\_aks\_principal\_id) | The ID of the Service Principal object associated with the created AKS identity. |
| <a name="output_user_assigned_identity_kubelet_client_id"></a> [user\_assigned\_identity\_kubelet\_client\_id](#output\_user\_assigned\_identity\_kubelet\_client\_id) | The ID of the app associated with the kubelet identity. |
| <a name="output_user_assigned_identity_kubelet_id"></a> [user\_assigned\_identity\_kubelet\_id](#output\_user\_assigned\_identity\_kubelet\_id) | The resource ID of the kubelet user-assigned managed identity. |
| <a name="output_user_assigned_identity_kubelet_principal_id"></a> [user\_assigned\_identity\_kubelet\_principal\_id](#output\_user\_assigned\_identity\_kubelet\_principal\_id) | The ID of the Service Principal object associated with the created kubelet identity. |
<!-- END_TF_DOCS -->

## History

| Date       | Release | Change                                                                                                    |
| ---------- | ------- | --------------------------------------------------------------------------------------------------------- |
| 2025-01-25 | v1.0.0  | Initial commit                                                                                            |
| 2025-10-14 | v2.0.1  | Add `cluster_support_plan` variable and change default for `cluster_sku_tier` to `Premium`.               |
| 2025-10-20 | v2.0.2  | Pin minimum version of azurerm to 4.49.0                                                                  |
| 2025-10-20 | v2.0.3  | Add back VNET Network Integration since now out of preview                                                |
| 2025-10-20 | v2.0.4  | Add option to disable VNET Network Integration                                                            |
| 2025-10-31 | v2.0.5  | Adds the `cluster_diag_setting` variable to configure the cluster's diagnostic setting                    |
| 2025-10-28 | v2.0.6  | Change default for `cluster_sku_tier` to `Standard`                                                       |
| 2025-12-08 | v2.0.7  | Added support for `os_sku` to node pools.                                                                 |
| 2025-12-12 | v2.0.8  | Enabled workload identity by default.                                                                     |
| 2025-12-24 | v2.0.9  | Added output for `oidc_issuer_url` to support federated identity credential setup                         |                                                                   |