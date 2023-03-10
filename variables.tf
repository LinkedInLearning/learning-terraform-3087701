variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"

  type = object({
    name  = string
    owner = string
  })

  default = {
    name   = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owners = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "Developement Environment"

  type = object ({
    name            = string
    network_prefix  = string 
  })
  default = {
    name = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_min_size" {
  description = "Minumum number of instances in the ASG"
  default = 1
}
variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  default = 2
}
