availability_zone = "us-east-1c"
instance_type = "t3.small"
# user_data = "${file("install.sh")}"
subnet_id = "subnet-02470c5e30cf1098d"
vpc_security_group_ids = [ "sg-02784dbc7f03b1ef1" ]
monitoring = true