# 4. Single-apply bootstrap via exec-auth Helm provider

Date: 2026-01-16

## Status
Accepted

## Context
ArgoCD must exist before it can manage anything, but the cluster is created in
the same Terraform run. The Kubernetes/Helm providers therefore need to
authenticate to a cluster that does not yet exist at plan time.

## Decision
Configure the `kubernetes` and `helm` providers with an `exec` block calling
`aws eks get-token`. Because exec auth is evaluated lazily (at apply, after the
cluster exists), a single `terraform apply` can both create the cluster and
install ArgoCD. ArgoCD then self-manages all further add-ons from Git.

## Alternatives considered
- **Split into two states/applies** (infra, then platform): the most robust
  pattern at scale and avoids provider-bootstrap fragility, at the cost of an
  extra apply and cross-state data passing. Recommended for large orgs;
  over-engineered for this reference repo.
- **Bootstrap ArgoCD by raw manifest in a script:** works but loses Terraform's
  drift visibility for the ArgoCD release itself.

## Consequences
- One command stands up the whole platform — great for demos and ephemeral envs.
- Destroy ordering matters (ArgoCD-managed cloud LBs); handled by
  `scripts/teardown.sh`.
- If the cluster is recreated, the provider re-binds automatically on next apply.
