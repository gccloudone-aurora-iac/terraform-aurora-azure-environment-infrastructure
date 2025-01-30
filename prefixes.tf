module "azure_resource_prefixes" {
  source = "git::https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-resource-prefixes.git?ref=v1.0.0"

  name_attributes = var.azure_resource_attributes
}
