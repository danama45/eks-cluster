
variable "aws_priv_subnet1_id" {
  description = "private subnet id"
}

variable "aws_pub_subnet1_id" {
  description = "public subnet id"
}

variable "eks_cluster_name" {
  description = "The name of EKS cluster"
  type        = string
}

variable "eks_cluster_role_name" {
  description = "iam role for eks cluster"
  default     = "eks_cluster_role"
}

variable "eks_SG_name" {
  description = "security group name for eks cluster"
  default     = "eks_SG"
}
variable "vpc_id" {
  description = "vpc id for the eks cluster"
}

variable "node_group_name" {
  type        = string
  description = "The name of the EKS cluster nodegroup"
  default     = "eks_node_group"
}

variable "node_group_iam_role" {
  description = "Name of node group IAM role"
  default     = "Nodegroup_IAM_role"
}

variable "fargate_name" {
  description = "The nam of fargate profile"
  default     = "eks_fargate"
}

variable "namespace" {
  description = "The namespace to be used for the eks deployment"
  default     = "fargate-node"
}

variable "fargate_pod_role_name" {
  description = "The name of fargate pod execution role"
  default     = "fargate_pod_role"
}


variable "k8s_cluster_type" {
  description = "Can be set to `vanilla` or `eks`. If set to `eks`, the Kubernetes cluster will be assumed to be run on EKS which will make sure that the AWS IAM Service integration works as supposed to."
  type        = string
  default     = "eks"
}

variable "aws_iam_path_prefix" {
  description = "Prefix to be used for all AWS IAM objects."
  type        = string
  default     = ""
}

variable "aws_resource_name_prefix" {
  description = "A string to prefix any AWS resources created. This does not apply to K8s resources"
  type        = string
  default     = "k8s-"
}

variable "region" {
  description = "The current region"
}


