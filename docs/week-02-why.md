\# Week 02 — AKS + ACR (Why / Decisions / Proof)

## Outcome
Created AKS + ACR using Terraform and proved kubectl access from my local machine; environment is destroyable to control cost.

## Decisions
- No custom VNet yet: used minimal AKS networking to keep scope small and destroy/recreate reliable.
- Node pool kept minimal (1 node) to stay within budget and reduce operational complexity.
- ACR SKU = Basic, admin disabled: enough for CI image pushes later without paying for premium features.
- Names use random suffix: acceptable for destroy-between-sessions; consumers must use Terraform outputs, not hardcoded names.
- Backend uses `use_azuread_auth=true` to avoid storage account key access in CI and rely on Azure AD + RBAC.

## Problems hit + Fixes
### Problem: Terraform backend tried to list storage account keys (403)
- Symptom: `storageAccounts/listKeys/action` forbidden during `terraform init`.
- Root cause: backend attempted key-based auth.
- Fix: set backend `use_azuread_auth=true`.
- Prevention: keep backend on Azure AD auth; avoid granting listKeys permissions.

### Problem: AKS kubectl command typo
- Symptom: `resource type "nodeskubectl"`.
- Root cause: typed two commands on one line.
- Fix: run one command per line.
- Prevention: slow down; copy/paste commands carefully.

## Proof
### Terraform outputs
- `acr_login_server = "acronqzge.azurecr.io"`
- `acr_name = "acronqzge"`
- `aks_name = "aks-azproj-swp3sr"`
- `aks_rg = "rg-azproj-prod"`

### kubectl
- API server: `https://azproj-swp3sr-spu8gbv8.hcp.westeurope.azmk8s.io:443`
- Nodes:
  - `aks-system-11849319-vmss000000   Ready    <none>   v1.33.5`
- Namespaces:
  - `default`, `kube-node-lease`, `kube-public`, `kube-system`

### Destroy drill (cost control)
- `terraform destroy` removed `rg-azproj-prod` successfully.
- `az aks list -g rg-azproj-prod` returned `ResourceGroupNotFound` (expected).
- `az acr list -g rg-azproj-prod` returned `ResourceGroupNotFound` (expected).