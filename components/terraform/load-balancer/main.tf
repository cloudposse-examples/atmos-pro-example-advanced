variable "name" {
  description = "The name of the load-balancer"
  type        = string
  default     = "load-balancer"
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

variable "lb_version" {
  description = "Version of the load balancer"
  type        = string
  default     = "1.0.0"
}

resource "random_id" "id" {
  byte_length = 8
  keepers = {
    name       = var.name
    lb_version = var.lb_version
  }
}

resource "null_resource" "lb_version" {
  triggers = {
    lb_version = var.lb_version
  }
}

locals {
  mock_lb_id = "${var.name}-${random_id.id.hex}"
}

output "lb_id" {
  value = local.mock_lb_id
}

output "vpc_id" {
  value = var.vpc_id
}

output "lb_version" {
  value = var.lb_version
}
