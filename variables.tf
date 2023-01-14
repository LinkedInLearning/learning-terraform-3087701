variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter"{
  description = "name filter and owner for ami"

  type = object({
    name  = string
    owner = string
  }) 
  default={
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631"
  }
}

variable "environment"{
  description = "deployment environment"

  type = object ({
    name           = string
    network_prefix = string
  })
  default= {
    name            = dev
    network_prefix  = "10.0"
  }
}

variable "asg_min" {
  asg_min     = 1
  description = "minimum number of instances"
}
variable "asg_max"{
  asg_max     = 2
  description = "maximum number of instances"
}

