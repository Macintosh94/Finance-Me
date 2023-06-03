terraform{
         required_providers {
                 aws = {
                         source = "hashicorp/aws"
                         version = "~> 4.0"
                 }
         }
}

provider "aws" {
  region = "us-east-1"
  shared_config_files      = ["/var/lib/jenkins/config"]
  shared_credentials_files = ["/var/lib/jenkins/credentials"]
}
resource "aws_instance" "test-server" {
  ami                         = "ami-053b0d53c279acc90"
  subnet_id                   = "subnet-0325f173ed2ce59ad"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = local.key_name
  tags = {
    Name = "Test-Server"
    }
  }

  esource "aws_vpc" "test-vpc" {
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
   cidr_block = "10.0.0.0/16"
   availability_zone = "us-east-1c"

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
   private_ips = ["10.0.11.77"]
   
}

resource "aws_eip" "test-eip"{

  vpc  = true
  network_interface = aws_network_interface.test-ni.id
  associate_with_private_ip = "10.0.11.77"
}