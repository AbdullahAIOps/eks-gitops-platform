# ------------------------------------------------------------------------------
# eks-gitops-platform — operator entrypoint
# Usage: make <target> ENV=<dev|staging|prod>
# ------------------------------------------------------------------------------
SHELL        := /usr/bin/env bash
ENV          ?= dev
TF_DIR       := terraform
TFVARS       := environments/$(ENV).tfvars
REGION       ?= eu-central-1                # Frankfurt — low-latency for EU
STATE_BUCKET ?= my-org-tfstate-$(ENV)
STATE_TABLE  ?= my-org-tflock
CLUSTER_NAME ?= eks-gitops-$(ENV)

.DEFAULT_GOAL := help
.PHONY: help fmt lint validate init plan apply destroy backend kubeconfig \
        bootstrap-argocd teardown precommit

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

fmt: ## Format all Terraform
	terraform -chdir=$(TF_DIR) fmt -recursive

lint: ## Lint Terraform (tflint) and config-scan (trivy)
	cd $(TF_DIR) && tflint --recursive
	trivy config $(TF_DIR)

validate: init ## terraform validate
	terraform -chdir=$(TF_DIR) validate

init: ## terraform init with the per-env S3 backend
	terraform -chdir=$(TF_DIR) init -reconfigure \
	  -backend-config="bucket=$(STATE_BUCKET)" \
	  -backend-config="key=eks/$(ENV)/terraform.tfstate" \
	  -backend-config="region=$(REGION)" \
	  -backend-config="dynamodb_table=$(STATE_TABLE)" \
	  -backend-config="encrypt=true"

plan: ## terraform plan for $(ENV)
	terraform -chdir=$(TF_DIR) plan -var-file=$(TFVARS) -out=tfplan

apply: ## terraform apply the saved plan
	terraform -chdir=$(TF_DIR) apply tfplan

destroy: ## terraform destroy $(ENV) (use teardown for the safe ordering)
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TFVARS)

backend: ## Create the S3 state bucket + DynamoDB lock table (one time per env)
	./scripts/bootstrap.sh "$(STATE_BUCKET)" "$(STATE_TABLE)" "$(REGION)"

kubeconfig: ## Write kubeconfig for the cluster
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)

bootstrap-argocd: ## Apply the app-of-apps root so ArgoCD manages everything else
	kubectl apply -n argocd -f argocd/bootstrap/root-app.yaml

teardown: ## Safe teardown: remove GitOps-managed resources, then the cluster
	./scripts/teardown.sh "$(CLUSTER_NAME)" "$(REGION)"
	$(MAKE) destroy ENV=$(ENV)

precommit: ## Run all pre-commit hooks against the whole tree
	pre-commit run --all-files
