output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes control-plane version."
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "github_ci_role_arn" {
  description = "ARN to set as the AWS_ROLE_TO_ASSUME secret in GitHub Actions."
  value       = aws_iam_role.github_ci.arn
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for the External Secrets Operator service account."
  value       = module.external_secrets_irsa.iam_role_arn
}

output "alb_controller_role_arn" {
  description = "IRSA role ARN for the AWS Load Balancer Controller service account."
  value       = module.alb_controller_irsa.iam_role_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
