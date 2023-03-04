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

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.app_ami.id
#   instance_type = var.instance_type
  
#   vpc_security_group_ids = [module.blog_sg.security_group_id]

#   tags = {
#     Name = "HelloWorld"
#   }
# }
  
  module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.1"
  # insert the 1 required variable here
  name = "blog"
  min_size = 1
  max_size = 2
    
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns = module.blog_alb.target_group_arns
  security_groups   = [module.blog_sg.security_group_id]
  
  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}
  
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.blog_sg.security_group_id]

#   access_logs = {
#     bucket = "my-alb-logs"
#   }

  target_groups = [
    {
      name_prefix      = "blog-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = "aws_instance.blog.id"
          port = 80
        }
      }
   }
  ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "HTTPS"
#       certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
#       target_group_index = 0
#     }
#   ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
  }
}
    
      

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"
  name = "blog_new"
  
  vpc_id = module.vpc.public_subnets[0]
  
  ingress_rules = ["http-80-tcp", "https-8443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
  
  
# resource "aws_security_group" "blog"{
#   name        = "blog"
#   description = "Allow http and https in. Allow everything out"
  
#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_security_group_rule" "blog_http_in" {
#   type = "ingress"
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
  
#   security_group_id = aws_security_group.blog.id
# }
  
# resource "aws_security_group_rule" "blog_https_in" {
#   type = "ingress"
#   from_port = 443
#   to_port = 443
#   protocol  ="tcp"
#   cidr_blocks = ["0.0.0.0/0"]
  
#   security_group_id = aws_security_group.blog.id
# }

  
# resource "aws_security_group_rule" "blog_everything_out" {
#   type = "egress"
#   from_port = 0
#   to_port = 0
#   protocol  = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
  
#   security_group_id = aws_security_group.blog.id
# }
