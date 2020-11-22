#The VPC
resource "aws_vpc" "test-vpc" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "test-vpc"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}

#The Subnets
resource "aws_subnet" "test-public-subnet-1" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.0.0/28"
   map_public_ip_on_launch = "true"
   availability_zone = "eu-central-1a"
   tags = {
     Name = "test-public-subnet-1"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_subnet" "test-public-subnet-2" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.0.16/28"
   map_public_ip_on_launch = "true"
   availability_zone = "eu-central-1b"
   tags = {
     Name = "test-public-subnet-2"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_subnet" "test-private-subnet-1" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.1.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-central-1a"
   tags = {
     Name = "test-private-subnet-1"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_subnet" "test-private-subnet-2" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.2.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-central-1b"
   tags = {
     Name = "test-private-subnet-2"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_subnet" "test-private-subnet-3" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.3.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-central-1a"
   tags = {
     Name = "test-private-subnet-3"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_subnet" "test-private-subnet-4" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   cidr_block = "192.168.4.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "eu-central-1b"
   tags = {
     Name = "test-private-subnet-4"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
#The Internet Gateway
resource "aws_internet_gateway" "test-igw" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   tags = {
     Name = "test-igw"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}

resource "aws_nat_gateway" "test-nat-gw1" {
   allocation_id = "eipalloc-099f0604ed5230df8"
   subnet_id = "${aws_subnet.test-public-subnet-1.id}"
   depends_on = ["aws_internet_gateway.test-igw"]
}

resource "aws_nat_gateway" "test-nat-gw2" {
   allocation_id = "eipalloc-0957dc41fb157bbc2"
   subnet_id = "${aws_subnet.test-public-subnet-2.id}"
   depends_on = ["aws_internet_gateway.test-igw"]
}

#The Public Route Table
resource "aws_route_table" "test-public-rtb" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.test-igw.id}"
   }
   tags = {
     Name = "test-public-rtb"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}

# The Public Route Table Associations
resource "aws_route_table_association" "test-public-1a" {
   subnet_id = "${aws_subnet.test-public-subnet-1.id}"
   route_table_id = "${aws_route_table.test-public-rtb.id}"
}
resource "aws_route_table_association" "test-public-1b" {
   subnet_id = "${aws_subnet.test-public-subnet-2.id}"
   route_table_id = "${aws_route_table.test-public-rtb.id}"
}

#The first Private Route Tables
resource "aws_route_table" "test-private1-rtb" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.test-nat-gw1.id}"
   }
   tags = {
     Name = "test-private1-rtb"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     costCenter = "91204"
     environment = "test"
   }

}

# The first Private Route Table Associations
resource "aws_route_table_association" "test-private1-1a" {
   subnet_id = "${aws_subnet.test-private-subnet-1.id}"
   route_table_id = "${aws_route_table.test-private1-rtb.id}"
}

resource "aws_route_table_association" "test-private3-1a" {
   subnet_id = "${aws_subnet.test-private-subnet-3.id}"
   route_table_id = "${aws_route_table.test-private1-rtb.id}"
}

#The Second Private Route Table 
resource "aws_route_table" "test-private2-rtb" {
   vpc_id = "${aws_vpc.test-vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.test-nat-gw2.id}"
   }
   tags = {
     Name = "test-private2-rtb"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }

}

# The Second Private Route Table Associations
resource "aws_route_table_association" "test-private1-1b" {
   subnet_id = "${aws_subnet.test-private-subnet-2.id}"
   route_table_id = "${aws_route_table.test-private2-rtb.id}"
}
resource "aws_route_table_association" "test-private2-1b" {
   subnet_id = "${aws_subnet.test-private-subnet-4.id}"
   route_table_id = "${aws_route_table.test-private2-rtb.id}"
}

#The Security Groups
resource "aws_security_group" "test-ec2-sg" {
  name        = "test-ec2-sg"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.test-vpc.id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["42.54.23.12/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "test-ec2-sg"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_security_group" "test-ecs-ec2-sg" {
  name        = "test-ecs-ec2-sg"
  description = "ecs cluster security group"
  vpc_id = "${aws_vpc.test-vpc.id}"

  ingress {
    description = "ssh"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["42.54.23.12/32"]
  }

  ingress {
    description = "ssh"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["42.54.23.12/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "test-ecs-ec2-sg"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
resource "aws_security_group" "test-alb-sg" {
  name        = "test-alb-sg"
  description = "alb security group"
  vpc_id = "${aws_vpc.test-vpc.id}"

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["42.54.23.12/32"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["42.54.23.12/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "test-alb-sg"
     createdBy = "MaureenBarasa"
     Owner = "DevSecOps"
     Project = "test-terraform"
     environment = "test"
   }
}
