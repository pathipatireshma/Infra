resource "aws_cloudfront_cache_policy" "this" {
    name = var.name
    min_ttl = var.min_ttl
    default_ttl = var.default_ttl
    comment = var.comment
    dymanic "parameters_in_cache_key_and_forwarded_to_origin" {
        for_each = var.parameters_in_cache_key_and_forwarded_to_origin
        content {
            
        }

    }
}