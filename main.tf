module "networking" {
  source           = "./modules/networking"
  vpc_cidr         = var.vpc_cidr
  vpc_name         = var.vpc_name
  igw_name         = var.igw_name
  eks_cluster_name = var.eks_cluster_name
}

module "eks" {
  source              = "./modules/eks"
  vpc_id              = module.networking.vpc_id
  aws_priv_subnet1_id = module.networking.private_subnet_ids
  aws_pub_subnet1_id  = module.networking.public_subnet_ids
  eks_cluster_name = var.eks_cluster_name
region =var.region
}