data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] 
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["us-west-2a","us-west-2b","us-west-2c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]


  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id  = module.blog_vpc.vpc_id
  name    = "${var.environment.name}-blog"
  ingress_rules = ["https-443-tcp","http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.environment.name}-blog-alb"
  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets

  security_groups = [module.blog_sg.security_group_id]

  listeners = {
    blog-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_arn = aws_lb_target_group.blog.arn
      }
    }
  }

  tags = {
    Environment = var.environment.name
  }
}

resource "aws_lb_target_group" "blog" {
  name     = "${var.environment.name}-blog"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.blog_vpc.vpc_id
}

module "blog_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.2.1"
  name = "${var.environment.name}-blog"

  min_size = var.min_size
  max_size = var.max_size

  vpc_zone_identifier = module.blog_vpc.public_subnets

  launch_template_name = "${var.environment.name}-blog"
  security_groups = [module.blog_sg.security_group_id]
  instance_type   = var.instance_type
  image_id        = data.aws_ami.app_ami.id

  traffic_source_attachments = {
    "${var.environment.name}-blog_alb" = {
      traffic_source_identifier = aws_lb_target_group.blog.arn
    }
  }

}
