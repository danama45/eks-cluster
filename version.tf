terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.5.1"
    }
kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"

}
  }


}

#  #AWS provider details
provider "aws" {
  profile = "default"
  region  = "ca-central-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
}



# terraform {

#   cloud {
#     organization = "AlemOrg"

#     workspaces {
#       name = "terraform_cloud_github"
#     }
#   }
# }