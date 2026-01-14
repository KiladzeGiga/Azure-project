# ADR-000: Goals and Constraints

**Status:** Accepted  
**Date:** 2026-01-14  
**Owner:** Gigla Kiladze  
**Scope:** This repository / portfolio project only

## Context
I’m building a portfolio project to compensate for limited on-the-job ownership/architecture experience. The project must demonstrate interview-relevant DevOps/Platform skills with real proof (pipelines, IaC, runbooks), not “tutorial completion”.

## Goals (what success looks like)
1. **IaC ownership:** Infrastructure is reproducible from scratch using Terraform with remote state and CI gates.
2. **Safe delivery:** CI builds/pushes images and CD deploys to Kubernetes with a rollback story.
3. **Operations:** Monitoring/logs exist and I can debug a failure using a written runbook.
4. **Core platform features (web scenario):** Ingress + automated TLS + autoscaling + zero-downtime deploy proof.

## Non-goals (explicitly out of scope)
- Multi-region, DR, or high availability beyond basic multi-replica in a single region.
- Stateful databases and persistent storage (stateless app only for now).
- Service mesh, advanced traffic shaping (full canary), or GitOps (Argo/Flux).
- Full security hardening (policy engines, SIEM integration). Basic RBAC + secrets strategy only.
- Building a “platform for multiple teams”; this is a single app platform MVP.

## Constraints
- **Time:** 4–5 hours/week maximum.
- **Budget:** $50–$100/month → must be destroyable and cost-aware.
- **Skill gaps to address:** Kubernetes ops, Terraform patterns/state, Linux basics.
- **Evidence requirement:** Every claim must be backed by proof in repo (workflow run, command output, screenshot).

## Key decisions forced by constraints
- Single environment (“prod”) with manual approval gate instead of full multi-env (time/budget).
- Minimal AKS footprint (small nodepool, limited add-ons).
- Observability uses Azure-native tooling first to reduce setup overhead.

## Acceptance criteria (verifiable)
- **TLS automation:** cert-manager issues a valid cert automatically via DNS-01; proof via `kubectl describe certificate` + browser screenshot.
- **Autoscaling:** HPA scales from 2→6 pods under load within 5 minutes; proof via `kubectl get hpa -w` + load test command/output.
- **Zero-downtime deploy:** 0 failed requests during `helm upgrade` measured by a probe script; proof output committed.
- **CI/CD discipline:** PR runs `terraform plan`, main requires approval for `apply`.

## Consequences
- Project will not look “enterprise big”, but it will look “production real” and explainable.
- Some Azure-native alternatives (e.g., ACA, Bicep) are intentionally not used to maximize interview signal for K8s/Terraform roles.
