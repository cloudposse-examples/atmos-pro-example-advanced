variable "name" {
  description = "The name of the storage"
  type        = string
  default     = "storage"
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

variable "storage_version" {
  description = "Version of the object storage"
  type        = string
  default     = "1.0.0"
}

resource "random_id" "id" {
  byte_length = 8
  keepers = {
    name            = var.name
    storage_version = var.storage_version
  }
}

resource "null_resource" "storage_version" {
  triggers = {
    storage_version = var.storage_version
  }
}

locals {
  mock_storage_id = "${var.name}-${random_id.id.hex}"
}

output "storage_id" {
  value = local.mock_storage_id
}

output "storage_version" {
  value = var.storage_version
}
