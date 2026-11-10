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

resource "aws_instance" "web" {
  ami                  = data.aws_ami.app_ami.id
  instance_type        = var.instance_type
  monitoring           = var.enable_monitoring
  iam_instance_profile = aws_iam_instance_profile.web_profile.name

  tags = merge(
    var.additional_tags,
    {
      Name        = var.instance_name
      Environment = var.environment
    }
  )

  depends_on = [aws_iam_role.web_role]
}

resource "aws_iam_role" "web_role" {
  name = "${var.instance_name}-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.additional_tags
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "${var.instance_name}-profile-${var.environment}"
  role = aws_iam_role.web_role.name
}
