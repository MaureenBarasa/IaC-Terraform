output "ecs-fargate" {
  description = "The ECS fargate cluster"
  value       = "${aws_ecs_cluster.test-fargate.id}"
}
