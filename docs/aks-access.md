## Goal
Show how I access AKS with kubectl **without committing kubeconfig** and what permissions are involved.

## What happens on my machine
- `az aks get-credentials` writes/updates kubeconfig at:
  - Windows: `%USERPROFILE%\.kube\config`
- It adds/updates a **context** for the AKS cluster (API server endpoint + auth method).
- I never commit kubeconfig (it contains credentials/tokens).

## How auth works (short + correct)
1) I authenticate to Azure with `az login`.
2) I fetch cluster credentials using `az aks get-credentials`.
3) kubectl uses the kubeconfig entry to talk to the AKS API server.

AKS API endpoint is hosted by Microsoft (public cluster):
- `https://<cluster>.<region>.hcp.<region>.azmk8s.io:443`

## Required Azure permissions (the interview bit)
- To fetch kubeconfig, the caller needs permission to perform:
  - `Microsoft.ContainerService/managedClusters/listClusterUserCredential/action`
- If using `--admin`, it uses:
  - `.../listClusterAdminCredential/action`
and should be restricted (CI only + approval gate).

## Commands (proof)
```powershell
az account show
az aks get-credentials -g <aks_rg> -n <aks_name> --overwrite-existing
kubectl cluster-info
kubectl get nodes
kubectl get ns
