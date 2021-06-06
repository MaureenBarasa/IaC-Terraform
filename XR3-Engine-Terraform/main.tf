terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  required_version = "~> 0.14"
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region =  var.AWS_REGION
  
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "s3bucket" {
  source = "./XR3-Engine-Terraform/Modules/S3"
  #provider = "aws.us-east-1"
  bucket_region = "us-east-1"
  bucket_name = "dev-superreality"
}

module "SuperReality-Env" {
  source  = "./XR3-Engine-Terraform/Modules/SUPERREALITY"
}
