#Import values from VPC Module
module "VPC" {
  source  = "/Users/maureenbarasa/Desktop/SuperReality Terraform/Modules/VPC"
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
	ami = "ami-063d4ab14480ac177"
	instance_type = "t2.micro"
    key_name = "maureenaws"
    subnet_id = "${module.VPC.VPC_public_subnet1_id}"
    vpc_security_group_ids = [aws_security_group.bastion-dev-ec2-sg.id]
    monitoring = "true"
    iam_instance_profile = "${aws_iam_instance_profile.ssm_profile.id}"
    user_data = "${file("/Users/maureenbarasa/Desktop/SuperReality Terraform/install-ssm.sh")}"
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
  availability_zones      = ["eu-west-1a", "eu-west-1b"]
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
  subnets         = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id,module.VPC.VPC_public_subnet1_id,module.VPC.VPC_public_subnet2_id]

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

data "aws_security_group" "cluster" {
      id = module.eks.cluster_primary_security_group_id
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

resource "aws_launch_template" "gameservers-lt" {
  name = "gameservers-lt"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 40
    }
  }
  instance_type = "t3.small"
}

resource "aws_launch_template" "mainnode-lt" {
  name = "mainnode-lt"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
    }
  }
  instance_type = "t3.medium"
}

resource "aws_launch_template" "redis-lt" {
  name = "redis-lt"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
    }
  }
  instance_type = "t3.small"
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
  launch_template {
   name = aws_launch_template.mainnode-lt.name
   version = aws_launch_template.mainnode-lt.latest_version
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
    aws_launch_template.mainnode-lt,
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
  subnet_ids      = [module.VPC.VPC_public_subnet1_id,module.VPC.VPC_public_subnet2_id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  launch_template {
   name = aws_launch_template.gameservers-lt.name
   version = aws_launch_template.gameservers-lt.latest_version
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
    aws_launch_template.gameservers-lt,
    module.eks,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "SuperReality-eks-redis-nodes" {
  cluster_name    = local.cluster_name
  node_group_name = "SuperReality-dev-eks-redis-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  launch_template {
   name = aws_launch_template.redis-lt.name
   version = aws_launch_template.redis-lt.latest_version
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
    aws_launch_template.redis-lt,
    module.eks,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Import Ingress rules to SG1 created by EKS    
# SG Rule which you would like to add
resource "aws_security_group_rule" "rule1" {
    depends_on        = [module.eks]
    type              = "ingress"
    from_port         = 7000
    to_port           = 8000
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    
    security_group_id = module.eks.cluster_primary_security_group_id
}
    
# SG Rule which you would like to add
resource "aws_security_group_rule" "rule2" {
    depends_on        = [module.eks]
    type              = "ingress"
    from_port         = 7000
    to_port           = 8000
    protocol          = "udp"
    cidr_blocks       = ["0.0.0.0/0"]
    
    security_group_id = module.eks.cluster_primary_security_group_id
}

