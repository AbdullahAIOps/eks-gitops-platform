# 3. Keyless identity everywhere (IRSA for pods, OIDC for CI)

Date: 2026-01-15

## Status
Accepted

## Context
Long-lived AWS access keys are the most common cloud-credential leak vector and
are painful to rotate. We want zero static cloud secrets.

## Decision
- **CI -> AWS:** GitHub Actions assumes an IAM role via OIDC federation, with a
  trust policy scoped to `repo:<owner>/<repo>:ref:refs/heads/main`. Tokens are
  short-lived and minted per run.
- **Pods -> AWS:** workloads use IRSA (IAM Roles for Service Accounts), each
  scoped to least privilege.

## Consequences
- No `aws_access_key_id`/`secret` stored in GitHub or in the cluster.
- The trust-policy `sub` condition must be kept in sync with the branching
  model; a mismatch surfaces as an explicit AssumeRole failure (fail-closed).
- For multi-account setups, OIDC providers/roles are created per account.
