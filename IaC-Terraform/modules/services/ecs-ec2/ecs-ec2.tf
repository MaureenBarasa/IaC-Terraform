module "vpc" {
  source  = "/Users/maureenbarasa/modules/services/vpc"
}

#Instance Role
resource "aws_iam_role" "test_role" {
  name = "test-ecs-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "test-ecs-ec2"
    createdBy = "MaureenBarasa"
    Owner = "DevSecOps"
    Project = "test-terraform"
    environment = "test"
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test-ecs-ec2"
  role = "${aws_iam_role.test_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "test_attach1" {
  name       = "test-attachment1"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "test_attach2" {
  name       = "test-attachment2"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_policy_attachment" "test_attach3" {
  name       = "test-attachment3"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#ECS Cluster
resource "aws_ecs_cluster" "test-ecs-ec2" {
  name = "test-ecs-ec2"
  setting {
      name = "containerInsights"
      value = "enabled"
  }
	tags = {
		  Name = "test-ecs-ec2"
      createdBy = "MaureenBarasa"
      Owner = "DevSecOps"	
      Project = "test-terraform"
		environment = "test"
	}
}

#The Autoscaling Group
resource "aws_autoscaling_group" "test-ecs-asg-group" {
    name = "test-ecs-asg-group"
    max_size = 2
    min_size = 1
    desired_capacity = 1
    health_check_grace_period = 300
    launch_configuration = "${aws_launch_configuration.container-instance.id}"
    vpc_zone_identifier = [module.vpc.vpc_private_subnet1_id, module.vpc.vpc_private_subnet2_id]
}

#The launch Configuration
resource "aws_launch_configuration" "container-instance" {
    name = "test-ecs"
    image_id = "ami-07083d4e949ba5cf9"
    instance_type = "t2.micro"
    key_name = "test-key"
    security_groups = [module.vpc.vpc_ecs_security_group_id]
    user_data = "${file("/Users/maureenbarasa/modules/services/ecs-ec2/container-agent.sh")}"
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.id}"
    root_block_device {
        volume_size = 20
        volume_type = "gp2"
    }
}

