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