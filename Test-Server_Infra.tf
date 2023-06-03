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
  access_key = "AKIATVOIMA34MRX6I4EK"
  secret_key = "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"
}

resource "aws_instance" "test-server" {
  ami                         = "ami-053b0d53c279acc90"
  subnet_id                   = "subnet-0325f173ed2ce59ad"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = local.key_name

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
    command = "ansible-playbook  -i ${aws_instance.test-server.public_ip}, --private-key ${local.private_key_path} test-deployment.yaml"
  }
}