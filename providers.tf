terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Add a version constraint
    }
  }
}

provider "aws" {
  region = "us-west-2"
}