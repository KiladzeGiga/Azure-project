# Destroy / Recreate (cost control)

## Why
AKS costs money even when idle. For a portfolio project, I destroy between sessions and recreate when needed.

## What Terraform creates
Terraform provisions Azure infrastructure:
- RG, AKS, ACR, RBAC role assignments, etc.

Terraform does **NOT** deploy the application into AKS.

## What deploys the application
App deploy is handled by CI (GitHub Actions):
- build image -> push to ACR -> helm upgrade/install -> rollout check -> in-cluster /healthz proof

## Recreate procedure (expected)
1) `tf-apply` to recreate infra
2) run `app-build-push` workflow (manual dispatch or app/chart change) to deploy the app