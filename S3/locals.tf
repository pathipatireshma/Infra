locals {
  create_bucket = var.create_bucket
  attach_policy = var.attach_require_latest_tls_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_inventory_destination_policy || var.attach_policy
  grants = try(jsondecode(var.grant), var.grant)
  cors_rules = try(jsondecode(var.cors_rule), var.cors_rule)
  lifecycle_rules = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
  metric_configuration = try(jsondecode(var.metric_configuration), var.metric_configuration)
  intelligent_tiering  = try(jsondecode(var.intelligent_tiering), var.intelligent_tiering)
}
