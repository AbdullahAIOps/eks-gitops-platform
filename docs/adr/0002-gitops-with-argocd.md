# 2. Use GitOps (ArgoCD, app-of-apps) for delivery

Date: 2026-01-15

## Status
Accepted

## Context
We need a way to deploy and continuously manage platform add-ons and apps that
is auditable, self-healing, and decoupled from CI runners' credentials.

## Decision
ArgoCD reconciles the cluster from this Git repo using the **app-of-apps**
pattern: a single root Application points at `argocd/applications/`, and each
child Application manages one add-on/app. Sync is automated with `prune` and
`selfHeal`.

## Alternatives considered
- **Push from CI (`kubectl apply`/`helm upgrade`):** simpler, but CI needs
  cluster-admin credentials and there is no drift correction. Rejected.
- **Flux:** comparable; ArgoCD chosen for its UI, AppProject RBAC, and team
  familiarity. Either would satisfy the requirements.

## Consequences
- Git is the single source of truth; manual `kubectl` edits are reverted by
  self-heal.
- A two-step seam exists for IRSA ARNs (created by Terraform, consumed by
  Applications) — documented in the runbook; acceptable for this scope.
