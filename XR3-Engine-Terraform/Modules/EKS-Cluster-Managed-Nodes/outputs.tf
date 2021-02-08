output "eks_cluster_endpoint" {
  value = aws_eks_cluster.xr3-engine-eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.xr3-engine-eks.certificate_authority 
}