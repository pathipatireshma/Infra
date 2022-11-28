terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40.0"
      # version = ">= 2.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}