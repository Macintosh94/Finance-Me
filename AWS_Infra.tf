terraform{
         required_providers {
                 aws = {
                         source = "hashicorp/aws"
                         version = "~> 4.0"
                 }
         }
}

# Configure Providers

provider "aws" {
  region  = "us-east-1"
  access_key = "AKIATVOIMA34DCNGVROL"
  secret_key = "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"

}

# Deploy Ec2 instances

resource "aws_instance" "test-server"{
        ami = "ami-053b0d53c279acc90"
        instance_type = "t2.micro"
        tags = {
        Name = "Test-Server"
        }
}

resource "aws_instance" "prod-server"{
        ami = "ami-053b0d53c279acc90"
        instance_type = "t2.micro"
        tags = {
        Name = "Prod-Server"
        }
}



