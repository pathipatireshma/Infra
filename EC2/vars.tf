variable "availability_zone" {
    type = string
      
}

variable "cpu_core_count" {
    type = number
    
}

variable "cpu_threads_per_core" {
    type = number
    
}
variable "hibernation" {
    type = bool
}

variable "cpu_credits" {
    type = string
    default = "null"
}
variable "instance_type" {
    type = string
    default = "null"
  
}
variable "key_name" {
    type = string
    default = "null"
  
}
variable "launch_template" {
    type = map(string)
  
}
variable "disable_api_termination" {
    type        = bool
  
}
variable "ebs_block_device" {
    type        = list(map(string))
    default     = []
}
variable "user_data" {
    type = string
    default = "null"
}
variable "user_data_base64" {
    type = string
    default = "null"
}
variable "user_data_replace_on_change" {
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
variable "get_password_data" {
    type = bool
}
variable "host_id" {
    type = string
    default     = null
}

variable "metadata_options" {
    type = map(string)
    default     = null
}
variable "network_interface" {
    type = list(map(string)) 
    default     = null
}
variable "name" {
    type = string
  
}
variable "tags" {
    type = map(string)
  
}
