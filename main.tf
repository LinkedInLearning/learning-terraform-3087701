data "aws_ami" "app_ami" {
  most_recent = true
  include_deprecated = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}
