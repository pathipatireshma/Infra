variable "availability_zone" {
    type = string
      
}
variable "instance_type" {
    type = string
   
}
variable "user_data" {
    type = string
    default = "null"
}
variable "subnet_id" {
    type        = string
    default     = null
}
variable "vpc_security_group_ids" {
    type        = list(string)
    default     = null
}
variable "monitoring" {
    type = bool
    
}  