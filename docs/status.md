# Project Status — Azure Web Platform (AKS + Terraform + GitHub Actions)

## Snapshot
- **Repo:** https://github.com/KiladzeGiga/Azure-project
- **Goal:** Interview-grade portfolio showing ownership: IaC, CI/CD, TLS, autoscaling, zero-downtime deploys, observability.
- **Time budget:** 4–5h/week
- **Budget:** $50–$100/month
- **Environment model:** Single “prod” env with manual approval gate (GitHub Environments)

## Current Milestone
- **Milestone:** M1 — Terraform foundations (remote state + OIDC + plan/apply gates)
- **Status:** ✅ Done

## Proof (Week 01)
- Apply run (OIDC + approval gate): https://github.com/KiladzeGiga/Azure-project/actions/runs/20956477711/job/60224768765
- PR plan run: https://github.com/KiladzeGiga/Azure-project/actions/runs/21065338584
- PR apply run: https://github.com/KiladzeGiga/Azure-project/actions/runs/21065340426
- Manual approval gate: [screenshot](./assets/week-01/manual-approval.png)
- Remote state exists (Azure Storage): [screenshot](./assets/week-01/tfstate-in-storage.png)
- Subscription activity log: [screenshot](./assets/week-01/subscription-activity-log.png)
- Import vs recreate documented: [state-import.md](./state-import.md)


## Proof (Week 02)
- Plan run link (ACR + random): https://github.com/KiladzeGiga/Azure-project/actions/runs/21285576850/job/61265788044
- Apply run link (ACR created): https://github.com/KiladzeGiga/Azure-project/actions/runs/21285627844/job/61265959167
- kubectl nodes: aks-system-12484962-vmss000000   Ready    <none>   4m31s   v1.33.5
- namespaces: default, kube-node-lease, kube-public, kube-system
- az aks get-credentials -g rg-azproj-prod -n aks-azproj-lwt3q9 --overwrite-existing
Merged "aks-azproj-lwt3q9" as current context in C:\Users\gkiladze\.kube\config
- Destroy drill: `terraform destroy` removed `rg-azproj-prod` (5 resources destroyed)
- Post-destroy verification: `az aks list` and `az acr list` returned `ResourceGroupNotFound` (expected)
- kubectl cluster-info: Kubernetes control plane is running at https://*.hcp.<region>.azmk8s.io

## Proof (Week 03)
- app-build-push (build → push → helm deploy): https://github.com/KiladzeGiga/Azure-project/actions/runs/21391990192/job/61580884028
- Image pushed: `acrpkje3k.azurecr.io/azproj-api:07b42e3b6f387ab0a8828334aa9ef96c1daf5d16`
- Rollout verified: `deployment "azproj-api" successfully rolled out`
- In-cluster health proof (via Service DNS): `"healthy"`

## What’s Done (evidence-first)
- [✅] Remote Terraform state in Azure Storage used by CI (OIDC + RBAC, no storage keys) — proof: Week 01 runs + storage screenshot
- [✅] GitHub Actions plan/apply pipeline with environment approval gate — proof: apply run + approval screenshot
- [✅] Public repo hardening: fork-safe validation + split PLAN/APPLY identities — proof: workflow code + logs
- [✅] ACR created via Terraform — proof: Week 02 plan/apply runs
- [✅] AKS created via Terraform + kubectl access proven — proof: Week 02 kubectl outputs
- [✅] Destroy-between-sessions drill completed — proof: destroy output + RG-not-found verification

## Current Architecture (tiny, production-like)
- **IaC:** Terraform
- **CI/CD:** GitHub Actions
- **Target platform:** AKS
- **App delivery:** Helm
- **Ingress/TLS:** NGINX Ingress + cert-manager + Let’s Encrypt DNS-01 via Azure DNS
- **Observability:** Azure Monitor / Log Analytics (Container insights)

## ADR Index
- ADR-000 Goals & constraints — (./docs/adr/ADR-000-goals-and-constraints.md)
- ADR-001 AKS vs ACA — (./docs/adr/ADR-001-platform-choice-aks-vs-aca.md)
- ADR-002 Terraform vs Bicep — Planned
- ADR-003 Ingress/TLS strategy — Planned
- ADR-004 Deployment strategy (zero downtime) — Planned

## Acceptance Criteria (must be provable)
- **TLS:** cert issued automatically + proof commands/screens
- **Autoscaling:** HPA scales 2→6 under load + proof output
- **Zero downtime:** 0 failed requests during deploy + probe script evidence

## Week 01 Plan (archived)
**Outcome:** configured Terraform foundations (remote state + OIDC + plan/apply gates)
## Week 02 Plan (archived)
**Outcome:** created ACR + AKS via Terraform, proved kubectl access, proved destroy/recreate.

### Tasks (4–5h max)
1) [✅] create documentation — ./docs directory
2) [✅] create resources in Azure — screenshots + Workflow run + Command outputs in proof section
3) [✅] create resources in GitHub — screenshots + Workflow run + Command outputs in proof section

### Proof to collect
- [✅] Command outputs (paste snippets into docs)
- [✅] Screenshots (Azure portal / browser TLS)
- [✅] Workflow run links

### Risks / blockers
- (lack of time)

## Next 2 Weeks (preview)
- Week 02: **Outcome:** AKS + ACR created by Terraform (minimal), kubectl access documented.
- Week __: 

### Lessons (Week 01)
- OIDC federation is strict: issuer/subject/audience must match exactly (environment subject mismatch caused AADSTS700213).
- Terraform won’t manage existing resources unless imported; importing avoids destructive “delete & recreate”.
- Remote state is mandatory for collaboration and CI, and prevents local-state drift.
- PLAN vs APPLY identities. Reduced risks from PRs from forks (untrusted code) for my public repo by:
	Trust boundary in workflow: only run cloud-auth steps for same-repo PRs; forks run only fmt/validate (no Azure login).
	Least privilege in Azure: separate identities:
		PLAN identity: read-only (Reader on prod RG + state access only).
		APPLY identity: higher privilege (Contributor), and only usable behind manual approval via GitHub Environments.
- Terraform listKeys vs use_azuread_auth=true. key-based auth needs extra permissions, use_azuread_auth=true forces the backend to use Azure AD auth.
