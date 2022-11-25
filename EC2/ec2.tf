resource "aws_instance" "this" {
    ami                         =   data.aws_ami.amazon.id
    associate_public_ip_address =   true
    availability_zone           =   var.availability_zone
    cpu_core_count              =   var.cpu_core_count
    cpu_threads_per_core        =   var.cpu_threads_per_core
    hibernation                 =    var.hibernation
    instance_type               =    var.instance_type
    key_name                    =    var.key_name
    dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = lookup(var.launch_template, "id", null)
      name    = lookup(var.launch_template, "name", null)
      version = lookup(var.launch_template, "version", null)
      }
    }
}