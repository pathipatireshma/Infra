variable "name" {
    type = string
     
}
variable "min_ttl" {
    type = string
      
}
variable "max_ttl" {
    type = string
    default = "null"
  
}
variable "default_ttl" {
    type = string
    default = "null"
  
}
variable "comment" {
    type = string
    default = "null"
  
}
variable "parameters_in_cache_key and_forwarded_to_origin" {
    type = map(string)
  
}
