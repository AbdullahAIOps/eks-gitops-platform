# Cost notes

Rough monthly cost drivers (eu-central-1, on-demand) for the **dev** profile:

| Item | dev | prod |
|---|---|---|
| EKS control plane | ~$73 (flat per cluster) | ~$73 |
| Worker nodes | 2 x m5.large | 3+ x m5.xlarge |
| NAT gateway | 1 (single) | 3 (one per AZ) |
| ALB | 1 | 1+ |
| EBS / data transfer | usage-based | usage-based |

## Levers
- **`single_nat_gateway = true`** in dev/staging saves ~2x NAT hourly + data
  processing cost. Prod uses one NAT per AZ for availability (a single NAT is an
  AZ-level SPOF for egress).
- Consider **Spot** capacity for stateless workloads (add a Spot node group).
- Add **cluster-autoscaler / Karpenter** to scale nodes to actual demand.

## Estimating changes in CI
Add Infracost to the PR pipeline to surface the cost delta of every change:
```yaml
- uses: infracost/actions/setup@v3
- run: infracost breakdown --path terraform --terraform-var-file environments/dev.tfvars
```
