output "instance_ami" {
 value = aws_instance.blog
}

output "instance_arn" {
 value = aws_instance.blog.arn
