module "ec2_example" {
    source = "../"
    availability_zone = var.availability_zone
    key_name = "Linux_key"
    instance_type = var.instance_type
    user_data = "${file("install.sh")}"
    subnet_id                   =    var.subnet_id
    vpc_security_group_ids      =    var.vpc_security_group_ids
    monitoring                  =    var.monitoring
}