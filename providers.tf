

################################################################################
#                     Required provider                                        #
################################################################################
terraform {
  required_version = ">= 1.0.0"
  # backend "s3" {
  #   bucket         = "cgm-statefile-us-east-1-dev-333458576590"
  #   key            = "terraform/eks/eks/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "cgm-dynamodb-us-east-1-dev-333458576590"
  #   profile        = "saml"
  #   }
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    harness = {
      source  = "harness/harness"
      version = "0.22.1"
    }
  }
}

provider "aws" {
  #region = "us-east-1"
  # profile = "saml"
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   # This requires the awscli to be installed locally where Terraform is executed
  #   args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  # }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}
# provider "harness" {
#   endpoint         = "https://app.harness.io/gateway"
#   account_id       = "H6rHO8vtQYKelD_wgjnMpA"
#   platform_api_key = var.harness_platform_api_key
# }
