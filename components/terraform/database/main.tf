variable "name" {
  description = "The name of the database"
  type        = string
  default     = "database"
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

variable "vpc_id" {
  description = "Mock input for vpc id"
  type        = string
  default     = ""
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  mock_database_id = "${var.name}-${random_id.id.hex}"
}

output "database_id" {
  value = local.mock_database_id
}

output "vpc_id" {
  value = var.vpc_id
}
