#Import values from VPC Module
module "VPC" {
  source  = "./XR3-Engine-Terraform/Modules/VPC"
}

locals {
  cluster_name = "SuperReality-dev-eks-cluster"
}

#THE ROUTE 53 HOSTED ZONES
resource "aws_route53_zone" "static" {
  name = "static.superreality.com"
  tags = {
     Name = "static.superreality.com"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_route53_zone" "dev" {
  name = "dev.superreality.com"
  tags = {
     Name = "dev.superreality.com"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#S3 AND CLOUDFRONT
#The origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "the SuperReality dev cloudfront origin access identity"
}

#The S3 Bucket
resource "aws_s3_bucket" "SuperReality" {
  bucket = "dev-superreality"
  acl    = "private"
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
      "Resource": "arn:aws:s3:::dev-superreality/*"
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

#SNS TOPIC
#The SNS Topic
resource "aws_sns_topic" "SuperReality_Engine_Updates" {
  name = "SuperReality_Dev_Updates"
   tags = {
     Name = "SuperReality_Dev_Updates"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#BASTION INSTANCE
#instance role
resource "aws_iam_role" "ssm_role" {
  name = "ssm-dev-ec2"
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
    Name = "ssm-dev-ec2"
    createdBy = "MaureenBarasa"
    Project = "SuperReality"
    Environment = "UAT"
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-dev-ec2"
  role = "${aws_iam_role.ssm_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "attach1" {
  name       = "ssm1-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "attach2" {
  name       = "ssm2-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#The bastion instance security group
resource "aws_security_group" "bastion-dev-ec2-sg" {
  name        = "bastion-dev-ec2-sg"
  description = "Allow TLS inbound traffic"
  vpc_id = "${module.VPC.VPC_vpc_id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "bastion-dev-ec2-sg"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#ec2 Instance
resource "aws_instance" "SuperReality-dev-bastion" {
	ami = "ami-04468e03c37242e1e"
	instance_type = "t2.micro"
    key_name = "gamegenXr3"
    subnet_id = "${module.VPC.VPC_public_subnet1_id}"
    vpc_security_group_ids = [aws_security_group.bastion-dev-ec2-sg.id]
    monitoring = "true"
    iam_instance_profile = "${aws_iam_instance_profile.ssm_profile.id}"
    user_data = "${file("./XR3-Engine-Terraform/install-ssm.sh")}"
	tags = {
		    Name = "SuperReality-dev-bastion"
        createdBy = "MaureenBarasa"
        Project = "SuperReality"
		    Environment = "UAT"
	}
}

#DB CLUSTER AND INSTANCE
#The DB subnet group
resource "aws_db_subnet_group" "SuperReality-rds-aurora-subnetgroup" {
  name       = "superreality-rds-dev-aurora-subnetgroup"
  subnet_ids = [module.VPC.VPC_private_subnet3_id,module.VPC.VPC_private_subnet4_id]

  tags = {
	Name = "superreality-rds-dev-aurora-subnetgroup"
    createdBy = "MaureenBarasa"
    Project = "SuperReality"
	Environment = "UAT"    
  }
}

#The DB parameter group
resource "aws_db_parameter_group" "SuperReality-rds-aurora-parametergroup" {
  name   = "superreality-rds-dev-aurora-parametergroup"
  family = "aurora-mysql5.7"
  tags = {
     Name = "superreality-rds-dev-aurora-parametergroup"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The DB Cluster Parameter group
resource "aws_rds_cluster_parameter_group" "SuperReality-rds-aurora-clusterparametergroup" {
  name        = "superreality-rds-dev-aurora-clusterparametergroup"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"
  tags = {
     Name = "superreality-rds-dev-aurora-clusterparametergroup"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The DB security group
resource "aws_security_group" "SuperReality-rds-aurora-securitygroup" {
  name        = "superreality-rds-dev-aurora-securitygroup"
  description = "rds dev security group"
  vpc_id = "${module.VPC.VPC_vpc_id}"

  ingress {
    description = "rds access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
     Name = "superreality-rds-dev-aurora-securitygroup"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The DB cluster
resource "aws_rds_cluster" "SuperReality-aurora-rds-cluster" {
  cluster_identifier      = "superreality-aurora-rds-dev-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7"
  availability_zones      = ["us-west-1b", "us-west-1c"]
  database_name           = "mydb"
  master_username         = "SuperRealityengine"
  master_password         = "var.db_root_password"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  port = "3306"
  deletion_protection = "false"
  db_subnet_group_name = "${aws_db_subnet_group.SuperReality-rds-aurora-subnetgroup.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.SuperReality-rds-aurora-clusterparametergroup.id}"
  vpc_security_group_ids = [aws_security_group.SuperReality-rds-aurora-securitygroup.id]
  storage_encrypted = "true"
  final_snapshot_identifier = "DELETE-ME"
  skip_final_snapshot = "true"
  enabled_cloudwatch_logs_exports = ["audit", "error"]
  tags = {
     Name = "SuperReality-aurora-rds-dev-cluster"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The DB instance
resource "aws_rds_cluster_instance" "SuperReality-aurora-db-instance1" {
  count              = 1
  identifier         = "aurora-dev-cluster-mysql-instance1"
  cluster_identifier = "${aws_rds_cluster.SuperReality-aurora-rds-cluster.id}"
  instance_class     = "db.t3.medium"
  engine             = "aurora-mysql"
  engine_version     = "5.7"
  db_subnet_group_name = "${aws_db_subnet_group.SuperReality-rds-aurora-subnetgroup.id}"
  db_parameter_group_name = "${aws_db_parameter_group.SuperReality-rds-aurora-parametergroup.id}"
}

module "db_provisioner" {
  source  = "aleks-fofanov/rds-lambda-db-provisioner/aws"
  depends_on = [
    aws_rds_cluster_instance.SuperReality-aurora-db-instance1,
  ]
  version = "~> 2.0"
    
    #source    = "git::https://github.com/aleks-fofanov/terraform-aws-rds-lambda-db-provisioner.git?ref=master"
  name      = "stack"
  namespace = "cp"
  stage     = "prod"

  db_instance_id                = "aurora-dev-cluster-mysql-instance1"
  db_instance_security_group_id = "${aws_security_group.SuperReality-rds-aurora-securitygroup.id}"
  db_master_password            = "var.db_root_password"

  db_name          = "SRDB"
  db_user          = "SRDB"
  db_user_password = "var.db_user_password"

  vpc_config = {
      vpc_id             = "${module.VPC.VPC_vpc_id}"
      subnet_ids         = [module.VPC.VPC_private_subnet3_id,module.VPC.VPC_private_subnet4_id]
      security_group_ids = [aws_security_group.SuperReality-rds-aurora-securitygroup.id]
    }
  }

#EKS
#eks cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id]

  tags = {
    Environment = "UAT"
    createdBy  = "Maureen Barasa"
    Name   = "SuperReality-dev-eks-cluster"
    Project = "SuperReality"
  }

  vpc_id = "${module.VPC.VPC_vpc_id}"
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-tuto"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "SuperReality-eks-nodes" {
  cluster_name    = local.cluster_name
  node_group_name = "SuperReality-dev-eks-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id]

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 4
  }
  tags = {
     Name = "SuperReality-dev-eks-nodes"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "SuperReality-eks-gameservers-nodes" {
  cluster_name    = local.cluster_name
  node_group_name = "SuperReality-dev-eks-gameservers-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  tags = {
     Name = "SuperReality-dev-eks-gameservers-nodes"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     environment = "UAT"
   }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}



