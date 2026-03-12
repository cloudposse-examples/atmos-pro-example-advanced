variable "name" {
  description = "The name of the frontend"
  type        = string
  default     = "frontend"
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

variable "api_id" {
  description = "Mock input for api id"
  type        = string
  default     = ""
}

variable "cache_id" {
  description = "Mock input for cache id"
  type        = string
  default     = ""
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  mock_frontend_id = "${var.name}-${random_id.id.hex}"
}

output "frontend_id" {
  value = local.mock_frontend_id
}

output "api_id" {
  value = var.api_id
}

output "cache_id" {
  value = var.cache_id
}
