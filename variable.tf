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