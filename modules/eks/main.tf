#Configuration for eks cluster

resource "aws_eks_cluster" "Cali-eks" {
  name                      = var.eks_cluster_name
  enabled_cluster_log_types = ["api", "audit"]
  role_arn                  = aws_iam_role.eks_cluster_iam_role.arn
  vpc_config {
    subnet_ids = concat(var.aws_priv_subnet1_id, var.aws_pub_subnet1_id)
    security_group_ids        = [aws_security_group.eks_SG.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.cloudwatch_log_group
  ]
}

resource "aws_iam_role" "eks_cluster_iam_role" {
  name = var.eks_cluster_role_name

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
  role       = aws_iam_role.eks_cluster_iam_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_iam_role.name
}
# output "endpoint" {
#   value = aws_eks_cluster.example.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.example.certificate_authority[0].data
# }

#security Group for the eks cluster

resource "aws_security_group" "eks_SG" {
  name        = var.eks_SG_name
  description = "Allow http/Https traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_http"
  }
}

# iam policies for the cloudwatch log group

resource "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name   = "AmazonEKSClusterCloudWatchMetricsPolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role       = aws_iam_role.eks_cluster_iam_role.name
}
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 7
}

# node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.Cali-eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group_iam_role.arn
  subnet_ids      = concat(var.aws_priv_subnet1_id)
  instance_types  = ["t2.micro"]
  ami_type        = "AL2_x86_64"

  scaling_config {
    desired_size = 4
    max_size     = 10
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.alem-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.alem-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.alem-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# node group IAM role
resource "aws_iam_role" "node_group_iam_role" {
  name = var.node_group_iam_role

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "alem-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "alem-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "alem-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_iam_role.name
}

# Fargate profile

resource "aws_eks_fargate_profile" "alem_fargate_eks" {
  cluster_name           = aws_eks_cluster.Cali-eks.name
  fargate_profile_name   = var.fargate_name
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = concat(var.aws_priv_subnet1_id)

  selector {
    namespace = var.namespace
  }
}

# EKS fargate pod execution role
resource "aws_iam_role" "fargate_pod_execution_role" {
  name = var.fargate_pod_role_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "alem-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

# created a name space
resource "kubernetes_namespace" "fargate_namespace" {
  metadata {
    name = var.namespace
  }
}
