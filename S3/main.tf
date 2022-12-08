resource "aws_s3_bucket" "this" {
    count = local.create_bucket ? 1 : 0
    bucket              = var.bucket
    bucket_prefix       = var.bucket_prefix
    force_destroy       = var.force_destroy
    object_lock_enabled = var.object_lock_enabled
    tags                = var.tags
   
}
resource "aws_s3_bucket_accelerate_configuration" "this" {
    count = local.create_bucket && var.acceleration_status != null ? 1 : 0
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    status                  = var.status 
    
}
resource "aws_s3_bucket_acl" "this" {
    count = local.create_bucket && ((var.acl != null && var.acl != "null") || length(local.grants) > 0) ? 1 : 0
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
    count = local.create_bucket && length(keys(var.website)) > 0 ? 1 : 0
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
    count = local.create_bucket && length(keys(var.versioning)) > 0 ? 1 : 0
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    mfa                   = try(var.versioning["mfa"], null)
    versioning_configuration {
        status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))
        mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
    }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    count = local.create_bucket && length(keys(var.server_side_encryption_configuration)) > 0 ? 1 : 0
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
    count = local.create_bucket && var.object_lock_enabled && try(var.object_lock_configuration.rule.default_retention, null) != null ? 1 : 0
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
    count = local.create_bucket && var.request_payer != null ? 1 : 0
    bucket                  = var.bucket
    expected_bucket_owner   = var.expected_bucket_owner
    payer = lower(var.request_payer) == "requester" ? "Requester" : "BucketOwner"
}
resource "aws_s3_bucket_cors_configuration" "this" {
    count = local.create_bucket && length(local.cors_rules) > 0 ? 1 : 0
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
    count = local.create_bucket && length(local.lifecycle_rules) > 0 ? 1 : 0
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
resource "aws_s3_bucket_replication_configuration" "this" {
    count = local.create_bucket && length(keys(var.replication_configuration)) > 0 ? 1 : 0
    bucket = var.bucket
    role = var.replication_configuration["role"]
    dynamic "rule" {
        for_each = flatten(try([var.replication_configuration["rule"]], [var.replication_configuration["rules"]], []))

        content {
            id       = try(rule.value.id, null)
            priority = try(rule.value.priority, null)
            prefix   = try(rule.value.prefix, null)
            status   = try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)), "Enabled")
            dynamic "delete_marker_replication" {
              for_each = flatten(try([rule.value.delete_marker_replication_status], [rule.value.delete_marker_replication], []))

                content {
                    status = try(tobool(delete_marker_replication.value) ? "Enabled" : "Disabled", title(lower(delete_marker_replication.value)))
                }
            }
            dynamic "existing_object_replication" {
                for_each = flatten(try([rule.value.existing_object_replication_status], [rule.value.existing_object_replication], []))

                content {          
                    status = try(tobool(existing_object_replication.value) ? "Enabled" : "Disabled", title(lower(existing_object_replication.value)))
                }              
            }
            dynamic "destination" {
                for_each = try(flatten([rule.value.destination]), [])

                content {
                    bucket        = destination.value.bucket
                    storage_class = try(destination.value.storage_class, null)
                    account       = try(destination.value.account_id, destination.value.account, null)
                    dynamic "access_control_translation" {
                        for_each = try(flatten([destination.value.access_control_translation]), [])

                        content {
                            owner = title(lower(access_control_translation.value.owner))
                        }           
                    }
                    dynamic "encryption_configuration" {
                        for_each = flatten([try(destination.value.encryption_configuration.replica_kms_key_id, destination.value.replica_kms_key_id, [])])

                        content {
                            replica_kms_key_id = encryption_configuration.value
                        }                      
                    }
                    dynamic "replication_time" {
                        for_each = try(flatten([destination.value.replication_time]), [])

                        content {
                            status = try(tobool(replication_time.value.status) ? "Enabled" : "Disabled", title(lower(replication_time.value.status)), "Disabled")
                            dynamic "time" {
                                for_each = try(flatten([replication_time.value.minutes]), [])

                                content {
                                    minutes = replication_time.value.minutes
                                }                              
                            }                                                    
                        }
                    }
                    dynamic "metrics" {
                        for_each = try(flatten([destination.value.metrics]), [])
                        content {
                          status = try(tobool(metrics.value.status) ? "Enabled" : "Disabled", title(lower(metrics.value.status)), "Disabled")
                          dynamic "event_threshold" {
                            for_each = try(flatten([metrics.value.minutes]), [])
                            content {
                                minutes = metrics.value.minutes
                            }                            
                          }
                        }                      
                    }
                }
            }
            dynamic "source_selection_criteria" {
                for_each = try(flatten([rule.value.source_selection_criteria]), [])
                content {
                    dynamic "replica_modifications" {
                        for_each = flatten([try(source_selection_criteria.value.replica_modifications.enabled, source_selection_criteria.value.replica_modifications.status, [])])
                        content {
                            status = try(tobool(replica_modifications.value) ? "Enabled" : "Disabled", title(lower(replica_modifications.value)), "Disabled")
                        }                      
                    }
                    dynamic "sse_kms_encrypted_objects" {
                        for_each = flatten([try(source_selection_criteria.value.sse_kms_encrypted_objects.enabled, source_selection_criteria.value.sse_kms_encrypted_objects.status, [])])
                        content {
                          status = try(tobool(sse_kms_encrypted_objects.value) ? "Enabled" : "Disabled", title(lower(sse_kms_encrypted_objects.value)), "Disabled")
                        }                      
                    }
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
                    prefix = try(filter.value.prefix, null)
                    dynamic "tag" {
                        for_each = try(filter.value.tags, filter.value.tag, [])
                        content {
                            key = tag.key
                            value = tag.value
                        }                      
                    }
                }              
            }
            dynamic "filter" {
                for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]
                content {
                    and {
                        prefix = try(filter.value.prefix, null)
                        tags   = try(filter.value.tags, filter.value.tag, null)
                    }
                }              
            }
        }    
    }
    depends_on = [aws_s3_bucket_versioning.this]
}
resource "aws_s3_bucket_policy" "this" {
    count = local.create_bucket && local.attach_policy ? 1 : 0
    bucket = var.bucket
    policy = data.aws_iam_policy_document.combined[0].json  
}
resource "aws_s3_bucket_public_access_block" "this" {
    count = local.create_bucket && var.attach_public_policy ? 1 : 0
    bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this[0].id
    block_public_acls       = var.block_public_acls
    block_public_policy     = var.block_public_policy
    ignore_public_acls      = var.ignore_public_acls
    restrict_public_buckets = var.restrict_public_buckets
  
}
resource "aws_s3_bucket_ownership_controls" "this" {
    count = local.create_bucket && var.control_object_ownership ? 1 : 0
    bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this[0].id
    rule {
      object_ownership = var.object_ownership
    }
    depends_on = [
        aws_s3_bucket_policy.this,
        aws_s3_bucket_public_access_block.this,
        aws_s3_bucket.this
    ]  
}
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
    for_each = { for k, v in local.intelligent_tiering : k => v if local.create_bucket }
    name   = each.key
    bucket = aws_s3_bucket.this[0].id
    status = try(tobool(each.value.status) ? "Enabled" : "Disabled", title(lower(each.value.status)), null)
    dynamic "filter" {
        for_each = length(try(flatten([each.value.filter]), [])) == 0 ? [] : [true]
        content {
            prefix = try(each.value.filter.prefix, null)
            tags   = try(each.value.filter.tags, null)
        }      
    }
    dynamic "tiering" {
        for_each = each.value.tiering
        content {
            access_tier = tiering.key
            days        = tiering.value.days
        }
    }  
}
resource "aws_s3_bucket_metric" "this" {
    for_each = { for k, v in local.metric_configuration : k => v if local.create_bucket }
    name   = each.value.name
    bucket = aws_s3_bucket.this[0].id
    dynamic "filter" {
        for_each = length(try(flatten([each.value.filter]), [])) == 0 ? [] : [true]
        content {
            prefix = try(each.value.filter.prefix, null)
            tags   = try(each.value.filter.tags, null)
        }
    }  
}
resource "aws_s3_bucket_inventory" "this" {
    for_each = { for k, v in var.inventory_configuration : k => v if local.create_bucket }
    name                     = each.key
    bucket                   = try(each.value.bucket, aws_s3_bucket.this[0].id)
    included_object_versions = each.value.included_object_versions
    enabled                  = try(each.value.enabled, true)
    optional_fields          = try(each.value.optional_fields, null)
    destination {
        bucket {
            bucket_arn = try(each.value.destination.bucket_arn, aws_s3_bucket.this[0].arn)
            format     = try(each.value.destination.format, null)
            account_id = try(each.value.destination.account_id, null)
            prefix     = try(each.value.destination.prefix, null)
            dynamic "encryption" {
                for_each = length(try(flatten([each.value.destination.encryption]), [])) == 0 ? [] : [true]
                content {
                    dynamic "sse_kms" {
                        for_each = each.value.destination.encryption.encryption_type == "sse_kms" ? [true] : []
                        content {
                            key_id = try(each.value.destination.encryption.kms_key_id, null)
                        }                      
                    }
                    dynamic "sse_s3" {
                        for_each = each.value.destination.encryption.encryption_type == "sse_s3" ? [true] : []
                        content {
                          
                        }
                    }
                }
            }
        }
    }
    schedule {
        frequency = each.value.frequency
    }
    dynamic "filter" {
        for_each = length(try(flatten([each.value.filter]), [])) == 0 ? [] : [true]
        content {
            prefix = try(each.value.filter.prefix, null)
        }      
    }
}