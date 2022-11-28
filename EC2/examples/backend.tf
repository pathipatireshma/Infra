terraform {
    backend "s3" {
        bucket = "reshma-cloud-practice"
        key = "tfstatefiles/example_ec2/terraform.tfstate"
        region = "us-east-1"
        

      
    }
  
}