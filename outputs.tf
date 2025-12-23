###################
### AKS Cluster ###
###################

### Names & Resource IDs ###

output "cluster_id" {
  description = "The Azure resource ID of the created AKS cluster."
  value       = module.cluster.kubernetes_cluster_id
}

output "cluster_name" {
  description = "The name of the AKS cluster."
  value       = module.cluster.kubernetes_cluster_name
}

output "cluster_resource_group_id" {
  description = "The resource group ID that the created AKS cluster is in."
  value       = azurerm_resource_group.aks.id
}

output "cluster_resource_group_name" {
  description = "The resource group name that the created AKS cluster is in."
  value       = azurerm_resource_group.aks.name
}

output "cluster_node_resource_group_id" {
  description = "The Azure resource ID of the resource group that contains the resources for the AKS cluster."
  value       = module.cluster.node_resource_group_id
}

output "cluster_node_resource_group_name" {
  description = "The resource group name that contains the resources for the AKS cluster."
  value       = module.cluster.node_resource_group_name
}

output "cluster_kubeconfig" {
  description = "A Terraform object that contains kubeconfig info."
  value       = module.cluster.kubeconfig
}

### Identities ###

output "cluster_kubelet_identity" {
  description = "The identity details of the user-assigned managed indeity assigned to the cluster's kublets."
  value       = module.cluster.kubernetes_kubelet_identity
}

// Refer to https://github.com/hashicorp/terraform-provider-azurerm/issues/13362
output "cluster_identity_object_id" {
  description = "The identity details of the managed identity assigned to the cluster. Note: when configuring the cluster to use a userAssigned identity, the principal_id field is empty."
  value       = module.cluster.kubernetes_identity.0.principal_id
}

output "user_assigned_identity_aks_id" {
  description = "The resource ID of the aks user-assigned managed identity."
  value       = azurerm_user_assigned_identity.aks.id
}

output "user_assigned_identity_aks_client_id" {
  description = "The ID of the app associated with the AKS identity."
  value       = azurerm_user_assigned_identity.aks.client_id
}

output "user_assigned_identity_aks_principal_id" {
  description = "The ID of the Service Principal object associated with the created AKS identity."
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "user_assigned_identity_kubelet_id" {
  description = "The resource ID of the kubelet user-assigned managed identity."
  value       = azurerm_user_assigned_identity.aks_kubelet.id
}

output "user_assigned_identity_kubelet_client_id" {
  description = "The ID of the app associated with the kubelet identity."
  value       = azurerm_user_assigned_identity.aks_kubelet.client_id
}

output "user_assigned_identity_kubelet_principal_id" {
  description = "The ID of the Service Principal object associated with the created kubelet identity."
  value       = azurerm_user_assigned_identity.aks_kubelet.principal_id
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value = module.cluster.oidc_issuer_url
}

### Other ###

output "cluster_admin_kubeconfig" {
  description = "The admin kubeconfig of the created AKS cluster."
  value       = module.cluster.admin_kubeconfig
}

output "cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = module.cluster.fqdn
}

#######################
### Disk Encryption ###
#######################

output "disk_encryption_key_vault_id" {
  description = "The Azure resource ID of the Key Vault used to store the customer managed encryption key for the AKS cluster."
  value       = module.cluster_key_vault.id
}

output "disk_encryption_key_vault_private_endpoint_ids" {
  description = "The Azure resource IDs of the private endpoints used on the Azure key vault used to store the customer managed encryption key for the AKS cluster."
  value       = module.cluster_key_vault.private_endpoint_ids
}

output "disk_encryption_key_vault_key" {
  description = "The Azure resource ID of the key within an Azure Key Vault used as the customer managed encryption key for the AKS cluster."
  value       = azurerm_key_vault_key.disk_encryption.resource_id
}

output "disk_encryption_set_id" {
  description = "The Azure resource ID of the disk encryption set used for the customer managed encryption key for the AKS cluster."
  value       = azurerm_disk_encryption_set.disk_encryption.id
}
