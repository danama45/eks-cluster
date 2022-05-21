module "networking" {
  source   = "./modules/networking"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  igw_name = var.igw_name
  eks_cluster_name = var.eks_cluster_name
}