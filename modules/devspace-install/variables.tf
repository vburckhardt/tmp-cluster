variable "cluster_id" {
  description = "Unique identifier for the cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where the resources will be deployed"
  type        = string
  default     = "openshift-operators"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key with permissions to access the cluster"
  type        = string
  sensitive = true
}

# variable "region" {
#   description = "Region where the cluster is located"
#   type        = string
# }