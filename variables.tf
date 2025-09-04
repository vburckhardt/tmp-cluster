########################################################################################################################
# Input Variables
########################################################################################################################

# variable "ibmcloud_api_key" {
#   type        = string
#   description = "The IBM Cloud api key"
#   sensitive   = true
# }

variable "resource_group_id" {
  type        = string
  description = "The Resource Group ID to use for all resources created in this solution (VPC and cluster)"
  default     = null
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
  default = "txc"
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "us-south"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the resources created by the module"
  default     = []
}

variable "ocp_version" {
  type        = string
  description = "Version of the OCP cluster to provision"
  default     = null
}

variable "ocp_entitlement" {
  type        = string
  description = "Value that is applied to the entitlements for OCP cluster provisioning"
  default     = null
}

variable "existing_vpc_id" {
  description = "The ID of the existing vpc. If not set, a new VPC will be created."
  type        = string
  default     = null
}

variable "existing_cluster_id" {
  description = "The CRN of the existing cluster. If not set, a new cluster will be created."
  type        = string
  default     = null
}
