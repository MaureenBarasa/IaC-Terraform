output "Aurora-RDS_auroradb_id" {
  description = "The Public Hosted Zone ID"
  value       = "${aws_rds_cluster.xr3-aurora-rds-cluster.id}"
}