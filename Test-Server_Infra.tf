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

}
provider "aws" {
  region = "us-east-1"
  shared_config_files      = ["/var/lib/jenkins/workspace/test-server-deployment/config"]
  shared_credentials_files = ["/var/lib/jenkins/workspace/test-server-deployment/credentials"]
}
resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "test-ig" {
  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_route_table" "test-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.test-ig.id
  }

  tags = {
    Name = "RT1"
  }
}

resource "aws_subnet" "test-subnet" {
   vpc_id = aws_vpc.test-vpc.id
   cidr_block = "10.0.128.0/17"
   availability_zone = "us-east-1a"

   tags = {
     Name = "Subnet1"

   }
}
resource "aws_route_table_association" "test-rt-sub-association" {
  subnet_id = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.test-rt.id
}


resource "aws_network_interface" "test-ni" {
   subnet_id  = aws_subnet.test-subnet.id
   private_ips = ["10.0.128.6"]
   security_groups = [local.security_group_id]

}

resource "aws_eip" "test-eip" {
  vpc  = true
  network_interface = aws_network_interface.test-ni.id
  associate_with_private_ip = "10.0.128.6"

}

resource "aws_instance" "jenkins-server" {
  ami                         = "ami-053b0d53c279acc90" #us-east-1
  instance_type               = "t2.medium"
  key_name                    = "AWS_Key"
  availability_zone  = "us-east-1a"


  network_interface {
  network_interface_id = aws_network_interface.test-ni.id
  device_index = 0
  }
}
