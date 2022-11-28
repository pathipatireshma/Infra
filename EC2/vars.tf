variable "availability_zone" {
    type = string
      
}

variable "cpu_core_count" {
    type = number
    default = 1
}

variable "cpu_threads_per_core" {
    type = number
    default = 1
    
}
variable "hibernation" {
    type = bool
    default = false
}

variable "cpu_credits" {
    type = string
    default = "null"
}
variable "instance_type" {
    type = string
   
}
variable "key_name" {
    type = string
    default = "null"
  
}
variable "launch_template" {
    type = map(string)
    default = {}
  
}
variable "disable_api_termination" {
    type        = bool
    default = false
  
}
variable "ebs_block_device" {
    type        = list(map(string))
    default     = []
}
variable "user_data" {
    type = string
    default = "null"
}

variable "user_data_replace_on_change" {
    type = bool
    default = false
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
    default = false
    
}  
variable "get_password_data" {
    type = bool
    default = false
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
    default     = []
}
variable "name" {
    type = string
    default = []
  
}
variable "tags" {
    type = map(string)
    default = {}  
}
