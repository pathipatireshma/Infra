resource "aws_cloudfront_cache_policy" "this" {
    name = var.name
    min_ttl = var.min_ttl
    default_ttl = var.default_ttl
    comment = var.comment
}