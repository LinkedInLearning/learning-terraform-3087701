output "instance_ami" {
  value = data.aws_ami.app_ami.id
}

output "instance_arn" {
  value = aws_instance.blog.arn
}

