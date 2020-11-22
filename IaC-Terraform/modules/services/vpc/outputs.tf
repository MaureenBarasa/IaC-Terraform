output "vpc_public_subnet1" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.test-public-subnet-1.id}"
}

output "vpc_public_subnet2" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.test-public-subnet-2.id}"
}

output "vpc_private_subnet1_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.test-private-subnet-1.id}"
}

output "vpc_private_subnet2_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.test-private-subnet-2.id}"
}

output "vpc_security_group_id" {
  description = "ID of the VPC's security groups"
  value       = "${aws_security_group.test-ec2-sg.id}"
}

output "vpc_ecs_security_group_id" {
  description = "ID of the ECS security groups"
  value       = "${aws_security_group.test-ecs-ec2-sg.id}"
}

output "vpc_alb_security_group_id" {
  description = "ID of the ALB security groups"
  value       = "${aws_security_group.test-alb-sg.id}"
}

