variable "name" {
  description = "The name of the cluster"
  type        = string
  default     = "cluster"
}

variable "namespace" {
  type        = string
  default     = null
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
}

variable "tenant" {
  type        = string
  default     = null
  description = "ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for"
}

variable "environment" {
  type        = string
  default     = null
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "stage" {
  type        = string
  default     = null
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
}

variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "descriptor_formats" {
  type        = any
  default     = {}
  description = "Descriptor formats"
}

variable "label_order" {
  type        = list(string)
  default     = null
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
    EOT
}

variable "vpc_id" {
  description = "Mock input for vpc id"
  type        = string
  default     = ""
}

variable "lb_id" {
  description = "Mock input for lb id"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Version of the cluster"
  type        = string
  default     = "1.0.0"
}

resource "random_id" "id" {
  byte_length = 8
  keepers = {
    name            = var.name
    cluster_version = var.cluster_version
  }
}

resource "null_resource" "cluster_version" {
  triggers = {
    cluster_version = var.cluster_version
  }
}

resource "random_id" "id2" {
  byte_length = 8
  keepers = {
    name = var.name
  }
}

locals {
  mock_cluster_id = "${var.name}-${random_id.id.hex}"
}

output "cluster_id" {
  value = local.mock_cluster_id
}

output "vpc_id" {
  value = var.vpc_id
}

output "lb_id" {
  value = var.lb_id
}

output "cluster_version" {
  value = var.cluster_version
}
