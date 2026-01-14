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
- GitHub Actions apply run (OIDC + approval gate): https://github.com/KiladzeGiga/Azure-project/actions/runs/20956477711/job/60224768765
- Manual approval gate: [screenshot](./assets/week-01/manual-approval.png)
- Remote state in Azure Storage: [screenshot](./assets/week-01/subscription-activity-log.png)
- Subscription activity log: [screenshot](./assets/week-01/tfstate-in-storage.png)
- azurerm: (.\Azure-project\infra\live\prod\.terraform\terraform.tfstate)
- PR runs tf-plan: https://github.com/KiladzeGiga/Azure-project/pull/2
- import vs recreate - (./state-import.md)

## What’s Done (evidence-first)
- [✅] Terraform remote backend (azurerm) configured - terraform.tfstate (link above)
- [✅] GitHub Actions OIDC login works (no long-lived secrets) - proof: workflow run link above
- [✅] PR runs `terraform fmt/validate/plan` - proof: PR link above
- [✅] main runs `terraform apply` behind manual approval - proof: approval screenshot + run link
- [✅] Manual resource import handled (import vs recreate) documented - state-import.md + run link

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
- ADR-002 Terraform vs Bicep — (link)
- ADR-003 Ingress/TLS strategy — (link)
- ADR-004 Deployment strategy (zero downtime) — (link)

## Acceptance Criteria (must be provable)
- **TLS:** cert issued automatically + proof commands/screens
- **Autoscaling:** HPA scales 2→6 under load + proof output
- **Zero downtime:** 0 failed requests during deploy + probe script evidence

## This Week Plan (Week 01)
**Outcome:** configured Terraform foundations (remote state + OIDC + plan/apply gates)

### Tasks (4–5h max)
1) [✅] create documantations — ./docs directory
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
