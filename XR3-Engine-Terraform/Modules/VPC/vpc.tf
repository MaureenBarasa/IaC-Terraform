#The VPC
resource "aws_vpc" "XR3-VPC" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "XR3-VPC"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

#The Subnets
resource "aws_subnet" "XR3-PublicSub01" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.0.0/28"
   map_public_ip_on_launch = "true"
   availability_zone = "us-west-1a"
   tags = {
     Name = "XR3-PublicSub01"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}
resource "aws_subnet" "XR3-PublicSub02" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.0.16/28"
   map_public_ip_on_launch = "true"
   availability_zone = "us-west-1b"
   tags = {
     Name = "XR3-PublicSub02"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}
resource "aws_subnet" "XR3-PrivateSub01" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.1.0/26"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1a"
   tags = {
     Name = "XR3-PrivateSub01"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "test"
   }
}
resource "aws_subnet" "XR3-PrivateSub02" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.1.64/26"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1b"
   tags = {
     Name = "XR3-PrivateSub02"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "test"
   }
}
resource "aws_subnet" "XR3-PrivateSub03" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.1.128/26"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1a"
   tags = {
     Name = "XR3-PrivateSub03"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "test"
   }
}
resource "aws_subnet" "XR3-PrivateSub04" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   cidr_block = "192.168.1.192/26"
   map_public_ip_on_launch = "false"
   availability_zone = "us-west-1b"
   tags = {
     Name = "XR3-PrivateSub04"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}
#The Internet Gateway
resource "aws_internet_gateway" "XR3-IGW" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   tags = {
     Name = "XR3-IGW"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}
resource "aws_eip" "one" {
    vpc = true
}
resource "aws_eip" "two" {
    vpc = true
}
resource "aws_nat_gateway" "XR3-NAT-GW1" {
   allocation_id = "${aws_eip.one.id}"
   subnet_id = "${aws_subnet.XR3-PublicSub01.id}"
   depends_on = ["aws_internet_gateway.XR3-IGW"]
}

resource "aws_nat_gateway" "XR3-NAT-GW2" {
   allocation_id = "${aws_eip.two.id}"
   subnet_id = "${aws_subnet.XR3-PublicSub01.id}"
   depends_on = ["aws_internet_gateway.XR3-IGW"]
}

#The Public Route Table
resource "aws_route_table" "XR3-Public-RTB" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.XR3-IGW.id}"
   }
   tags = {
     Name = "XR3-Public-RTB"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
}

# The Public Route Table Associations
resource "aws_route_table_association" "XR3-public-1a" {
   subnet_id = "${aws_subnet.XR3-PublicSub01.id}"
   route_table_id = "${aws_route_table.XR3-Public-RTB.id}"
}
resource "aws_route_table_association" "XR3-public-1b" {
   subnet_id = "${aws_subnet.XR3-PublicSub02.id}"
   route_table_id = "${aws_route_table.XR3-Public-RTB.id}"
}

#The first Private Route Tables
resource "aws_route_table" "XR3-Private01-RTB" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.XR3-NAT-GW1.id}"
   }
   tags = {
     Name = "XR3-Private01-RTB"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }

}

# The first Private Route Table Associations
resource "aws_route_table_association" "XR3-private1-1a" {
   subnet_id = "${aws_subnet.XR3-PrivateSub01.id}"
   route_table_id = "${aws_route_table.XR3-Private01-RTB.id}"
}

resource "aws_route_table_association" "XR3-private3-1a" {
   subnet_id = "${aws_subnet.XR3-PrivateSub03.id}"
   route_table_id = "${aws_route_table.XR3-Private01-RTB.id}"
}

#The Second Private Route Table 
resource "aws_route_table" "XR3-Private02-RTB" {
   vpc_id = "${aws_vpc.XR3-VPC.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.XR3-NAT-GW2.id}"
   }
   tags = {
     Name = "XR3-Private02-RTB"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }

}

# The Second Private Route Table Associations
resource "aws_route_table_association" "XR3-private2-1b" {
   subnet_id = "${aws_subnet.XR3-PrivateSub02.id}"
   route_table_id = "${aws_route_table.XR3-Private02-RTB.id}"
}
resource "aws_route_table_association" "XR3-private4-1b" {
   subnet_id = "${aws_subnet.XR3-PrivateSub04.id}"
   route_table_id = "${aws_route_table.XR3-Private02-RTB.id}"
}
