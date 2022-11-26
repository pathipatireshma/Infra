resource "aws_instance" "this" {
    ami                         =   data.aws_ami.amazon.id
    associate_public_ip_address =   true
    availability_zone           =   var.availability_zone
    cpu_core_count              =   var.cpu_core_count
    cpu_threads_per_core        =   var.cpu_threads_per_core
    hibernation                 =    var.hibernation
    instance_type               =    var.instance_type
    key_name                    =    var.key_name
    disable_api_termination     =    var.disable_api_termination
    user_data                   =    var.user_data
    user_data_base64            =    var.user_data_base64
    user_data_replace_on_change =    var.user_data_replace_on_change
    subnet_id                   =    var.subnet_id
    vpc_security_group_ids      =    var.vpc_security_group_ids
    dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = lookup(var.launch_template, "id", null)
      name    = lookup(var.launch_template, "name", null)
      version = lookup(var.launch_template, "version", null)
      }
    }
    dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }
    

}