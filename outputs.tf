output "instance_ami" {
  value = aws_instance.blog.ami
}

output "instance_arn" {
  value = aws_instance.blog.arn
}

output "security_group_id" {
  value = aws_security_group.blog.id
}
