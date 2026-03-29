#######################################################################################################################
#                                          EKS Module                                                                 #
#   Reference https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking  #
#   Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html                    #
#######################################################################################################################
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.34.0"
  cluster_name                   = "${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = false
  iam_role_permissions_boundary  = var.iam_role_permissions_boundary
  iam_role_name                  = "${local.name_prefix}-${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}-role"
  iam_role_use_name_prefix       = false
  vpc_id                         = var.vpc_id
  subnet_ids                     = local.subnet_ids
  control_plane_subnet_ids       = local.subnet_ids
  cluster_additional_security_group_ids = [data.aws_security_group.baseline.id, data.aws_security_group.all_ual_users_https.id]
  enable_irsa                    = true
  kms_key_owners                 = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/HarnessCDDelegateRole"]
  tags                           = local.tags

  cluster_addons = {
    coredns = {
      most_recent = true
      timeouts = {
        create = "20m"
        delete = "10m"
      }
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
      timeouts = {
        create = "60m"
        delete = "10m"
      }
      resolve_conflicts = "OVERWRITE"
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
        }
      })
    }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries = {
    APPCI_MA_SSO_ROLE = {
      principal_arn = var.aws_auth_role

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  # manage_aws_auth_configmap = true
  # aws_auth_roles            = var.aws_auth_roles
  eks_managed_node_groups = {
    "${var.cluster_name}_node_group" = {
      ami_release_version           = var.ami_version
      ami_type                      = "AL2_x86_64"
      instance_types                = [var.instance_type]
      use_custom_launch_template    = true
      create_launch_template        = true
      launch_template_name          = var.launch_template_name
      user_data_template_path       = "./user_data.tpl"
      iam_role_attach_cni_policy    = true
      name                          = "${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}_node_group"
      use_name_prefix               = false
      subnet_ids                    = local.subnet_ids
      iam_role_name                 = "${local.name_prefix}-${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}"
      iam_role_permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AppPolicy_Harness"
      iam_role_description          = "EKS managed node group for ${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env} cluster"
      iam_role_attach_cni_policy    = true
      ebs_optimized                 = true
      enable_monitoring             = true
      force_update_version          = true
      enable_bootstrap_user_data    = true
      min_size                      = var.min_size
      max_size                      = var.max_size
      desired_size                  = var.desired_size
      capacity_type                 = "ON_DEMAND"
      iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      SecretManagerPolicy = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
      S3Policy = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      CloudwatchPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      Ec2Policy = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      }
      labels = {
        ApplicationCI = var.ApplicationCI
        environment   = var.env
      }

      tags = merge(local.tags,
        { "kubernetes.io/cluster/${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}" = "owned",
      "k8s.io/cluster-autoscaler/${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}" = "owned" })

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
      metadata_options = {

        http_tokens = "required"
        http_put_response_hop_limit = 10
        http_endpoint = "enabled"


      }
    }
  }

  ##########################################################################################################
  #                       Cluster additional Security Group                                                #
  # Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html                   #
  ##########################################################################################################
  cluster_security_group_additional_rules = {
    ingress_united_cluster_acess = {
      description = "Allow communication with the cluster API Server from United network"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  #########################################################################################################
  #                             Node Security Group                                                       #
  #            Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html       #
  #                          Plus NTP/HTTPS (otherwise nodes fail to launch)                              #
  #########################################################################################################
  node_security_group_additional_rules = {
    # ingress_self_all = {
    #   description = "Node to node all ports/protocols"
    #   protocol    = "-1"
    #   from_port   = 0
    #   to_port     = 0
    #   type        = "ingress"
    #   self        = true
    # }
    ingress_self_http = {
    description = "Node to node HTTP traffic"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    type        = "ingress"
    self        = true
  }

  ingress_self_https = {
    description = "Node to node HTTPS traffic"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    type        = "ingress"
    self        = true
  }

    # ingress_source_security_group_id = {
    #   description              = "Ingress from another computed security group"
    #   protocol                 = "tcp"
    #   from_port                = 22
    #   to_port                  = 22
    #   type                     = "ingress"
    #   source_security_group_id = aws_security_group.additional.id
    # }
  }
}
################################################################################
#                     aws-auth has moved here, to be removed in 21.X           #
################################################################################

module "aws-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  # version = "~> 20.0"
  version = "~> 20.34.0"

  manage_aws_auth_configmap = true
  aws_auth_roles            = var.aws_auth_roles

}

################################################################################
#                     Additional Resources                                     #
################################################################################
resource "aws_ssm_parameter" "DT_Token" {
  name        = "${var.ApplicationCI}-dynatrace-api-key"
  description = "DT_TOKEN for Dynatrace"
  type        = "String"
  value       = var.dt_api_token
}
# resource "aws_security_group" "additional" {
#   name_prefix = "${var.ApplicationCI}-${var.cluster_name}-${var.region}-${var.env}-additional"
#   vpc_id      = var.vpc_id
#   tags        = local.tags

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"
#     cidr_blocks = [
#       "10.0.0.0/8",
#       "172.16.0.0/12",
#       "192.168.0.0/16",
#     ]
#   }
# }

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each = toset(local.subnet_ids)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_alb_tag" {
  for_each = toset(local.subnet_ids)

  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_autoscaling_group_tag" "additional_asg_tags" {
  for_each = {
    for k, v in local.asg_tags :
    v.sha => v
  }

  autoscaling_group_name = each.value.name

  tag {
    key                 = each.value.key
    propagate_at_launch = true
    value               = each.value.value
  }
}

resource "kubernetes_namespace" "cluster_namespace" {
  metadata {
    name = "${var.ApplicationCI}-${var.cluster_name}-${var.env}"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
