variable "bucket" {
    type = string
  
}
variable "bucket_prefix" {
    type = string
  
}
variable "force_destroy" {
    type = bool
}
variable "object_lock_enabled" {
    type = bool
  
}
variable "tags" {
    type        = map(string)
    default     = {}
}
variable "expected_bucket_owner" {
    type = string
    default = "null"
}
variable "status" {
    type = string
    default = "null"
}
variable "acl" {
    type = string
    default = "null"  
}
variable "grant" {
    type = any
    default = []
  
}
variable "owner" {
    type = map(string)
    default  = {}
}
variable "website" {
    type = any
    default  = {}
}
variable "versioning" {
    type = map(string)
    default  = {}
  
}
variable "server_side_encryption_configuration" {
    type = any
    default  = {}  
}
variable "object_lock_configuration" {
    type = any
    default  = {}   
}
variable "request_payer" {
    type = string
    default = "null"
}
variable "cors_rule" {
    type = any
    default = []
}
variable "lifecycle_rule" {
    type = any
    default = []
}
variable "replication_configuration" {
    type = any
    default = {}
}
variable "create_bucket" {
    type = bool
    default = true  
}
variable "attach_require_latest_tls_policy" {
    type = bool
    default = false 
}
variable "attach_policy" {
    type = bool
    default = false
}
variable "attach_inventory_destination_policy" {
    type = bool
    default = false
}
variable "attach_elb_log_delivery_policy" {
    type = bool
    default = false
}
variable "attach_lb_log_delivery_policy" {
    type = bool
    default = false
}
variable "attach_deny_insecure_transport_policy" {
    type = bool
    default = false
}
variable "acceleration_status" {
    type = string
    default = "null"
}
variable "inventory_self_source_destination" {
    type = bool
    default = false
}
variable "inventory_source_bucket_arn" {
    type = string
    default = "null"
}
variable "inventory_source_account_id" {
    type = string
    default = "null"
}
variable "policy" {
    type = string
    default = "null"
}