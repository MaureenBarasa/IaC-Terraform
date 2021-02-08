#Import values from VPC Module
module "VPC" {
  source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/VPC"
}

#The DB subnet group
resource "aws_db_subnet_group" "xr3-rds-aurora-subnetgroup" {
  name       = "xr3-rds-aurora-subnetgroup"
  subnet_ids = [module.VPC.VPC_private_subnet3_id,module.VPC.VPC_private_subnet4_id]

  tags = {
	Name = "xr3-rds-aurora-subnetgroup"
    createdBy = "MaureenBarasa"
    Project = "XR3-Engine"
	environment = "UAT"    
  }
}

#The DB parameter group
resource "aws_db_parameter_group" "xr3-rds-aurora-parametergroup" {
  name   = "xr3-rds-aurora-parametergroup"
  family = "aurora-mysql5.7"
  tags = {
     Name = "xr3-rds-aurora-parametergroup"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The DB Cluster Parameter group
resource "aws_rds_cluster_parameter_group" "xr3-rds-aurora-clusterparametergroup" {
  name        = "xr3-rds-aurora-clusterparametergroup"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"
  tags = {
     Name = "xr3-rds-aurora-clusterparametergroup"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The DB security group
resource "aws_security_group" "xr3-rds-aurora-securitygroup" {
  name        = "xr3-rds-aurora-securitygroup"
  description = "alb security group"
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
     Name = "xr3-rds-aurora-securitygroup"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The DB cluster
resource "aws_rds_cluster" "xr3-aurora-rds-cluster" {
  cluster_identifier      = "xr3-aurora-rds-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7"
  availability_zones      = ["us-west-1a", "us-west-1b"]
  database_name           = "mydb"
  master_username         = "xr3engine"
  master_password         = "lovelyawsengine"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  port = "3306"
  deletion_protection = "false"
  db_subnet_group_name = "${aws_db_subnet_group.xr3-rds-aurora-subnetgroup.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.xr3-rds-aurora-clusterparametergroup.id}"
  vpc_security_group_ids = [aws_security_group.xr3-rds-aurora-securitygroup.id]
  storage_encrypted = "true"
  final_snapshot_identifier = "DELETE-ME"
  skip_final_snapshot = "true"
  enabled_cloudwatch_logs_exports = ["audit", "error"]
  tags = {
     Name = "xr3-aurora-rds-cluster"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The DB instance
resource "aws_rds_cluster_instance" "xr3-aurora-db-instance1" {
  count              = 1
  cluster_identifier = aws_rds_cluster.xr3-aurora-rds-cluster.id
  instance_class     = "db.t3.medium"
  engine             = "aurora-mysql"
  engine_version     = "5.7"
  db_subnet_group_name = "${aws_db_subnet_group.xr3-rds-aurora-subnetgroup.id}"
  db_parameter_group_name = "${aws_db_parameter_group.xr3-rds-aurora-parametergroup.id}"
}