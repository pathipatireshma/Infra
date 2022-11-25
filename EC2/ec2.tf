resource "aws_instance" "this" {
    ami                         =   data.aws_ami.amazon.id
    associate_public_ip_address =   true
    availability_zone           =   var.availability_zone
    cpu_core_count              =   var.cpu_core_count
    cpu_threads_per_core        =   var.cpu_threads_per_core
    hibernation                 =    var.hibernation
    
}