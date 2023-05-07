terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
    }
  }
}

provider "registry.terraform.io/hashicorp/aws" {
  region  = "us-west-2"
}
