terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
    }
  }
}

provider "hashicorp/aws" {
  region  = "us-west-2"
}
