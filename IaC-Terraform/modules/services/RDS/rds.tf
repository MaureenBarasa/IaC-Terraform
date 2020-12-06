module "vpc" {
  source  = "/Users/maureenbarasa/modules/services/vpc"
}
resource "aws_db_subnet_group" "test-sb-grp" {
  name       = "test-sb-grp"
  subnet_ids = [module.vpc.vpc_public_subnet1_id, module.vpc.vpc_public_subnet2_id]

  tags = {
	Name = "test-sb-grp"
    createdBy = "MaureenBarasa"
    Owner = "DevSecOps"	
    Project = "test-terraform"
	environment = "test"    
  }
}
resource "aws_db_parameter_group" "test-pr-grp" {
  name   = "test-pr-grp"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_security_group" "test-rds-sg" {
  name        = "test-rds-sg"
  description = "alb security group"
  vpc_id = "${module.vpc.vpc_id}"

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
     Name = "test-rds-sg"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_db_instance" "testrds" {
  allocated_storage    = 20 
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t3.micro"
  name                 = "testrds"
  username             = "admin"
  password             = "******"
  db_subnet_group_name = "${aws_db_subnet_group.test-sb-grp.id}"
  parameter_group_name = "${aws_db_parameter_group.test-pr-grp.id}"
  deletion_protection = "true"
  port = "3306"
  vpc_security_group_ids = [aws_security_group.test-rds-sg.id]
  tags = {
     Name = "testrds"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
