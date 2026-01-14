# ADR-001: Platform Choice — AKS vs Azure Container Apps

**Status:** Accepted  
**Date:** 2026-01-14  
**Owner:** Gigla Kiladze

## Context
The target jobs I’m aiming for are remote DevOps/Platform/Cloud roles where Kubernetes knowledge and operating model (deployments, ingress, RBAC, rollout/rollback, autoscaling, observability) is frequently expected. My current job does not provide deep Kubernetes ownership, so this project must generate credible, explainable experience.

## Decision
Use **Azure Kubernetes Service (AKS)** as the primary platform for this project.

## Options considered
### Option A — AKS (managed Kubernetes)
- Pros:
  - Strong interview signal for Platform/DevOps roles.
  - Exposes real operational concepts: ingress, cert-manager, probes, rollout strategy, HPA, RBAC.
  - Portable skills to non-Azure environments.
- Cons:
  - Higher complexity and more “ops surface area”.
  - Higher cost risk if left running.
  - More failure modes to debug.

### Option B — Azure Container Apps (ACA)
- Pros:
  - Faster time to deploy apps; less infrastructure to manage.
  - Built-in scaling and simpler ops for many workloads.
- Cons:
  - Abstracts away Kubernetes details I need to demonstrate.
  - Weaker signal for roles that expect hands-on K8s operations.
  - Harder to show “K8s-native” concepts (Helm, ingress controllers, Kubernetes RBAC) in a credible way.

## Why this decision (tie to constraints + interview signal)
- Primary objective is **interview readiness for K8s/Terraform roles**, not fastest deployment.
- AKS forces practice in areas I’m weak at (K8s ops + Linux tooling) and creates artifacts I can defend.
- Scope will stay minimal to control complexity: single region, small nodepool, single app, evidence-driven milestones.

## Consequences (what gets harder)
- I must actively manage cost and teardown procedures.
- I must build runbooks and proof of troubleshooting (because AKS will break in realistic ways).
- I must separate concerns clearly:
  - App deploy safety (Helm + probes + rolling updates) vs
  - Cluster upgrades (node/cluster lifecycle).

## Validation (how I will prove this was a good choice)
- Repo contains:
  - Terraform that creates AKS + ACR with remote state + CI plan/apply gates.
  - Helm-based deployment with rollback demo.
  - Automated TLS using cert-manager + DNS-01.
  - HPA scaling demo under load.
  - Zero-downtime deploy proof script output.
  - One failure drill + runbook demonstrating debugging steps and fixes.
