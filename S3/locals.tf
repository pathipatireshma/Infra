locals {
  grants = try(jsondecode(var.grant), var.grant)
  cors_rules = try(jsondecode(var.cors_rule), var.cors_rule)
  lifecycle_rules = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
}
