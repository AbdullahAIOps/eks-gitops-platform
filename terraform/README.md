# terraform/

Root module that provisions the platform: VPC, EKS, IRSA roles, the GitHub OIDC
CI role, and the ArgoCD bootstrap install.

## Design notes
- **We consume battle-tested registry modules** (`terraform-aws-modules/vpc`,
  `.../eks`, `.../iam`) rather than re-implementing them. Re-writing an EKS
  module by hand is a maintenance liability; pinning a well-maintained upstream
  module is the pragmatic production choice. (Authoring *bespoke* reusable
  modules is the explicit focus of the companion repo
  `multicloud-terraform-landing-zone`.)
- **One root module, many environments.** State is isolated per environment via
  the partial S3 backend (`-backend-config` at init), and inputs come from
  `environments/dev.tfvars`. No `terraform workspace` magic — explicit is
  better.
- **`modules/`** is reserved for thin internal wrappers (e.g. an opinionated
  `platform-namespace` module). It is intentionally empty in this repo.

## Usage
```bash
make init  ENV=dev     # init with the dev backend
make plan  ENV=dev
make apply ENV=dev
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| aws | ~> 5.60 |
| helm | ~> 2.14 |
| kubernetes | ~> 2.31 |
| tls | ~> 4.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region | AWS region to deploy into | string | "eu-central-1" |
| environment | dev \| staging \| prod | string | n/a |
| cluster_version | EKS control-plane version | string | "1.32" |
| vpc_cidr | VPC CIDR | string | "10.0.0.0/16" |
| single_nat_gateway | Single NAT (cheaper) vs one per AZ | bool | true |
| node_instance_types | Default node group instance types | list(string) | ["m5.large"] |
| github_repository | owner/repo allowed to assume the CI role | string | "AbdullahAIOps/eks-gitops-platform" |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | EKS cluster name |
| cluster_endpoint | API server endpoint |
| github_ci_role_arn | Set as AWS_ROLE_TO_ASSUME in GitHub |
| external_secrets_role_arn | IRSA role for External Secrets |
| alb_controller_role_arn | IRSA role for the ALB controller |
<!-- END_TF_DOCS -->
