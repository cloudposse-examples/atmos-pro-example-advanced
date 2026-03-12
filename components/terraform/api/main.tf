variable "name" {
  description = "The name of the API"
  type        = string
  default     = "api"
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
  type        = map(string)
  default     = {}
  description = "Descriptor formats"
}


variable "database_id" {
  description = "Mock database ID"
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "Mock cluster ID"
  type        = string
  default     = ""
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  mock_api_id = "${var.name}-${random_id.id.hex}"
}

output "api_id" {
  value = local.mock_api_id
}

output "database_id" {
  value = var.database_id
}

output "cluster_id" {
  value = var.cluster_id
}
