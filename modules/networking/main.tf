# Local variables
locals {
  private_subnet_name = "private_subnet"
  public_subnet_name  = "public_subnet"
}

# VPC for EKS cluster
resource "aws_vpc" "eks" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    Name                                            = var.vpc_name
    Env                                             = "Prod"
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
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.eks.id
  cidr_block        = element(var.private_cidr_block, count.index)
  availability_zone = element(var.private_az, count.index)

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
    Name                                            = local.private_subnet_name
  }
}

# Public subnet for EKS VPC
resource "aws_subnet" "eks_public_subnet" {
  count             = length(var.public_cidr_block)
  vpc_id            = aws_vpc.eks.id
  cidr_block        = element(var.public_cidr_block, count.index)
  availability_zone = element(var.public_az, count.index)

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
    Name                                            = local.public_subnet_name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.eks_public_subnet[0].id

  tags = {
    Name = "NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks_igw]
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "pub_subnets" {
  count          = length(var.public_cidr_block)
  subnet_id      = element(aws_subnet.eks_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "Private"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count          = length(var.private_cidr_block)
  subnet_id      = element(aws_subnet.eks_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rtb.id
}