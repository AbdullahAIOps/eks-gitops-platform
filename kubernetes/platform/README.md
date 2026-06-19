# kubernetes/platform/

Platform-level manifests applied across the cluster.

- `secret-store.yaml` — `ClusterSecretStore` pointing at AWS Secrets Manager,
  authenticated via the External Secrets IRSA service account.
- `example-externalsecret.yaml` — shows the pattern: commit a *reference*, the
  operator materialises the real value into a Kubernetes Secret at runtime.

To create the backing AWS secret:
```bash
aws secretsmanager create-secret \
  --name eks-gitops/demo/app-config \
  --secret-string '{"api_key":"...","db_password":"..."}' \
  --region eu-central-1
```
