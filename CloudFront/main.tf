resource "aws_cloudfront_origin_access_identity" "this" {
    for_each = local.create_origin_access_identity ? var.origin_access_identities : {}
    comment = each.value
    lifecycle {
        create_before_destroy = true
    }
}
resource "aws_cloudfront_distribution" "this" {
    count = var.create_distribution ? 1 : 0
    aliases             = var.aliases
    comment             = var.comment
    default_root_object = var.default_root_object
    enabled             = var.enabled
    http_version        = var.http_version
    is_ipv6_enabled     = var.is_ipv6_enabled
    price_class         = var.price_class
    retain_on_delete    = var.retain_on_delete
    wait_for_deployment = var.wait_for_deployment
    web_acl_id          = var.web_acl_id
    tags                = var.tags
}