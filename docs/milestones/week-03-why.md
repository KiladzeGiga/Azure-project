# Week 03 — CI build/push + Helm deploy to AKS (Why / Decisions / Proof)

## Outcome
Automated CI pipeline that builds a .NET container, pushes it to ACR, deploys it to AKS via Helm, verifies rollout, and proves `/healthz` from inside the cluster.

## What I built
- GitHub Actions workflow `app-build-push.yml`:
  - Azure OIDC login (no secrets)
  - Reads Terraform outputs (ACR + AKS names)
  - Builds and pushes image tagged with commit SHA
  - Helm lint + helm upgrade/install
  - Rollout verification + in-cluster health proof

- Helm chart `charts/azproj-api`:
  - Deployment with readiness/liveness probes
  - ClusterIP service

## Key decisions (and why)
- **Image tag = commit SHA**: deterministic rollbacks and auditability.
- **Helm**: repeatable app releases; standard in platform teams.
- **Readiness/liveness probes**: required for safe rollouts + future zero-downtime proof.
- **CI proof inside the cluster**: avoids “works on my laptop” and demonstrates service discovery.
- **Infra vs app separation**:
  - Terraform provisions Azure resources.
  - Helm deploys app to Kubernetes.
  - This matches real org boundaries and keeps blast radius smaller.

## Problems hit + fixes (real incidents)
- **403 creating azurerm_role_assignment in Terraform**
  - Root cause: APPLY identity had Contributor but lacks `Microsoft.Authorization/roleAssignments/write`.
  - Fix: grant APPLY identity `User Access Administrator` at RG scope (gated by GitHub Environment approval).
  - Why it matters: common enterprise issue; shows RBAC understanding.

- **AKS kubelet couldn't pull from ACR (preventative hardening)**
  - Fix: Terraform role assignment `AcrPull` for AKS kubelet identity on ACR scope.
  - Why it matters: avoids `ImagePullBackOff` on fresh nodes.

- **CI probe flakiness using kubectl run --rm / wait condition**
  - Root cause: `kubectl wait --for=condition=Succeeded` not reliable (Succeeded is pod phase, not condition).
  - Fix: probe uses pod phase polling; includes curl timeouts + retries.

## Proof
- app-build-push (build → push → helm deploy): https://github.com/KiladzeGiga/Azure-project/actions/runs/21391990192/job/61580884028
- Image pushed: `acrpkje3k.azurecr.io/azproj-api:07b42e3b6f387ab0a8828334aa9ef96c1daf5d16`
- Rollout verified: `deployment "azproj-api" successfully rolled out`
- In-cluster health proof (via Service DNS): `"healthy"`
