output "ecs-ec2" {
  description = "The ECS fargate cluster"
  value       = "${aws_ecs_cluster.test-ecs-ec2.id}"
}
