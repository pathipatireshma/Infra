resource "aws_cloudfront_origin_access_identity" "this" {
    for_each = local.create_origin_access_identity ? var.origin_access_identities : {}
    comment = each.value
    lifecycle {
        create_before_destroy = true
    }
}