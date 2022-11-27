locals {
  grants = try(jsondecode(var.grant), var.grant)
}
