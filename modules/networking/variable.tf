variable "vpc_cidr" {
    description = "This is the cidr for the main eks cluster VPC"
    type = string
}

variable "private_cidr_block" {
    description = "This is the cidr for the main eks cluster private subnet A"
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "public_cidr_block" {
    description = "This is the cidr for the main eks cluster public subnet A"
    type = list(string)
    default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}

variable "vpc_name" {
    type = string
    description = "This is the name of the EKS cluster VPC"
}

variable "igw_name" {
    type = string
    description = "This is the name of the internet gateway for the eks cluster"
}

variable "public_az" {
    type = list(string)
    description = "These are the availabity zones for the public subnets"
    default = [ "ca-central-1a", "ca-central-1b" ]
}

variable "private_az" {
    type = list(string)
    description = "These are the availabity zones for the private subnets"
    default = [ "ca-central-1a", "ca-central-1d" ]
}