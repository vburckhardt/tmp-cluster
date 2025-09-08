########################################################################################################################
# Cluster Module
########################################################################################################################

module "cluster" {
  source = "./modules/cluster"

  # Required variables
  resource_group_id = var.resource_group_id
  region           = var.region
  prefix           = var.prefix

  # Optional variables with defaults
  resource_tags      = var.resource_tags
  access_tags        = var.access_tags
  ocp_version        = var.ocp_version
  ocp_entitlement    = var.ocp_entitlement
  existing_vpc_id    = var.existing_vpc_id
  existing_cluster_id = var.existing_cluster_id
}