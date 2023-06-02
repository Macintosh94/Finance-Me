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
  access_key = "AKIATVOIMA34B7DRMV67"
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



