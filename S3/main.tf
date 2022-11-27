resource "aws_s3_bucket" "this" {
    bucket              = var.bucket
    bucket_prefix       = var.bucket_prefix
    force_destroy       = var.force_destroy
    object_lock_enabled = var.object_lock_enabled
    tags                = var.tags
   
}
resource "aws_s3_bucket_accelerate_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    status                  = var.status 
    
}
resource "aws_s3_bucket_acl" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    acl                     = var.acl
    dynamic "access_control_policy" {
        for_each = length(local.grants) > 0 ? [true] : []
        content {
            dynamic "grant" {
                for_each = local.grants

                content {
                    permission = grant.value.permission

                    grantee {
                        type          = grant.value.type
                        id            = try(grant.value.id, null)
                        uri           = try(grant.value.uri, null)
                        email_address = try(grant.value.email, null)
                    }
                }
            }
            owner {
                id           = try(var.owner["id"], data.aws_canonical_user_id.this.id)
                display_name = try(var.owner["display_name"], null)
            }
        }
    }
}

resource "aws_s3_bucket_website_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    dynamic "index_document" {
        for_each = try([var.website["index_document"]], [])

        content {
            suffix = index_document.value
        }
    }

    dynamic "error_document" {
        for_each = try([var.website["error_document"]], [])

        content {
            key = error_document.value
        }
    }
    dynamic "redirect_all_requests_to" {
        for_each = try([var.website["redirect_all_requests_to"]], [])

        content {
            host_name = redirect_all_requests_to.value.host_name
            protocol  = try(redirect_all_requests_to.value.protocol, null)
        }
    }
    dynamic "routing_rule" {
        for_each = try(flatten([var.website["routing_rules"]]), [])

        content {
            dynamic "condition" {
                for_each = [try([routing_rule.value.condition], [])]

                content {
                    http_error_code_returned_equals = try(routing_rule.value.condition["http_error_code_returned_equals"], null)
                    key_prefix_equals               = try(routing_rule.value.condition["key_prefix_equals"], null)
                }
            }

            redirect {
                host_name               = try(routing_rule.value.redirect["host_name"], null)
                http_redirect_code      = try(routing_rule.value.redirect["http_redirect_code"], null)
                protocol                = try(routing_rule.value.redirect["protocol"], null)
                replace_key_prefix_with = try(routing_rule.value.redirect["replace_key_prefix_with"], null)
                replace_key_with        = try(routing_rule.value.redirect["replace_key_with"], null)
            }
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    mfa                   = try(var.versioning["mfa"], null)
    versioning_configuration {
        status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))
        mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
    }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    dynamic "rule" {
        for_each = try(flatten([var.server_side_encryption_configuration["rule"]]), [])

        content {
            bucket_key_enabled = try(rule.value.bucket_key_enabled, null)

            dynamic "apply_server_side_encryption_by_default" {
                for_each = try([rule.value.apply_server_side_encryption_by_default], [])

                content {
                    sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
                    kms_master_key_id = try(apply_server_side_encryption_by_default.value.kms_master_key_id, null)
                }
            }
        }
    }
}