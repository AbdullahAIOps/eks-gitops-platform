variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Deployment environment (dev|staging|prod). Used for naming + tags."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "cluster_version" {
  description = "EKS Kubernetes control-plane version."
  type        = string
  default     = "1.32"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (cheaper, lower availability). Set false in prod."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "Instance types for the default managed node group."
  type        = list(string)
  default     = ["m5.large"]
}

variable "node_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 5
}

variable "github_repository" {
  description = "owner/repo allowed to assume the CI role via GitHub OIDC."
  type        = string
  default     = "AbdullahAIOps/eks-gitops-platform"
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version (bootstrapped by Terraform)."
  type        = string
  default     = "7.6.12"
}

variable "extra_tags" {
  description = "Additional tags merged into every resource."
  type        = map(string)
  default     = {}
}
