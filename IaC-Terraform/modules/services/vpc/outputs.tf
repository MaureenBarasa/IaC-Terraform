output "vpc_public_subnet1" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.test-public-subnet-1.id}"
}

output "vpc_public_subnet2" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.test-public-subnet-2.id}"
}

output "vpc_security_group_id" {
  description = "IDs of the VPC's security groups"
  value       = "${aws_security_group.test-ec2-sg.id}"
}

