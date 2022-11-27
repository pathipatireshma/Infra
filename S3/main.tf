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