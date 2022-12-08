variable "create_origin_access_identity " {
    type = bool
    default = false
}
variable "origin_access_identities" {
    type = map(string)
    default = {}
}