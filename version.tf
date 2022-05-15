terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.14.0"
    }
  }

}

#  #AWS provider details
provider "aws" {
  profile = "default"
  region  = "ca-central-1"
}

# terraform {

#   cloud {
#     organization = "AlemOrg"

#     workspaces {
#       name = "terraform_cloud_github"
#     }
#   }
# }