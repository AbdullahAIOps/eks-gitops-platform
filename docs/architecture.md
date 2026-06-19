# Architecture

## Goals
- **Declarative everything.** Infra in Terraform; apps + add-ons in Git via ArgoCD.
- **No standing credentials.** CI uses GitHub OIDC; pods use IRSA.
- **Reproducible environments.** One root module, per-env state + tfvars.
- **Secure by default.** Signed images, runtime-synced secrets, hardened pods, NetworkPolicies.

## Provisioning flow

```mermaid
sequenceDiagram
    participant Dev as Engineer
    participant GH as GitHub Actions
    participant AWS as AWS
    participant Argo as ArgoCD
    Dev->>GH: open PR (terraform/**)
    GH->>AWS: assume role (OIDC), terraform plan
    GH-->>Dev: plan posted as PR comment
    Dev->>GH: merge to main
    GH->>AWS: terraform apply (gated env)
    AWS-->>GH: EKS + IRSA + OIDC role created
    Dev->>Argo: make bootstrap-argocd (apply root app once)
    Argo->>Argo: reconcile argocd/applications/*
    Argo->>AWS: ALB controller, External Secrets, monitoring, demo-app
```

## Network topology

```mermaid
flowchart LR
    IGW[Internet Gateway] --> PUB
    subgraph VPC["VPC 10.x.0.0/16"]
        subgraph PUB["Public subnets (3 AZ)"]
            ALB[Application Load Balancer]
            NAT[NAT Gateway]
        end
        subgraph PRIV["Private subnets (3 AZ)"]
            NODES[EKS managed nodes]
            PODS[Pods]
        end
    end
    ALB --> NODES
    NODES --> NAT --> IGW
    NODES -. control plane (AWS-managed) .-> EKSCP[EKS API]
```

- Nodes live only in **private** subnets; the **ALB** in public subnets is the
  single ingress. Egress is via NAT (one per AZ in prod, single in dev/staging).
- The EKS control plane is AWS-managed; the API endpoint is public but
  authenticated (tighten to private/allow-listed for hardened environments).

## Identity boundaries
| Principal | Mechanism | Scope |
|---|---|---|
| GitHub Actions | OIDC federation -> IAM role | `repo:AbdullahAIOps/eks-gitops-platform:ref:refs/heads/main` only |
| External Secrets pod | IRSA | read `eks-gitops/*` secrets/params only |
| ALB controller pod | IRSA | ELB/EC2 describe + manage |
| EBS CSI controller | IRSA | EBS volume lifecycle |

## Trade-offs (recorded as ADRs)
- ArgoCD installed by Terraform, then self-manages — see ADR-0002 / ADR-0004.
- Keyless identity everywhere — ADR-0003.
- Single vs multi-NAT per environment — cost vs availability, see `cost.md`.
