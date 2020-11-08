resource "aws_ecs_cluster" "test-fargate" {
    name = "test-fargate-ecs"
    setting {
        name = "containerInsights"
        value = "enabled"
    }
	tags = {
		Name = "test-fargate-ecs"
        createdBy = "MaureenBarasa"
        Owner = "DevSecOps"	
        Project = "test-terraform"
		environment = "test"
	}
}
