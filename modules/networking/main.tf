# Local variables
locals {
  private_subnet_name = "private_subnet"
  public_subnet_name = "public_subnet"
}

# VPC for EKS cluster
resource "aws_vpc" "eks" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
    Env  = "Prod"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks.id

  tags = {
    Name = var.igw_name
  }
}

# Private subnet for EKS VPC
resource "aws_subnet" "eks_private_subnet" {
  count = length(var.private_cidr_block)
  vpc_id     = aws_vpc.eks.id
  cidr_block = element(var.private_cidr_block,count.index)
  availability_zone = element(var.private_az,count.index)
  
  tags = {
    Name = local.private_subnet_name
  }
}

# Public subnet for EKS VPC
resource "aws_subnet" "eks_public_subnet" {
  count = length(var.public_cidr_block)
  vpc_id     = aws_vpc.eks.id
  cidr_block = element(var.public_cidr_block,count.index)
  availability_zone = element(var.public_az,count.index)

  tags = {
    Name = local.public_subnet_name
  }
}


# # Public subnet B
# resource "aws_subnet" "eks" {
#   vpc_id     = aws_vpc.eks.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "Public_subnet_B"
#   }
# }

