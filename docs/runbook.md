# Runbook

Operational procedures for the platform. Assumes `make kubeconfig ENV=<env>` has been run.

## Accessing ArgoCD
```bash
# initial admin password (delete the secret after setting a real one / SSO)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
kubectl -n argocd port-forward svc/argocd-server 8080:80
# open https://localhost:8080  (user: admin)
```

## Wiring IRSA ARNs into ArgoCD Applications (one-time, post-apply)
```bash
ALB_ARN=$(terraform -chdir=terraform output -raw alb_controller_role_arn)
ESO_ARN=$(terraform -chdir=terraform output -raw external_secrets_role_arn)
# update argocd/applications/aws-load-balancer-controller.yaml and external-secrets.yaml,
# commit, push — ArgoCD re-syncs automatically.
```

## Enforcing signed images (admission)
Install a policy controller (e.g. Sigstore policy-controller or Kyverno) and
require a valid Cosign signature for the ECR repo. Example Kyverno rule lives
in the `devsecops-supply-chain` companion repo. Verify manually:
```bash
cosign verify <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/eks-gitops/demo-app:<tag> \
  --certificate-identity-regexp '.*' --certificate-oidc-issuer-regexp '.*'
```

## Common incidents
| Symptom | Likely cause | Action |
|---|---|---|
| Application stuck `OutOfSync` | drift or failed hook | `kubectl -n argocd describe application <name>`; check ArgoCD UI events |
| `terraform destroy` hangs on subnet | orphaned ALB/NLB | run `scripts/teardown.sh` first (deletes Ingress/LB Services) |
| Pods `CreateContainerConfigError` | ExternalSecret not synced | check ESO logs; confirm AWS secret exists + IRSA ARN is correct |
| CI cannot push to ECR | role/branch mismatch | confirm `AWS_ROLE_TO_ASSUME` + trust policy `sub` matches branch |

## Upgrading Kubernetes
1. Bump `cluster_version` in the env tfvars (one minor at a time).
2. `make plan ENV=<env>` and review.
3. Apply; the module upgrades the control plane, then roll node groups.
4. Re-validate add-on compatibility (ArgoCD shows any drift).
