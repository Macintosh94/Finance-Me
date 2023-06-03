terraform{
         required_providers {
                 aws = {
                         source = "hashicorp/aws"
                         version = "~> 4.0"
                 }
         }
}

locals {
  vpc_id           = "vpc-09e7ff8aeb1ef8610"
  subnet_id        = "subnet-0325f173ed2ce59ad"
  ssh_user         = "ubuntu"
  key_name         = "AWS_Key"
  private_key_path = "/etc/ansible/AWS_Key.pem"
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

resource "aws_subnet" "test-subnet" {
   vpc_id = aws_vpc.test-subnet.id
   cidr_block = "10.0.0.0/16"
   availability_zone = "us-east-1c"

   tags = {
     Name = "Subnet1"

   }
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

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.test-server.public_ip
    }
  }
    
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.test-server.public_ip}, --private-key ${local.private_key_path} /etc/ansible/test-deployment.yaml"
  }

output "test-server_ip" {
  value = aws_instance.test-server.public_ip  
}