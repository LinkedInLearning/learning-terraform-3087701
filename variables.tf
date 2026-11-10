variable "instance_type" {
  description = "Type of EC2 instance to provision"
  type        = string
  default     = "t3.nano"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "HelloWorld"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for the instance"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    ManagedBy = "Terraform"
  }
}
