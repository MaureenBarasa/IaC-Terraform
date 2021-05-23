#The VPC
resource "aws_vpc" "SuperReality-VPC" {
   cidr_block = "10.0.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "SuperReality-Dev-VPC"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

#The Subnets
resource "aws_subnet" "SuperReality-PublicSub01" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.0.0/26"
   map_public_ip_on_launch = "true"
   availability_zone = "us-west-1b"
   tags = {
     Name = "SuperReality-PublicSub01"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_subnet" "SuperReality-PublicSub02" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.0.64/26"
   map_public_ip_on_launch = "true"
   availability_zone = "us-west-1c"
   tags = {
     Name = "SuperReality-PublicSub02"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_subnet" "SuperReality-PrivateSub01" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.1.0/25"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1b"
   tags = {
     Name = "SuperReality-PrivateSub01"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_subnet" "SuperReality-PrivateSub02" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.1.128/25"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1c"
   tags = {
     Name = "SuperReality-PrivateSub02"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_subnet" "SuperReality-PrivateSub03" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.2.0/25"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1b"
   tags = {
     Name = "SuperReality-PrivateSub03"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
resource "aws_subnet" "SuperReality-PrivateSub04" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   cidr_block = "10.0.2.128/25"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1c"
   tags = {
     Name = "SuperReality-PrivateSub04"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
#The Internet Gateway
resource "aws_internet_gateway" "SuperReality-IGW" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   tags = {
     Name = "SuperReality-IGW"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}
#The Elastic IP's
resource "aws_eip" "one" {
    vpc = true
}
resource "aws_eip" "two" {
    vpc = true
}

#The NAT Gateways
resource "aws_nat_gateway" "SuperReality-NAT-GW1" {
   allocation_id = "${aws_eip.one.id}"
   subnet_id = "${aws_subnet.SuperReality-PublicSub01.id}"
   depends_on = ["aws_internet_gateway.SuperReality-IGW"]
}

resource "aws_nat_gateway" "SuperReality-NAT-GW2" {
   allocation_id = "${aws_eip.two.id}"
   subnet_id = "${aws_subnet.SuperReality-PublicSub01.id}"
   depends_on = ["aws_internet_gateway.SuperReality-IGW"]
}

#The Public Route Table
resource "aws_route_table" "SuperReality-Public-RTB" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.SuperReality-IGW.id}"
   }
   tags = {
     Name = "SuperReality-Public-RTB"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }
}

# The Public Route Table Associations
resource "aws_route_table_association" "SuperReality-public-1b" {
   subnet_id = "${aws_subnet.SuperReality-PublicSub01.id}"
   route_table_id = "${aws_route_table.SuperReality-Public-RTB.id}"
}
resource "aws_route_table_association" "SuperReality-public-1c" {
   subnet_id = "${aws_subnet.SuperReality-PublicSub02.id}"
   route_table_id = "${aws_route_table.SuperReality-Public-RTB.id}"
}

#The first Private Route Tables
resource "aws_route_table" "SuperReality-Private01-RTB" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.SuperReality-NAT-GW1.id}"
   }
   tags = {
     Name = "SuperReality-Private01-RTB"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }

}

# The first Private Route Table Associations
resource "aws_route_table_association" "SuperReality-private1-1b" {
   subnet_id = "${aws_subnet.SuperReality-PrivateSub01.id}"
   route_table_id = "${aws_route_table.SuperReality-Private01-RTB.id}"
}

resource "aws_route_table_association" "SuperReality-private3-1b" {
   subnet_id = "${aws_subnet.SuperReality-PrivateSub03.id}"
   route_table_id = "${aws_route_table.SuperReality-Private01-RTB.id}"
}

#The Second Private Route Table 
resource "aws_route_table" "SuperReality-Private02-RTB" {
   vpc_id = "${aws_vpc.SuperReality-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.SuperReality-NAT-GW2.id}"
   }
   tags = {
     Name = "SuperReality-Private02-RTB"
     createdBy = "MaureenBarasa"
     Project = "SuperReality"
     Environment = "UAT"
   }

}

# The Second Private Route Table Associations
resource "aws_route_table_association" "SuperReality-private2-1c" {
   subnet_id = "${aws_subnet.SuperReality-PrivateSub02.id}"
   route_table_id = "${aws_route_table.SuperReality-Private02-RTB.id}"
}
resource "aws_route_table_association" "SuperReality-private4-1c" {
   subnet_id = "${aws_subnet.SuperReality-PrivateSub04.id}"
   route_table_id = "${aws_route_table.SuperReality-Private02-RTB.id}"
}

