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
  instance_type               = "t2.micro"
  key_name                    = "AWS_Key"

 network_interface {
   network_interface_id = aws_network_interface.test-ni.id
   device_index = 0
 }

  tags = {
    Name = "Test-Server"
    }
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

resource "aws_security_group" "test-sg" {
    name = "test-sg"
    description = "Enable ports 22, 80, 443"  
    vpc_id = aws_vpc.test-vpc.id

    ingress {

        description = "HTTPS Traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    ingress {

        description = "HTTP Traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    
    ingress {

        description = "SSH Port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {

        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

resource "aws_network_interface" "test-ni" {
   subnet_id  = aws_subnet.test-subnet.id
   private_ips = ["10.0.11.77"]
   security_groups = [aws_security_group.test-sg.id]
   
}

resource "aws_eip" "test-eip"{

  vpc  = true
  network_interface = aws_network_interface.test-ni.id
  associate_with_private_ip = "10.0.11.77"
}