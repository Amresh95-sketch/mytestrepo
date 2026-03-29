
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "ami_version" {
  description = "AMI version"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = ""
}

variable "gitops_agent_token" {
  description = "token for deploying gitops agent"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "IAM role arn for cluster"
  type        = string
  default     = ""
}

variable "iam_role_use_name_prefix" {
  description = "IAM role prefix for cluster"
  type        = string
  default     = "harness"
}

variable "instance_type" {
  description = "The instance type for the EC2 node in the Managed Node Group"
  type        = string
  default     = "c5.4xlarge"
}

variable "min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances/nodes"
  type        = number
  default     = 2
}

variable "desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 2
}

variable "region" {
  description = "EKS cluster region"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC for EKS cluster"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet ids for EKS cluster"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "List of tags for EKS cluster"
  type        = map(any)
  default     = {}
}

variable "ApplicationCI" {
  description = "EKS ApplicationCI"
  type        = string
  default     = ""
}

variable "eks_module_version" {
  description = "Terraform module version"
  type        = string
  default     = ""
}

variable "env" {
  description = "This is the environment to which the cluster is deployed"
  type        = string
  default     = ""
}

variable "iam_role_permissions_boundary" {
  description = "EKS iam_role_permissions_boundary"
  type        = string
  default     = ""
}

variable "node_group_name" {
  type    = string
  default = "cwa-dev"
}

variable "aws_auth_roles" {
  type    = list(any)
  default = []
}
variable "aws_auth_role" {
  description = "DEPRECATED: Single IAM role ARN to add to the aws-auth configmap. Use aws_auth_roles instead."
  type        = string
}

variable "bucket" {
  description = "Bucket to store terraform statefile"
  type        = string
  default     = ""
}

variable "bucket_key" {
  description = "Bucket key/path to store terraform statefile"
  type        = string
  default     = ""
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "policy_name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = "harness-AmazonEKS_"
}

variable "aws_route53_zone" {
  description = "Hosted zone that the DNS record will be created"
  type        = string
  default     = ""
}

variable "launch_template_name" {
  description = "Name of launch template"
  type        = string
  default     = ""
}

variable "elk_role_account_id" {
  description = "The account ID of the ELK role used for FLuentbit Logging"
  type        = string
  default     = ""
}

variable "elk_role_env" {
  description = "The environment of the ELK role used for FLuentbit Logging"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of az for EKS cluster"
  type        = list(any)
  default     = []
}

variable "subnet_ids_eks_custom" {
  description = "List of subnet ids for custom network setup for pods"
  type        = list(any)
  default     = []
}

variable "Apptier_subnet_tag" {
  type    = string
  default = "AppTier-*"
}

variable "EKStier_subnet_tag" {
  type    = string
  default = "EKSTier-*"
}
variable "dt_api_token" {
  description = "Dynatrace API token"
  type        = string
  default     = ""
}
variable "terraform_template_version" {
  description = " CPE terraform eks template version"
  type        = string
  default     = "v1.3.1"
}
# variable "org_id" {
#   description = "Harness Organization Identifier"
#   type        = string
#   default     = ""
# }

# variable "project_identifier" {
#   description = "Harness project identifier"
#   type        = string
#   default     = ""
# }

# variable "harness_platform_api_key" {
#   description = "The API key for the Harness next gen platform"
#   type        = string
#   default     = ""
# }


variable "custom_label" {
  description = "custom label specific to the service"
  type        = string
  default     = "na"
}
# variable "destroy_flag" {
#   description = "enable if to destroy"
#   type        = bool
#   default     = false
# }

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to enable cluster creator as an admin"
  default = false
}
