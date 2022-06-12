variable "vpc_cidr" {
  description = "This is the cidr for the main eks cluster VPC"
  type        = string
}

variable "vpc_name" {
  type        = string
  description = "This is the name of the EKS cluster VPC"
}

variable "igw_name" {
  type        = string
  description = "This is the name of the internet gateway for the eks cluster"
}

variable "eks_cluster_name" {
  description = "The name of EKS cluster"
  type        = string
}

variable "region" {
  description = "The current region"
}


# variable "vpc_id" {
#   description = "vpc id for the eks cluster"
# }

# variable "aws_priv_subnet1_id" {
#   description = "private subnet id"
# }

# variable "aws_pub_subnet1_id" {
#   description = "public subnet id"
# }
