module "vpc" {
  source  = "/Users/maureenbarasa/modules/services/vpc"
}

resource "aws_s3_bucket" "maureenalbs3" {
  bucket = "maureenalbs3"
  acl    = "private"

	tags = {
		Name = "maureenalbs3"
        createdBy = "MaureenBarasa"
        Owner = "DevSecOps"	
        Project = "test-terraform"
		environment = "test"
	}
}

resource "aws_lb" "test-alb" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.vpc.vpc_alb_security_group_id]
  subnets            = [module.vpc.vpc_public_subnet1_id, module.vpc.vpc_public_subnet2_id]

  enable_deletion_protection = true

  access_logs {
    bucket = "${aws_s3_bucket.maureenalbs3.id}"
    prefix  = "test-alb"
    enabled = true
  }

	tags = {
		Name = "test-alb"
        createdBy = "MaureenBarasa"
        Owner = "DevSecOps"	
        Project = "test-terraform"
		environment = "test"
	}
}
