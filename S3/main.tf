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
resource "aws_s3_bucket_object_lock_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    token                 = try(var.object_lock_configuration.token, null)

    rule {
        default_retention {
            mode  = var.object_lock_configuration.rule.default_retention.mode
            days  = try(var.object_lock_configuration.rule.default_retention.days, null)
            years = try(var.object_lock_configuration.rule.default_retention.years, null)
        }
    }
}
resource "aws_s3_bucket_request_payment_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    payer = lower(var.request_payer) == "requester" ? "Requester" : "BucketOwner"
}
resource "aws_s3_bucket_cors_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    dynamic "cors_rule" {
       for_each =  local.cors_rules
       content {
        id              = try(cors_rule.value.id, null)
        allowed_methods = cors_rule.value.allowed_methods
        allowed_origins = cors_rule.value.allowed_origins
        allowed_headers = try(cors_rule.value.allowed_headers, null)
        expose_headers  = try(cors_rule.value.expose_headers, null)
        max_age_seconds = try(cors_rule.value.max_age_seconds, null)
       }
    }
}
resource "aws_s3_bucket_lifecycle_configuration" "this" {
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    dynamic "rule" {
        for_each = local.lifecycle_rules
        content {
          id  = try(rule.value.id,null)
          status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))
          dynamic "abort_incomplete_multipart_upload" {
            for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

            content {
                days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
            }
          }
          dynamic "expiration" {
            for_each = try(flatten([rule.value.expiration]), [])

            content {
                date                         = try(expiration.value.date, null)
                days                         = try(expiration.value.days, null)
                expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
            }            
          }
          dynamic "transition" {
            for_each = try(flatten([rule.value.transition]), [])

            content {
                date          = try(transition.value.date, null)
                days          = try(transition.value.days, null)
                storage_class = transition.value.storage_class
            }            
          }
          dynamic "noncurrent_version_expiration" {
            for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

            content {
                newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
                noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
            }            
          }
          dynamic "noncurrent_version_transition" {
            for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

            content {
                newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
                noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
                storage_class             = noncurrent_version_transition.value.storage_class
            }            
          }
          dynamic "filter" {
            for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

            content {
            }            
          }
          dynamic "filter" {
            for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

            content {
                object_size_greater_than = try(filter.value.object_size_greater_than, null)
                object_size_less_than    = try(filter.value.object_size_less_than, null)
                prefix                   = try(filter.value.prefix, null)

                dynamic "tag" {
                    for_each = try(filter.value.tags, filter.value.tag, [])

                    content {
                        key   = tag.key
                        value = tag.value
                    }
                }
            }            
          }
          dynamic "filter" {
            for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]
            content {
              and {
                object_size_greater_than = try(filter.value.object_size_greater_than, null)
                object_size_less_than    = try(filter.value.object_size_less_than, null)
                prefix                   = try(filter.value.prefix, null)
                tags                     = try(filter.value.tags, filter.value.tag, null)
              }
            }            
          }          
        }      
    }
    depends_on = [aws_s3_bucket_versioning.this]
}