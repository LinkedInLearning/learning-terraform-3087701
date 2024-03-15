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

  owners = ["979382823631"]  # Bitnami
}

module "blog_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"  # Replace with the actual version number

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Terraform"   = "true"
    "Environment" = "dev"
  }
}


module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "blog-security-group"
  description = "Security group for the blog application with HTTP and HTTPS access"
  vpc_id      = module.blog_vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  egress_rules  = ["all-all"]
}

resource "aws_instance" "blog" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.blog_sg.this_security_group_id]
  subnet_id              = element(module.blog_vpc.public_subnets, 0)

  tags = {
    Name = "Mohammed_EC2"
  }
}
