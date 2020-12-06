output "rds_db_instance_id" {
  description = "the rds db instance"
  value       = "${aws_db_instance.testrds.id}"
}

output "rds_subnet_group_id" {
  description = "the rds subnet group"
  value       = "${aws_db_subnet_group.test-sb-grp.id}"
}

output "rds_parameter_group_id" {
  description = "the rds parameter group"
  value       = "${aws_db_parameter_group.test-pr-grp.id}"
}
