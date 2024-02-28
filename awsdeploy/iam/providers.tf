terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

variable "AWS_PROFILE" {
  type = string
  default = "defaulf"
}

variable "ENVIRONMENT" {
  type = string
  default = "prod"
}

provider "aws" {
  region = "ap-south-1"
  profile = var.AWS_PROFILE
}

terraform {
  backend "s3" {}
}