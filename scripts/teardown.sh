#!/usr/bin/env bash
# Safe teardown ordering. ArgoCD-managed Services of type LoadBalancer and ALB
# Ingresses create AWS load balancers OUTSIDE Terraform's state; deleting them
# first prevents orphaned ELBs that block VPC/subnet destruction.
#
# Usage: ./scripts/teardown.sh eks-gitops-prod us-east-1
set -euo pipefail

CLUSTER="${1:?cluster name required}"
REGION="${2:?region required}"

echo ">> Pointing kubectl at ${CLUSTER}"
aws eks update-kubeconfig --name "${CLUSTER}" --region "${REGION}" || {
  echo "   cluster unreachable; skipping in-cluster cleanup"
  exit 0
}

echo ">> Removing the app-of-apps root (cascades to all Applications)"
kubectl delete -n argocd -f argocd/bootstrap/root-app.yaml --ignore-not-found

echo ">> Deleting Ingresses and LoadBalancer Services so AWS LBs are released"
kubectl delete ingress --all-namespaces --all --ignore-not-found
kubectl delete svc --all-namespaces \
  --field-selector spec.type=LoadBalancer --ignore-not-found

echo ">> Waiting 60s for the ALB/NLB to be deprovisioned..."
sleep 60

echo ">> In-cluster cleanup complete. Run 'make destroy' to remove infra."
