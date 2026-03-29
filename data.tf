
################################################################################
#                            Data                                              #
################################################################################

data "aws_caller_identity" "current" {}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_id]
}

data "http" "eks_cluster_readiness" {
  url         = join("/", [data.aws_eks_cluster.cluster.endpoint, "healthz"])
  ca_cert_pem = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  depends_on  = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  # depends_on = [module.eks.cluster_id]
  depends_on = [data.http.eks_cluster_readiness]
}

data "aws_route53_zone" "eks_hosted_zone" {
  name         = "${var.aws_route53_zone}."
  private_zone = true
}

data "external" "iam_role_check" {
  program = ["bash", "${path.module}/check_role.sh", "harness-${var.ApplicationCI}-${var.env}-${var.region}-iam_role_sa"]
}

# data "aws_vpc" "vpc" {
#   tags = {
#     "ApplicationCI" = var.ApplicationCI
#   }
# }

data "aws_subnets" "Apptier_subnets" {
  filter {
    name   = "tag:Name"
    values = [var.Apptier_subnet_tag]
  }
}

data "aws_subnets" "EKStier_subnets" {
  filter {
    name   = "tag:Name"
    values = [var.EKStier_subnet_tag]
  }
}

data "aws_subnet" "EKStier1" {
  id = data.aws_subnets.EKStier_subnets.ids[0]
}

data "aws_subnet" "EKStier2" {
  id = data.aws_subnets.EKStier_subnets.ids[1]
}

data "aws_subnet" "EKStier3" {
  id = data.aws_subnets.EKStier_subnets.ids[2]
}
data "aws_security_group" "baseline" {
  tags = {
    "aws:cloudformation:logical-id" = "BaselineSecurityGroup"
    "ApplicationCI"                 = "bte"
    #"aws:cloudformation:stack-name" = "StackSet-BaselineSGTGW-Prd-68656772-067d-4471-a426-e18257ed9b94"
  }
}

data "aws_security_group" "all_ual_users_https" {
  tags = {
    "aws:cloudformation:logical-id" = "AllUALUsersHTTPS"
  }
}
