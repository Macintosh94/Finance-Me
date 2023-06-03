terraform{
         required_providers {
                 aws = {
                         source = "hashicorp/aws"
                         version = "~> 4.0"
                 }
         }
}

variable "ansible" {}

# Configure Providers

provider "aws" {
  region  = "us-east-1"
  access_key = "AKIATVOIMA34MRX6I4EK"
  secret_key = "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"

}

# Deploy Ec2 instances

resource "aws_instance" "test-server"{
        ami = "ami-053b0d53c279acc90"
        key_name = "AWS_Key"
        instance_type = "t2.micro"
        tags = {
        Name = "Test-Server"
        }
}

resource "aws_instance" "prod-server"{
        ami = "ami-053b0d53c279acc90"
        key_name = "AWS_Key"
        instance_type = "t2.micro"
        tags = {
        Name = "Prod-Server"
        }
}
resource "null_resource" "localinventorynull01" {
         triggers = {
                 mytest = timestamp()
         }
        
         provisioner "local-exec" {
             command = "echo ${aws_instance.test-server.tags.Name} ansible_host=${aws_instance.test-server.public_ip} ansible_user=ec2-user>> inventory"

           }

 
         depends_on = [

                          aws_instance.test-server
                          ]
          }

resource "null_resource" "localinventorynull02" {
         triggers = {
                 mytest = timestamp()
         }
        
         provisioner "local-exec" {
             command = "echo ${aws_instance.prod-server.tags.Name} ansible_host=${aws_instance.prod-server.public_ip} ansible_user=ec2-user>> inventory"

           }

 
         depends_on = [

                          null_resource.localinventorynull01
                          ]
          }

resource "null_resource" "mydynamicinventory" {

        triggers = {
                mytest = timestamp()
        }

        provisioner "local-exec" {
            command = "scp inventory ubuntu@54.89.174.78:/tmp/"
  
          }
        depends_on = [
                       
                        null_resource.localinventorynull02 , null_resource.localinventorynull01
                        ]
}

resource  "null_resource"  "ssh3" {

	triggers = {
		mytest = timestamp()
	}

	connection {
	    type     = "ssh"
	    user     = "ec2-user"
	    private_key = "/home/ubuntu/AWS_Key.pem"
	    host     = var.ansible
	  }

	provisioner "remote-exec" {
	    inline = [
              "sudo chmod 777 /tmp/inventory",
              "sudo mv /tmp/inventory /root/ansible/inventory",
	    ]
	  }
}



