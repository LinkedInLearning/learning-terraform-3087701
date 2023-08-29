variable "instance_type" {
 description = "Type of EC2 instance to provision"
 default     = "t3.nano"
}

variable "ami_filter" {
  description = "Name/owner Filter for AMI"

  type = object({
    name = string
    owner = string
  })

  default = {
    name = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631"
  }
}

variable "environment" {

  type = object({
    name = string
    cidr_prefix = string 
  })

  default = {
    name = "dev"
    cidr_prefix = "10.0"
  }
}

variable "min_size" {
  description = "Minimum number of EC2 nodes"
  default = 1
}

variable "max_size" {
  description = "Maximum number of EC2 nodes"
  default = 2
}