variable "instance_type" {
  description = "Type of EC2 instance to provision"
  type        = string
  default     = "t3.micro"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"
  type = object({
    name   = string
    owners = list(string)
  })

  default = {
    name   = "al2023-ami-2023.*-x86_64"
    owners = ["amazon"]
  }
}

variable "environment" {
  description = "Deployment environment details"
  type = object({
    name           = string
    network_prefix = string
  })

  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}