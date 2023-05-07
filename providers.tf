terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}
