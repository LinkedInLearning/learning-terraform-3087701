data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

module "blog_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0" # Use an appropriate version

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = {
    "Name" = "dev-vpc"
  }
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.micro"
  subnet_id     = element(module.blog_vpc.public_subnets, 0)

  vpc_security_group_ids = [module.blog_sg.this_security_group_id]

  tags = {
    Name = "Mohammed_EC2"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0" # Use an appropriate version

  name        = "blog_sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = module.blog_vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}
