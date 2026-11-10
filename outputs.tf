output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.web.arn
}

output "instance_ami" {
  description = "The AMI ID used by the instance"
  value       = aws_instance.web.ami
}

output "instance_public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.web.public_ip
}

output "instance_details" {
  description = "Complete instance details in a map"
  value = {
    id                = aws_instance.web.id
    arn               = aws_instance.web.arn
    public_ip         = aws_instance.web.public_ip
    instance_type     = aws_instance.web.instance_type
    availability_zone = aws_instance.web.availability_zone
  }
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.web_role.arn
}
