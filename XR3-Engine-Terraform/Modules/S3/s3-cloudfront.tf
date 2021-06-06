provider "aws" {
  alias = "region"
  region = "us-east-1"
}

#S3 AND CLOUDFRONT
#The origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "the SuperReality dev cloudfront origin access identity"
}

#The S3 Bucket
variable bucket_region {}
variable bucket_name {}
resource "aws_s3_bucket" "SuperReality" {
   provider = aws.region
   bucket = var.bucket_name
   acl = "private"
  tags = {
     Name = "dev-superreality"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The S3 Bucket Policy
resource "aws_s3_bucket_policy" "SuperReality-bucketpolicy" {
  bucket = "${aws_s3_bucket.SuperReality.id}"
  provider = aws.region
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        },  
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.SuperReality.arn}/*"
    }
  ]
}
POLICY
}

locals {
  s3_origin_id = "SuperReality-devs3origin"
}

#The Cloudfront Distribution
resource "aws_cloudfront_distribution" "SuperReality-dev-cf" {
  origin {
    domain_name = "${aws_s3_bucket.SuperReality.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    compress = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
