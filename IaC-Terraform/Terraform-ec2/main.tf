terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region = "eu-central-1"
}

module "vpc" {
  source  = "/Users/maureenbarasa/modules/services/vpc"
}


module "ecs-ec2" {
  source  = "/Users/maureenbarasa/modules/services/ecs-ec2"
}
