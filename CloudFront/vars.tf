variable "create_origin_access_identity " {
    type = bool
    default = false
}
variable "origin_access_identities" {
    type = map(string)
    default = {}
}
variable "aliases" {
    type = list(string)
    default = [ "null" ]
}
variable "comment" {
    type = string
    default = "null"
}
variable "default_root_object" {
    type = string
    default = "null"
}
variable "enabled" {
    type = bool
    default = true
}
variable "http_version" {
    type = string
    default = "http2"
}
variable "is_ipv6_enabled" {
    type = bool
    default = null
}
variable "price_class" {
    type = string
    default = "null"
}
variable "retain_on_delete" {
    type = bool
    default = false
}
variable "wait_for_deployment" {
    type = bool
    default = true
}
variable "web_acl_id" {
    type = string
    default = "null"
}
variable "tags" {
    type = map(string)
    default = null
}