# app/

A tiny, dependency-free Go HTTP service (`/`, `/healthz`, `/readyz`) that exists
to exercise the real supply-chain pipeline:
**build (multi-stage, distroless) -> Trivy scan -> Syft SBOM -> Cosign sign -> push to ECR -> GitOps image bump**.

Build locally:
```bash
docker build -t demo-app:dev ./app
docker run -p 8080:8080 demo-app:dev
curl localhost:8080/healthz
```
