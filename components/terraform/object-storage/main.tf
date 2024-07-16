resource "random_id" "id" {
  byte_length = 8
}

locals {
  mock_storage_id = "storage-${random_id.id.hex}"
}

output "storage_id" {
  value = local.mock_storage_id
}
