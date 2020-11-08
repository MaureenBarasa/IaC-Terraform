module "vpc" {
  source  = "/Users/maureenbarasa/modules/services/vpc"
}

#Instance Role
resource "aws_iam_role" "test_role" {
  name = "test-ssm-ec2"
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
    Name = "test-ssm-ec2"
    createdBy = "MaureenBarasa"
    Owner = "DevSecOps"
    Project = "test-terraform"
    environment = "test"
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test-ssm-ec2"
  role = "${aws_iam_role.test_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "test_attach1" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "test_attach2" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#EC2 Instance
resource "aws_instance" "test-ec2" {
	ami = "ami-00a205cb8e06c3c4e"
	instance_type = "t2.micro"
    key_name = "test-key"
    subnet_id = "${module.vpc.vpc_public_subnet1}"
    vpc_security_group_ids = [module.vpc.vpc_security_group_id]
    monitoring = "true"
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.id}"
    user_data = "${file("/Users/maureenbarasa/modules/services/ec2/install-ssm.sh")}"
	tags = {
		Name = "test-ec2"
        createdBy = "MaureenBarasa"
        Owner = "DevSecOps"	
        Project = "test-terraform"
		environment = "test"
	}
}