terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID"
  type        = string
}

resource "aws_instance" "linux_vm" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name = "Terraform-Linux-VM"
  }
}

output "instance_id" {
  value = aws_instance.linux_vm.id
}

output "private_ip" {
  value = aws_instance.linux_vm.private_ip
}

output "public_ip" {
  value = aws_instance.linux_vm.public_ip
}
