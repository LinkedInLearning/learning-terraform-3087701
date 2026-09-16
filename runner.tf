resource "tls_private_key" "lab_runner_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "lab_runner" {
  key_name   = "Lab-Terraform-Runner-Key"
  public_key = tls_private_key.lab_runner_ssh.public_key_openssh
}

resource "aws_instance" "lab_runner" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.lab_runner.key_name
  vpc_security_group_ids = [module.blog_sg.security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y yum-utils unzip

    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y terraform

    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
    dnf install -y azure-cli
  EOF

  tags = {
    Name = "Lab-Terraform-Runner"
  }
}

output "lab_runner_public_ip" {
  value = aws_instance.lab_runner.public_ip
}

output "lab_runner_ssh_private_key" {
  value     = tls_private_key.lab_runner_ssh.private_key_pem
  sensitive = true
}
