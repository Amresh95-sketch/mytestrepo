# EKS Terraform Module

This repository contains a comprehensive Terraform module for deploying Amazon EKS (Elastic Kubernetes Service) clusters with best practices and enterprise-ready configurations. It leverages the official AWS EKS Terraform module with additional customizations and enhancements for operational excellence.

## Architecture

The EKS deployment follows a modular design with the following components:

```mermaid
graph TD
    subgraph "AWS Cloud"
        subgraph "VPC"
            SN[Subnets]
            SG[Security Groups]
        end

        subgraph "EKS Cluster"
            CP[Control Plane]

            subgraph "Node Groups"
                MNG[Managed Node Groups]
            end

            subgraph "Add-ons"
                style Add-ons fill:#f9f,stroke:#333,stroke-width:2px
                CNI[VPC CNI]
                CoreDNS[CoreDNS]
                KP[Kube Proxy]
                EBS[EBS CSI Driver]
            end

            subgraph "IRSA"
                style IRSA fill:#bbf,stroke:#333,stroke-width:2px
                ALB[Load Balancer Controller]
                ECSIR[EBS CSI Role]
                KR[Karpenter Role]
                CNIR[VPC CNI Role]
            end
        end

        subgraph "Helm Deployments"
            K8D[Kubernetes Dashboard]
            KA[Karpenter]
            MM[Metrics Server]
        end

        subgraph "IAM"
            IR[IAM Roles]
            OIDC[OIDC Provider]
        end

        subgraph "Route53"
            R53[Private Hosted Zone]
        end

        subgraph "KMS"
            KEY[KMS Key]
        end
    end

    CP --> MNG
    CP --> Add-ons
    CP --> IRSA
    CP --> OIDC
    CP --> KEY
    SN --> CP
    SG --> CP
    IRSA --> IR
    CP --> Helm Deployments
    CP --> R53
```

## Key Features

- **AWS EKS Best Practices**: Follows all AWS recommended best practices for EKS
- **IAM Roles for Service Accounts (IRSA)**: Secure pod-level IAM roles
- **Managed Node Groups**: EC2 managed node groups with autoscaling
- **Karpenter**: Automatic node provisioning for right-sizing and cost optimization
- **Helm Deployments**: Automated deployment of common Kubernetes utilities
- **Private Networking**: Support for private cluster endpoints
- **Security**: Enhanced security with proper IAM roles and security groups
- **Monitoring & Observability**: Pre-configured addons for monitoring and observability

## Module Structure

- **eks.tf**: Main EKS cluster definition
- **iam/**: IAM roles and policies for the cluster and workloads
- **helm/**: Helm chart deployments for additional services
- **irsa.tf**: IAM roles for service accounts configuration
- **karpenter.tf**: Karpenter autoscaler configuration
- **manifest.tf**: Kubernetes manifests for additional resources
- **route53/**: DNS configuration for the EKS cluster
- **venafi/**: Certificate management integration

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform (version >= 1.0.0)
- kubectl
- Existing VPC with subnets properly tagged
- IAM permissions to create roles, policies, and EKS clusters

## Usage

1. Initialize the Terraform configuration:
   ```bash
   terraform init -backend-config=backend.tfvars
   ```

2. Plan the deployment:
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

4. Configure kubectl to use the new cluster:
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

## Configuration Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | EKS cluster name | string | "" | yes |
| account_id | AWS account ID | string | "" | yes |
| cluster_version | Kubernetes version to deploy | string | "1.27" | yes |
| vpc_id | VPC ID where EKS will be deployed | string | "" | yes |
| subnet_ids | List of subnet IDs for the EKS cluster | list(string) | [] | yes |
| ApplicationCI | Application CI name | string | "" | yes |
| env | Environment name (dev, qa, prod) | string | "" | yes |
| region | AWS region | string | "" | yes |
| iam_role_permissions_boundary | IAM permissions boundary for created roles | string | "" | no |
| node_groups | Map of EKS managed node group definitions | map(any) | {} | no |

## Add-ons and Components

### Core Add-ons
- VPC CNI with custom networking
- CoreDNS
- Kube Proxy
- EBS CSI Driver

### IRSA (IAM Roles for Service Accounts)
- Load Balancer Controller
- Cluster Autoscaler
- External DNS
- EBS CSI Driver
- VPC CNI Controller

### Helm Charts
- AWS Load Balancer Controller
- Metrics Server
- Karpenter
- Kubernetes Dashboard

## Security Considerations

- Cluster runs with private endpoint only by default
- All IAM roles follow least privilege principle
- KMS encryption for secrets
- Network policies for pod-to-pod communication
- Security groups for node-level access control

## Monitoring and Logging

- CloudWatch Logs integration
- Metrics collection via metrics-server
- Container Insights support

## Troubleshooting

Common issues and their solutions:

1. **Node group fails to join the cluster**:
   - Check IAM roles and instance profiles
   - Verify security group rules allow required traffic
   - Check VPC CNI configuration

2. **IRSA not working**:
   - Verify OIDC provider is correctly configured
   - Check service account annotations
   - Verify IAM role trust relationships

3. **Load balancer controller issues**:
   - Check IRSA configuration
   - Verify subnet tagging
   - Review controller logs

## Maintenance

### Upgrading the Cluster
To upgrade the Kubernetes version:
```bash
terraform apply -var='cluster_version=1.28' -var-file=terraform.tfvars
```

### Adding Node Groups
Modify the node_groups variable in your terraform.tfvars file:
```hcl
node_groups = {
  general = {
    desired_capacity = 2
    max_capacity     = 10
    min_capacity     = 2
    instance_types   = ["m5.large"]
    capacity_type    = "ON_DEMAND"
  }
}
```

## License

Copyright (c) 2025 United Airlines. All rights reserved.

## Contributors

- Infrastructure & Platform Engineering Team
