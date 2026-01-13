\# Project Status — Azure Web Platform (AKS + Terraform + GitHub Actions)



\## Snapshot

\- \*\*Repo:\*\* https://github.com/KiladzeGiga/Azure-project

\- \*\*Goal:\*\* Interview-grade portfolio showing ownership: IaC, CI/CD, TLS, autoscaling, zero-downtime deploys, observability.

\- \*\*Time budget:\*\* 4–5h/week

\- \*\*Budget:\*\* $50–$100/month

\- \*\*Environment model:\*\* Single “prod” env with manual approval gate (GitHub Environments)



\## Current Milestone

\- \*\*Milestone:\*\* M1 — Terraform foundations (remote state + OIDC + plan/apply gates)

\- \*\*Status:\*\* ✅ Done

\- \*\*Proof:\*\* (https://github.com/KiladzeGiga/Azure-project/actions/runs/20956477711/job/60224768765 / .\\assets\\week-01\\Azure subscription Activity log.png / .\\assets\\week-01\\tfs state in Azure storage.png / .\\assets\\week-01\\Manual approve.png)



\## What’s Done (evidence-first)

\- \[✅] Terraform remote backend (azurerm) configured

\- \[✅] GitHub Actions OIDC login works (no long-lived secrets)

\- \[✅] PR runs `terraform fmt/validate/plan`

\- \[✅] main runs `terraform apply` behind manual approval

\- \[✅] Manual resource import handled (import vs recreate) documented



\## Current Architecture (tiny, production-like)

\- \*\*IaC:\*\* Terraform

\- \*\*CI/CD:\*\* GitHub Actions

\- \*\*Target platform:\*\* AKS

\- \*\*App delivery:\*\* Helm

\- \*\*Ingress/TLS:\*\* NGINX Ingress + cert-manager + Let’s Encrypt DNS-01 via Azure DNS

\- \*\*Observability:\*\* Azure Monitor / Log Analytics (Container insights)



\## ADR Index

\- ADR-000 Goals \& constraints — (link)

\- ADR-001 AKS vs ACA — (link)

\- ADR-002 Terraform vs Bicep — (link)

\- ADR-003 Ingress/TLS strategy — (link)

\- ADR-004 Deployment strategy (zero downtime) — (link)



\## Acceptance Criteria (must be provable)

\- \*\*TLS:\*\* cert issued automatically + proof commands/screens

\- \*\*Autoscaling:\*\* HPA scales 2→6 under load + proof output

\- \*\*Zero downtime:\*\* 0 failed requests during deploy + probe script evidence



\## This Week Plan (Week 01)

\*\*Outcome:\*\* configured Terraform foundations (remote state + OIDC + plan/apply gates)



\### Tasks (4–5h max)

1\) \[✅] remote state — expected output artifact

2\) \[✅] OIDC — expected output artifact

3\) \[✅] plan/apply gates — expected output artifact



\### Proof to collect

\- \[✅] Command outputs (paste snippets into docs)

\- \[✅] Screenshots (Azure portal / browser TLS)

\- \[✅] Workflow run links



\### Risks / blockers

\- (What might stop you this week)



\## Next 2 Weeks (preview)

\- Week \_\_: …

\- Week \_\_: …



\## Notes / Lessons

\- What broke?
incorrectly created GitHub variables and federated.json

\- What you changed?

deleted incorrect ones and recreated with correct values

\- What you learned (1–3 bullets)

how to connect AZ with GitHub not ignoring best practices 



