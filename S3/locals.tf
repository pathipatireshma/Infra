locals {
  grants = try(jsondecode(var.grant), var.grant)
  cors_rules = try(jsondecode(var.cors_rule), var.cors_rule)
}
