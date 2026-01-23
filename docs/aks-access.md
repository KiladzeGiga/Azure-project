# AKS Access (kubectl) — How I Authenticate

## Goal
Explain how I obtain AKS cluster credentials and use kubectl safely without committing sensitive files.

## Interview notes
### Why the API server URL is `*.hcp.<region>.azmk8s.io`
- AKS control plane is **managed by Microsoft**; the Kubernetes API server is not running on my worker nodes.
- `kubectl` talks to the managed control-plane endpoint after I download credentials into kubeconfig.
- My current cluster is **public (not private)**, so the API server endpoint is reachable over the internet (still protected by auth/RBAC).

### Minimum Azure permissions for `az aks get-credentials`
- At minimum you need an AKS access role on the cluster:
  - **Azure Kubernetes Service Cluster User Role** (user credentials), or
  - **Azure Kubernetes Service Cluster Admin Role** (admin credentials).
- You also need basic access to read the cluster resource (commonly covered by Reader/Contributor at RG scope).
- Even if you can fetch credentials, Kubernetes RBAC can still block actions inside the cluster.

## What changes on my machine
- `az aks get-credentials` writes/updates kubeconfig at `%USERPROFILE%\.kube\config`.
- It adds a cluster context (API server endpoint + auth info) for this AKS cluster.
- `--overwrite-existing` replaces any existing entry for the same cluster name.

## Why kubectl works without a password
- I authenticate to Azure using `az login`.
- `az aks get-credentials` retrieves the cluster access configuration and saves it to kubeconfig.
- `kubectl` uses kubeconfig to authenticate and then uses Kubernetes RBAC for authorization.

## Prereqs (local machine)
- Azure CLI installed
- kubectl installed
- Logged into the correct subscription:
```powershell
az account show
