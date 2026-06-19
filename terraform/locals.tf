data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "eks-gitops-${var.environment}"

  # Use the first 3 AZs in the region for multi-AZ resilience.
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # /20 private + /24 public subnets carved out of the VPC CIDR, one per AZ.
  private_subnets = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, i + 48)]

  common_tags = merge({
    Project     = "eks-gitops-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }, var.extra_tags)
}
