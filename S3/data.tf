data "aws_canonical_user_id" "this" {}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "combined" {
    count = local.create_bucket && local.attach_policy ? 1 : 0
    source_policy_documents = compact([
        var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
        var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
        var.attach_require_latest_tls_policy ? data.aws_iam_policy_document.require_latest_tls[0].json : "",
        var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
        var.attach_inventory_destination_policy ? data.aws_iam_policy_document.inventory_destination_policy[0].json : "",
        var.attach_policy ? var.policy : ""
    ])
}
data "aws_elb_service_account" "this" {
    count = local.create_bucket && var.attach_elb_log_delivery_policy ? 1 : 0  
}
data "aws_iam_policy_document" "elb_log_delivery" {
    count = local.create_bucket && var.attach_elb_log_delivery_policy ? 1 : 0
    statement {
        sid = ""
        principals {
            type = "AWS"
            identifiers = data.aws_elb_service_account.this[*].arn
        }
        effect = "Allow"
        actions = [ "s3:PutObject" ,
        ]
        resources = [
            "${aws_s3_bucket.this[0].arn}/*",
        ]
    }  
}
data "aws_iam_policy_document" "lb_log_delivery" {
    count = local.create_bucket && var.attach_lb_log_delivery_policy ? 1 : 0
    statement {
        sid = "AWSLogDeliveryWrite"
        principals {
            type = "Service"
            identifiers = ["delivery.logs.amazonaws.com"]
        }
        effect = "Allow"
        actions = ["s3.PutObject",
        ]
        resources = [
            "${aws_s3_bucket.this[0].arn}/*",
        ]
        condition {
            test = "StringEquals"
            variable = "s3:x-amz-acl"
            values   = ["bucket-owner-full-control"]
        }
    }
    statement {
        sid = "AWSLogDeliveryAclCheck"
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["delivery.logs.amazonaws.com"]
        }
        actions = [
            "s3:GetBucketAcl",
        ]
        resources = [
            aws_s3_bucket.this[0].arn,
        ]
    }  
}
data "aws_iam_policy_document" "deny_insecure_transport" {
    count = local.create_bucket && var.attach_deny_insecure_transport_policy ? 1 : 0
    statement {
        sid = "denyInsecureTransport"
        effect = "Deny"
        actions = [
            "s3:*",
        ]
        resources = [
            aws_s3_bucket.this[0].arn,
            "${aws_s3_bucket.this[0].arn}/*",
        ]
        principals {
            type        = "*"
            identifiers = ["*"]
        }
        condition {
            test = "Bool"
            variable = "aws:Securetransport"
            values = [
                "false"
            ]
        }   
    }  
}
data "aws_iam_policy_document" "require_latest_tls" {
    count = local.create_bucket && var.attach_require_latest_tls_policy ? 1 : 0
    statement {
        sid = "denyOutdatedTLS"
        effect = "Deny"
        actions = [ "s3:*" ]
        resources = [
            "aws_s3_bucket.this[0].arn",
            "${aws_s3_bucket.this[0].arn}/*",
        ]
        principals {
            type = "*"
            identifiers = ["*"]
        }
        condition {
            test     = "NumericLessThan"
            variable = "s3:TlsVersion"
            values = [
                "1.2"
            ]
        }
    }
}
data "aws_iam_policy_document" "inventory_destination_policy" {
    count = local.create_bucket && var.attach_inventory_destination_policy ? 1 : 0
    statement {
        sid = "destinationInventoryPolicy"
        effect = "Allow"
        actions = ["s3:PutOject",]
        resources = ["${aws_s3_bucket.this[0].arn}/*",]
        principals {
            type = "Service"
            identifiers = ["s3.amazonaws.com"]
        }
        condition {
            test     = "ArnLike"
            variable = "aws:SourceArn"
            values = [
                var.inventory_self_source_destination ? aws_s3_bucket.this[0].arn : var.inventory_source_bucket_arn
            ]
        }
        condition {
            test = "StringEquals"
            values = [
                var.inventory_self_source_destination ? data.aws_caller_identity.current.id : var.inventory_source_account_id
            ]
            variable = "aws:SourceAccount"
        }
        condition {
            test     = "StringEquals"
            values   = ["bucket-owner-full-control"]
            variable = "s3:x-amz-acl"
        }
    }  
}