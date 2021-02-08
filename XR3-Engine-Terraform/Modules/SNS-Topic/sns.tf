#The SNS Topic
resource "aws_sns_topic" "XR3_Engine_Updates" {
  name = "XR3_Engine_Updates"
   tags = {
     Name = "XR3_Engine_Updates"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}