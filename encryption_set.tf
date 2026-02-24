
# Manages a Resource Group.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
#
resource "azurerm_resource_group" "secrets" {
  name     = "${module.azure_resource_names.resource_group_secrets_name}"
  location = var.azure_resource_attributes.location
  tags     = local.tags

  lifecycle {
    ignore_changes = [tags.DateCreatedModified]
  }
}

# Manages a Key Vault.
#
# https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault.git
#
module "cluster_key_vault" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault.git?ref=v2.0.1"

  azure_resource_attributes = var.azure_resource_attributes
  naming_convention         = var.naming_convention
  user_defined              = "AKS"

  resource_group_name = azurerm_resource_group.secrets.name

  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  enable_rbac_authorization = true

  public_network_access_enabled = false
  private_endpoints = [
    {
      sub_resource_name   = "vault"
      subnet_id           = var.networking_ids.subnets.infrastructure
      private_dns_zone_id = var.networking_ids.dns_zones.keyvault
    }
  ]

  tags = local.tags
}

# Manages a Key Vault Key.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key
#
resource "azurerm_key_vault_key" "disk_encryption" {
  name         = "${module.azure_resource_names.name}-disk-encryption"
  key_vault_id = module.cluster_key_vault.id

  # Use an HSM-backed key
  key_type = "RSA-HSM"

  # Key size of 3072 is recommended by 2030, 4096 is largest supported
  # https://cyber.gc.ca/en/guidance/cryptographic-algorithms-unclassified-protected-and-protected-b-information-itsp40111
  key_size = "4096"

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  expiration_date = timeadd(timestamp(), "17520h")

  depends_on = [
    azurerm_role_assignment.runner_manage_keys,
    module.cluster_key_vault
  ]
}

#  Manages a Disk Encryption Set
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set
#
resource "azurerm_disk_encryption_set" "disk_encryption" {
  name                = module.azure_resource_names.disk_encryption_set_name
  resource_group_name = azurerm_resource_group.secrets.name
  location            = var.azure_resource_attributes.location
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption.id

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

############################
### RBAC & Access Policy ###
############################

# Allow the runner to manage the key vault keys
resource "azurerm_role_assignment" "runner_manage_keys" {
  scope = module.cluster_key_vault.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id = data.azurerm_client_config.current.object_id
}

# Allow the disk encryption set to access to the Key Vault key
resource "azurerm_role_assignment" "disk_encryption" {
  scope = module.cluster_key_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id = azurerm_disk_encryption_set.disk_encryption.identity.0.principal_id
}

# Allow the cluster identity to read the encryption set
resource "azurerm_role_assignment" "cluster_read_disk_encryption" {
  scope                = azurerm_disk_encryption_set.disk_encryption.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
