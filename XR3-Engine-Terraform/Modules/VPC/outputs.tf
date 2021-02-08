output "VPC_vpc_id" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_vpc.XR3-VPC.id}"
}

output "VPC_public_subnet1_id" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.XR3-PublicSub01.id}"
}

output "VPC_public_subnet2_id" {
  description = "IDs of the VPC's public subnets"
  value       = "${aws_subnet.XR3-PublicSub02.id}"
}

output "VPC_private_subnet1_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.XR3-PrivateSub01.id}"
}

output "VPC_private_subnet2_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.XR3-PrivateSub02.id}"
}

output "VPC_private_subnet3_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.XR3-PrivateSub03.id}"
}

output "VPC_private_subnet4_id" {
  description = "ID of the VPC's private subnets"
  value       = "${aws_subnet.XR3-PrivateSub04.id}"
}


