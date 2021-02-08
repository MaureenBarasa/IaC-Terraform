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
  region = "us-west-1"
}

module "VPC" {
  source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/VPC"
}

#module "Route53-HostedZone" {
  #source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/Route53-HostedZone"
#}

#module "SNS-Topic" {
  #source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/SNS-Topic"
#}

#module "Aurora-RDS" {
  #source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/Aurora-RDS"
#}

#module "S3-CloudFront" {
  #source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/S3-CloudFront"
#}

module "EKS-Cluster-Managed-Nodes" {
  source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/EKS-Cluster-Managed-Nodes"
}
