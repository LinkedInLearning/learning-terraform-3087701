data "aws_ami" "app_ami" {
  most_recent = true
  owners      = var.ami_filter.owners

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "web_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

 name = "${var.environment.name}-web-vpc"
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  private_subnets = [
    "${var.environment.network_prefix}.1.0/24",
    "${var.environment.network_prefix}.2.0/24",
    "${var.environment.network_prefix}.3.0/24"
  ]

  public_subnets = [
    "${var.environment.network_prefix}.101.0/24",
    "${var.environment.network_prefix}.102.0/24",
    "${var.environment.network_prefix}.103.0/24"
  ]

  map_public_ip_on_launch = true

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = var.environment.name
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "${var.environment.name}-web-alb"
  load_balancer_type = "application"

  vpc_id  = module.web_vpc.vpc_id
  subnets = module.web_vpc.public_subnets

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "Allow HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web-instance"
      }
    }
  }

  target_groups = {
    web-instance = {
      name_prefix       = "web"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        matcher             = "200"
      }
    }
  }

  tags = {
    Environment = var.environment.name
    Project     = "Terraform-Learning"
  }
}

resource "aws_security_group" "web_instance_sg" {
  name_prefix = "web-instance-sg-"
  description = "Allow HTTP traffic from ALB to EC2"
  vpc_id      = module.web_vpc.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment.name}-web-instance-sg"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.2.1"

  name = "${var.environment.name}-web-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = module.web_vpc.public_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template_name        = "web-asg-template"
  launch_template_description = "Launch template for web ASG"
  update_default_version      = true

  image_id        = data.aws_ami.app_ami.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web_instance_sg.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from Terraform Auto Scaling behind ALB" > /var/www/html/index.html
EOF
  )

traffic_source_attachments = {
  web_alb = {
    traffic_source_identifier = module.alb.target_groups["web-instance"].arn
    traffic_source_type       = "elbv2"
  }
}

  tags = {
    Environment = var.environment.name
    Project     = "Terraform-Learning"
  }
}