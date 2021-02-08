#The Public Hosted Zone
resource "aws_route53_zone" "primary" {
  name = "testxr3engine.com"
  tags = {
     Name = "testxr3engine.com"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}