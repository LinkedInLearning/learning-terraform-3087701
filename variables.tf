#variable "instance_type" {
#  description = "Type of EC2 instance to provision"
#  default     = "t3.nano"
#}


variable "subnet_prv1" {
  description = "Private Subnet 1"
  default = "arn:aws:ec2:us-west-2:301721915996:subnet/subnet-0f4c5cc3e9b9b4dac"
}
