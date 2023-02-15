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

resource "aws_instance" "web-server-instance" {
  ami = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  tags = {
    Name = "HelloWorld"
  }
}
