# argocd/ — GitOps

ArgoCD reconciles everything in this directory from Git. The flow is the
**app-of-apps** pattern:

```
bootstrap/root-app.yaml          <- you apply this ONCE (make bootstrap-argocd)
  └── watches argocd/applications/*.yaml
        ├── aws-load-balancer-controller.yaml
        ├── external-secrets.yaml
        ├── kube-prometheus-stack.yaml
        └── demo-app.yaml
```

All Applications belong to the `platform` AppProject (`projects/platform-project.yaml`),
which whitelists the allowed source repos and destination namespaces — so a
typo can't deploy a random chart cluster-wide.

## Wiring values from Terraform
Two add-ons need IRSA role ARNs that Terraform creates. After `make apply`,
copy the outputs into the matching Application's Helm parameters:

```bash
terraform -chdir=terraform output -raw alb_controller_role_arn
terraform -chdir=terraform output -raw external_secrets_role_arn
```

(In a larger setup these would be injected via an ApplicationSet generator or a
config repo; kept explicit here for clarity — see docs/runbook.md.)

## Replace before use
- `https://github.com/AbdullahAIOps/eks-gitops-platform` -> the HTTPS URL of your fork of this repo.
- `123456789012` and role ARNs -> from `terraform output`.
