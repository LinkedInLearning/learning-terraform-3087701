resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}
