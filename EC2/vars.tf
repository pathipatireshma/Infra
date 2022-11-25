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