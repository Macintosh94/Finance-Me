terraform{
         required_providers {
                 aws = {
                         source = "hashicorp/aws"
                         version = "~> 4.0"
                 }
         }
}

locals {
  security_group_id = "sg-03c8373331e81fb6a"
  vpc_id = "vpc-047b174833ca44699"
  subnet_id = "subnet-0701a949f6a48fe16"
  internet_gateway_id = "igw-03bec895e5bb2ffbb"
}
provider "aws" {
  region = "us-east-1"
  shared_config_files      = ["/var/lib/jenkins/workspace/test-server-deployment/config"]
  shared_credentials_files = ["/var/lib/jenkins/workspace/test-server-deployment/credentials"]
}

resource "aws_network_interface" "test-ni1" {
   subnet_id  = local.subnet_id
   private_ips = ["10.0.128.6"]
   security_groups = [local.security_group_id]

}

resource "aws_eip" "test-eip" {
  vpc  = true
  network_interface = aws_network_interface.test-ni1.id
  associate_with_private_ip = "10.0.128.6"

}

resource "aws_instance" "test-server" {
  ami                         = "ami-053b0d53c279acc90" #us-east-1
  instance_type               = "t2.micro"
  key_name                    = "AWS_Key"
  availability_zone  = "us-east-1a"


  network_interface {
  network_interface_id = aws_network_interface.test-ni1.id
  device_index = 0
  } 

  tags = { 
    Name = "Test-Server"
  }

}

