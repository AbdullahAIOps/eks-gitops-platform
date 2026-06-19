provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# The kubernetes/helm providers authenticate to the cluster created in THIS
# config using a short-lived token from `aws eks get-token`. The exec block is
# evaluated lazily (at apply, after the cluster exists), which is what makes the
# single-apply bootstrap work. See ADR-0004 for the trade-off vs. a split apply.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}
