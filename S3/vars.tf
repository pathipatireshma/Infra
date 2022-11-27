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
variable "tags " {
    type = map(string)
  
}