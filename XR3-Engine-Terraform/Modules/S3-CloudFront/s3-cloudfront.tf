#Import values from VPC Module
module "VPC" {
  source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/VPC"
}

#The origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "the XR3 engine cloudfront origin access identity"
}

#The S3 Bucket
resource "aws_s3_bucket" "xr3-engine-test" {
  bucket = "xr3-engine-test"
  acl    = "private"
  tags = {
     Name = "xr3-engine-test"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The S3 Bucket Policy
resource "aws_s3_bucket_policy" "xr3-engine-bucketpolicy" {
  bucket = "${aws_s3_bucket.xr3-engine-test.id}"

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
      "Resource": "arn:aws:s3:::xr3-engine-test/*"
    }
  ]
}
POLICY
}

locals {
  s3_origin_id = "xr3-engine-tests3origin"
}

#The Cloudfront Distribution
resource "aws_cloudfront_distribution" "xr3-engine-cf" {
  origin {
    domain_name = "${aws_s3_bucket.xr3-engine-test.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    compress = true
    viewer_protocol_policy = "allow-all"
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
