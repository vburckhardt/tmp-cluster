output "image_stream_name" {
  description = "Name of the created ImageStream"
  value       = "udi-custom"
}

output "build_config_name" {
  description = "Name of the created BuildConfig"
  value       = "txchange-tf"
}

output "image_reference" {
  description = "Full image reference for the built image"
  value       = "udi-custom:latest"
}

output "che_cluster_name" {
  description = "Name of the deployed CheCluster"
  value       = "devspaces"
}

output "che_namespace" {
  description = "Namespace where DevSpaces is deployed"
  value       = var.namespace
}
