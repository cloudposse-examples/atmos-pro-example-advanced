variable "name" {
  description = "The name of the monitoring stack"
  type        = string
  default     = "monitoring"
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

variable "api_id" {
  description = "Mock input for API id"
  type        = string
  default     = ""
}

variable "database_id" {
  description = "Mock input for database id"
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "Mock input for cluster id"
  type        = string
  default     = ""
}

variable "frontend_id" {
  description = "Mock input for frontend id"
  type        = string
  default     = ""
}

resource "random_id" "id" {
  byte_length = 8
  keepers = {
    name = var.name
  }
}

locals {
  mock_monitoring_id = "${var.name}-${random_id.id.hex}"
}

output "monitoring_id" {
  value = local.mock_monitoring_id
}

output "api_id" {
  value = var.api_id
}

output "database_id" {
  value = var.database_id
}

output "cluster_id" {
  value = var.cluster_id
}

output "frontend_id" {
  value = var.frontend_id
}
