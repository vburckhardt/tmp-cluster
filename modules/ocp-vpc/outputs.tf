########################################################################################################################
# Outputs
########################################################################################################################

output "cluster_name" {
  value       = local.cluster_name
  description = "The name of the provisioned cluster."
}

output "cluster_id" {
  value       = local.cluster_id
  description = "The ID of the provisioned cluster."
}

output "ingress_hostname" {
  value       = local.ingress_hostname
  description = "The hostname of the cluster's ingress controller."
}
