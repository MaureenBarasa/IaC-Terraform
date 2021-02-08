#Import values from VPC Module
module "VPC" {
  source  = "/Users/maureenbarasa/Desktop/XR3-Engine-Terraform/Modules/VPC"
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "xr3-engine-eks" {
  name     = "xr3-engine-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [module.VPC.VPC_private_subnet3_id,module.VPC.VPC_private_subnet4_id]
  }
  tags = {
     Name = "XR3-EKS-Cluster"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-tuto"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "xr3-eks-nodes" {
  cluster_name    = aws_eks_cluster.xr3-engine-eks.name
  node_group_name = "xr3-engine-eks-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [module.VPC.VPC_private_subnet1_id,module.VPC.VPC_private_subnet2_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
     Name = "xr3-engine-eks-nodes"
     createdBy = "MaureenBarasa"
     Project = "XR3-Engine"
     environment = "UAT"
   }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}