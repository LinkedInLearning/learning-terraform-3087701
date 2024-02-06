data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}
#AWS Instance Type. 
resource "aws_instance" "Blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

vpc_security_group_ids = [aws_security_group.blog.id]

  tags = {
    Name = "Learning Terraform"
  }
}

data "aws_vpc" "default" {
default = true
}

resouce "aws_security_group" "blog"
name        = "blog"
description = "Allow HTTP and HTTPS in. Allow everything out"

VPC_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_In"{
type        = "ingress"
from_port   = 80
to_port     = 80
protocol    = "tcp"
CIDR_Blocks = ["0.0.0.0/0"]

security_group_id =  aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_http_In"{
type        = "ingress"
from_port   = 443
to_port     = 443
protocol    = "tcp"
CIDR_Blocks = ["0.0.0.0/0"]

security_group_id =  aws_security_group.blog.id
}

resource "aws_security_group_rule" "Blog_everything_out"{
type        = "egress"
from_port   = 0
to_port     = 0
protocol    = "-1"
CIDR_Blocks = ["0.0.0.0/0"]

security_group_id =  aws_security_group.blog.id
}
