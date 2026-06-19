# Contributing

## Workflow
1. Branch from `main` using a conventional prefix: `feat/`, `fix/`, `chore/`, `docs/`.
2. Run `make fmt lint` before pushing — CI will reject unformatted Terraform.
3. Open a PR. The `terraform-plan` workflow comments the plan on the PR.
4. After review + merge to `main`, `terraform-apply` runs against a protected environment that requires manual approval.

## Commit messages
We use [Conventional Commits](https://www.conventionalcommits.org/):
```
feat(eks): enable cluster autoscaler
fix(argocd): correct repo URL in root app
docs(adr): add ADR for single-NAT trade-off
```

## Local hooks
```bash
pip install pre-commit
pre-commit install
```
This runs `terraform fmt`, `tflint`, `tfsec/trivy config`, and YAML/markdown linting on every commit.

## Architecture changes
Any change that alters the architecture (new add-on, new trust boundary, networking change) must include or update an ADR under `docs/adr/`.
