# data "aws_eks_cluster" "cluster_this" {
#   count = var.destroy_flag ? 1 : 0
#   name  = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "auth" {
#   count = var.destroy_flag ? 1 : 0
#   name  = module.eks.cluster_name
# }