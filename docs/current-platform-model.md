# Current Platform Model

The project is being built as a Cloud DevOps portfolio platform. The goal is to demonstrate infrastructure automation, CI/CD, Kubernetes deployment, cost control, and later TLS, autoscaling, observability, and incident response.

## What exists today

### GitHub repository
The repository contains:
- `infra/` — Terraform code for Azure infrastructure
- `app/` — .NET API source code and Dockerfile
- `charts/` — Helm chart for deploying the app to AKS
- `.github/workflows/` — CI/CD workflows
- `docs/` — project documentation and proof notes

### Terraform
Terraform manages the Azure infrastructure for the project.

Terraform does not simply “run scripts.” It compares:
- desired state in code
- current state recorded in remote state
- real resources in Azure

Then it creates, updates, or destroys only what is required.

### Remote state
Terraform state is stored remotely in Azure Storage.

This is important because:
- CI/CD runners can access the same state
- state is not stored only on one laptop
- infrastructure changes are consistent between local and GitHub Actions
- the state backend should survive destroy/recreate of the production lab

### Azure resources
The project currently uses Azure resources such as:
- Terraform backend resource group
- Terraform state storage account/container
- production resource group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS)
- RBAC role assignments
- Azure DNS zone
- monitoring resources if enabled

ACR stores Docker images.
AKS runs the containerized application.
Azure RBAC controls which GitHub Actions identity can plan, apply, push images, and access AKS.

### Kubernetes
AKS provides the Kubernetes cluster.

Inside Kubernetes, the app is represented by:
- Helm release
- Deployment
- ReplicaSet
- Pod
- Service
- readiness/liveness health checks

The Deployment controls desired pod state.
The Pod runs the container.
The Service gives the app a stable internal network endpoint.
The Helm chart templates the Kubernetes resources.

### App deployment
The application is deployed with Helm from GitHub Actions.

Terraform creates the infrastructure.
Helm deploys the application into Kubernetes.

These are intentionally separate responsibilities.

## Request / deployment flow

When app or chart code is pushed to `main`, the `app-build-push` workflow runs.

The flow is:

1. App or chart code is pushed to main.
2. GitHub Actions starts the app-build-push workflow.
3. The workflow authenticates to Azure using OIDC.
4. The workflow reads Terraform outputs to discover the current ACR and AKS names.
5. Docker builds the .NET API image.
6. The image is pushed to ACR with the Git commit SHA as the tag.
7. The workflow gets AKS credentials.
8. Helm deploys or upgrades the app in AKS with the new image tag.
9. Kubernetes pulls the image from ACR and creates/updates the pod.
10. GitHub Actions verifies rollout status.
11. A temporary curl pod calls the app through Kubernetes Service DNS and checks /healthz.

## Infrastructure flow

When Terraform code is changed and merged to `main`, the `tf-apply` workflow runs.

The flow is:

1. Terraform code is changed and merged to main.
2. GitHub Actions starts the tf-apply workflow.
3. The workflow authenticates to Azure using OIDC.
4. The prod environment approval gate protects the apply.
5. Terraform initializes using the Azure Storage remote backend.
6. Terraform reads the current remote state.
7. Terraform compares desired code, saved state, and real Azure resources.
8. Terraform applies only the required infrastructure changes.
9. Terraform updates remote state.
10. New output values become available for other workflows, such as ACR name and AKS name.

Terraform creates cloud infrastructure.
Terraform does not deploy the app container into Kubernetes.

## Runtime flow

At runtime, the app runs inside AKS.

The current flow is:

1. The Kubernetes Deployment defines the desired app pod.
2. The pod runs the .NET container image pulled from ACR.
3. The Kubernetes Service provides a stable internal DNS name for the app.
4. Health probes help Kubernetes decide if the pod is healthy.
5. The CI pipeline verifies the service by running a temporary curl pod inside the cluster.

Currently the app is internal only through a ClusterIP Service.
It is not yet exposed publicly through Ingress/TLS.

## Destroy / recreate behavior

Destroy/recreate is used to control cost.

When the production Terraform stack is destroyed:
- AKS is destroyed
- Kubernetes objects inside AKS disappear
- app deployments disappear
- ACR may be destroyed if it is part of the production stack
- role assignments created for the production stack disappear
- monitoring resources may disappear if they are part of the production stack

The Terraform backend should survive:
- backend resource group
- state storage account
- state container
- state file

After recreating infrastructure with Terraform, the app is not automatically deployed.
The `app-build-push` workflow must run again to build/push/deploy the app into the new AKS cluster.

## Things I understand now
- Terraform and Helm have different responsibilities.
- Terraform manages Azure infrastructure.
- Helm manages Kubernetes application deployment.
- GitHub Actions connects the two through CI/CD.
- ACR stores the image; AKS runs the image.
- Destroying AKS also destroys the Kubernetes app objects inside it.

## Things still unclear
- How to make design decisions when there is no step-by-step instruction.
- How to choose between multiple valid tools or patterns.
- How to think from problem → options → tradeoff → decision.