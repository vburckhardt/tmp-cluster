########################################################################################################################
# Outputs
########################################################################################################################

output "cluster_name" {
  value       = module.openshift.cluster_name
  description = "The name of the provisioned cluster."
}

output "cluster_id" {
  value       = module.openshift.cluster_id
  description = "The ID of the provisioned cluster."
}

output "ingress_hostname" {
  value       = module.openshift.ingress_hostname
  description = "The hostname of the cluster's ingress controller."
}
