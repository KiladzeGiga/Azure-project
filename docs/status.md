# Project Status — Cloud-Native Marketplace Platform

## Snapshot

* **Repo:** https://github.com/KiladzeGiga/Azure-project
* **Goal:** Build an interview-grade Cloud DevOps portfolio project showing real platform ownership: Infrastructure as Code, CI/CD, Kubernetes deployment, ingress, TLS, scaling, rollout safety, and observability.
* **Time budget:** 4–5h/week
* **Budget:** $50–$100/month
* **Environment model:** Single `prod` environment with GitHub Environment approval gate.

## Current Milestone

* **Milestone:** Week 04 — Public HTTPS ingress
* **Status:** ✅ Done

## Current Platform Capabilities

The platform currently supports:

* Infrastructure provisioning with Terraform.
* Remote Terraform state in Azure Storage.
* GitHub Actions authentication to Azure using OIDC.
* Separate PLAN and APPLY identities.
* Manual approval gate before production infrastructure apply.
* AKS cluster provisioned by Terraform.
* ACR provisioned by Terraform.
* Application image build and push to ACR.
* Helm-based application deployment to AKS.
* ingress-nginx installed as the public ingress controller.
* Static Azure Public IP for ingress.
* Azure DNS A record for `api.gkiladze.space`.
* cert-manager installed in the cluster.
* Let’s Encrypt production TLS certificate issued automatically.
* Public HTTPS proof for the API health endpoint.
* Safer rolling deployments with readiness/liveness probes, graceful termination, and continuous public HTTPS proof.

## Current Public Endpoint

```text
https://api.gkiladze.space/healthz
```

Expected result:

```text
healthy
```

## Current Request Path

```text
Client
→ Azure DNS: api.gkiladze.space
→ Static Azure Public IP
→ Azure Load Balancer
→ ingress-nginx
→ Kubernetes Ingress
→ azproj-api Service
→ azproj-api Pod
```

## Proof — Week 01

* Apply run with OIDC and approval gate: https://github.com/KiladzeGiga/Azure-project/actions/runs/20956477711/job/60224768765
* PR plan run: https://github.com/KiladzeGiga/Azure-project/actions/runs/21065338584
* PR apply run: https://github.com/KiladzeGiga/Azure-project/actions/runs/21065340426
* Manual approval gate: [screenshot](./assets/week-01/manual-approval.png)
* Remote state exists in Azure Storage: [screenshot](./assets/week-01/tfstate-in-storage.png)
* Subscription activity log: [screenshot](./assets/week-01/subscription-activity-log.png)
* Import vs recreate documented: [state-import](./operations/state-import.md)

## Proof — Week 02

* Terraform plan run for ACR and AKS: https://github.com/KiladzeGiga/Azure-project/actions/runs/21285576850/job/61265788044
* Terraform apply run for ACR and AKS: https://github.com/KiladzeGiga/Azure-project/actions/runs/21285627844/job/61265959167
* AKS node access proven with `kubectl get nodes`.
* Kubernetes namespaces verified:
  * `default`
  * `kube-node-lease`
  * `kube-public`
  * `kube-system`
* `az aks get-credentials` tested successfully.
* Destroy drill completed:

  * `terraform destroy` removed `rg-azproj-prod`.
  * Post-destroy verification with `az aks list` and `az acr list` returned `ResourceGroupNotFound`, as expected.
* Kubernetes control plane access verified with `kubectl cluster-info`.

## Proof — Week 03

* App build, push, and Helm deploy workflow: https://github.com/KiladzeGiga/Azure-project/actions/runs/21391990192/job/61580884028
* Image pushed to ACR:
  * `acrpkje3k.azurecr.io/azproj-api:07b42e3b6f387ab0a8828334aa9ef96c1daf5d16`
* Rollout verified:
  * `deployment "azproj-api" successfully rolled out`
* In-cluster health proof through Kubernetes Service DNS:
  * `"healthy"`

## Proof — Week 04

### Phase 1 — Static ingress IP

* Terraform created a static public IP for ingress.
* Public IP:

  * `20.126.28.109`

### Phase 2 — ingress-nginx

* `platform-ingress` workflow succeeded.
* ingress-nginx installed by Helm into the `ingress-nginx` namespace.
* ingress-nginx Service type:

  * `LoadBalancer`
* Static public IP successfully bound to ingress-nginx:

  * `20.126.28.109`

### Phase 3 — Public HTTP ingress

* App Helm chart creates a Kubernetes Ingress resource.
* Ingress routes public HTTP traffic through ingress-nginx to the `azproj-api` Service.
* Public HTTP proof succeeded:

  * `http://20.126.28.109/healthz`
  * `PUBLIC_HTTP_PROOF=http_200`

### Phase 4 — DNS-based HTTP ingress

* Terraform created Azure DNS A record:

  * `api.gkiladze.space` → `20.126.28.109`
* App Ingress uses host-based routing:

  * Host: `api.gkiladze.space`
  * Path: `/`
  * Backend: `azproj-api:8080`
* Public DNS HTTP proof succeeded:

  * `http://api.gkiladze.space/healthz`
  * `PUBLIC_DNS_HTTP_PROOF=http_200`

### Phase 5 — Staging TLS

* cert-manager installed successfully.
* Let’s Encrypt staging `ClusterIssuer` created successfully.
* Ingress TLS enabled for:

  * `api.gkiladze.space`
* cert-manager created certificate:

  * `azproj-api-tls`
* HTTP redirects to HTTPS:

  * `PUBLIC_DNS_HTTP_PROOF=http_308`
* Staging HTTPS proof succeeded:

  * `PUBLIC_STAGING_HTTPS_PROOF=http_200`

### Phase 6 — Production TLS

* Switched TLS from Let’s Encrypt staging to Let’s Encrypt production.
* Production `ClusterIssuer` created:

  * `letsencrypt-prod`
* Production ACME server configured:

  * `https://acme-v02.api.letsencrypt.org/directory`
* Ingress TLS enabled for:

  * `api.gkiladze.space`
* Production HTTPS proof succeeded:

  * `https://api.gkiladze.space/healthz`
  * `PUBLIC_PROD_HTTPS_PROOF=http_200`
* HTTPS works without `curl -k`.

## Proof — Week 05

- Added deployment safety settings to the Helm chart:
  - `replicaCount: 2`
  - `readinessProbe`
  - `livenessProbe`
  - rolling update strategy:
    - `maxUnavailable: 0`
    - `maxSurge: 1`
  - `PodDisruptionBudget`
  - `minReadySeconds: 10`
  - graceful shutdown with `preStop` delay
  - `terminationGracePeriodSeconds: 30`
- Added continuous public HTTPS probe during deployment.
- Initial zero-downtime proof found a real rollout gap:
  - one request returned `status=000`
- Fixed rollout behavior with readiness/graceful termination settings.
- Final app deployment succeeded.
- Zero-downtime proof succeeded:
  - `ZERO_DOWNTIME_PROOF=no_failed_requests`

## Issues Found and Fixed

### AKS could not bind Terraform-created public IP

**Problem:**
ingress-nginx could not bind the static public IP because the AKS cloud controller identity did not have permission to manage public IPs in `rg-azproj-prod`.

**Fix:**
Granted the AKS system-assigned identity `Network Contributor` on `rg-azproj-prod` and imported the role assignment into Terraform state.

### Public DNS endpoint timed out after host-based Ingress

**Problem:**
DNS and Ingress were correct, but public traffic timed out.

**Fix:**
Updated ingress-nginx Service configuration so Azure Load Balancer health checks could succeed:

* `externalTrafficPolicy=Local`
* Azure Load Balancer health probe request path annotation
* Azure public IP resource group annotation

### ACME registration failed

**Problem:**
cert-manager failed to register the ACME account because the configured email value was invalid.

**Fix:**
Set a valid ACME contact email and reset Helm values during deployment.

### HTTP proof failed after TLS was enabled

**Problem:**
The HTTP proof expected `200`, but after TLS was enabled, HTTP returned `308` redirect to HTTPS.

**Fix:**
Updated the proof logic to accept HTTP `308` and added a separate HTTPS proof.

## What’s Done

* [x] Remote Terraform state in Azure Storage.
* [x] GitHub Actions plan/apply workflow.
* [x] GitHub Environment approval gate.
* [x] Public repo hardening with separated PLAN/APPLY identities.
* [x] ACR created by Terraform.
* [x] AKS created by Terraform.
* [x] Destroy/recreate drill completed.
* [x] Docker image built in CI.
* [x] Docker image pushed to ACR.
* [x] App deployed to AKS with Helm.
* [x] In-cluster Service DNS health proof.
* [x] Static ingress public IP created by Terraform.
* [x] ingress-nginx installed by Helm.
* [x] Azure DNS record created for `api.gkiladze.space`.
* [x] Host-based Kubernetes Ingress configured.
* [x] cert-manager installed.
* [x] Let’s Encrypt staging TLS proven.
* [x] Let’s Encrypt production TLS proven.
* [x] Public HTTPS endpoint proven.
* [x] Zero-downtime deployment: deployment completes with no failed requests.

## Current Architecture

* **Cloud:** Azure
* **IaC:** Terraform
* **CI/CD:** GitHub Actions
* **Container registry:** Azure Container Registry
* **Runtime platform:** Azure Kubernetes Service
* **App delivery:** Helm
* **Ingress:** ingress-nginx
* **DNS:** Azure DNS
* **TLS automation:** cert-manager
* **Certificate authority:** Let’s Encrypt
* **ACME challenge type:** HTTP-01 through ingress-nginx

## ADR Index

* [ADR-000 — Goals and constraints](./adr/ADR-000-goals-and-constraints.md)
* [ADR-001 — Platform choice: AKS vs ACA](./adr/ADR-001-platform-choice-aks-vs-aca.md)
* ADR-002 — Terraform vs Bicep — Planned
* ADR-003 — Ingress/TLS strategy — Planned
* ADR-004 — Deployment strategy and zero downtime — Planned

## Acceptance Criteria

The project is not complete until these are proven:

* [x] Public HTTPS endpoint works with valid production TLS.
* [ ] Autoscaling: HPA scales the app under load.
* [ ] Zero-downtime deployment: deployment completes with no failed requests.
* [ ] Observability: logs/metrics/traces can be used to debug a real failure.
* [ ] Operational runbook exists for common failure scenarios.

## Next Milestones

### Week 05 — Deployment safety

Goal:

```text
Deploy new app versions without downtime.
```

Planned work:

* Add readiness and liveness probes.
* Add rolling update settings.
* Add multiple replicas.
* Prove rollout with continuous requests.
* Document zero-downtime deployment evidence.

### Week 06 — Autoscaling

Goal:

```text
Scale the app based on load.
```

Planned work:

* Add resource requests and limits.
* Install or verify metrics-server.
* Add HPA.
* Generate load.
* Prove scaling from 2 replicas upward.

### Week 07 — Observability

Goal:

```text
Debug the platform using logs and metrics, not guessing.
```

Planned work:

* Enable useful AKS/container logs.
* Add structured app logs.
* Query logs during a controlled failure.
* Document troubleshooting workflow.

## Lessons Learned

* OIDC federation is strict: issuer, subject, and audience must match exactly.
* Terraform does not manage existing resources unless they are imported.
* Remote state is required for CI-based Terraform workflows.
* PLAN and APPLY identities reduce risk in a public repository.
* GitHub Environment approval protects production apply operations.
* AKS cloud-controller permissions matter when binding static public IPs.
* DNS can be correct while traffic still fails because of Load Balancer health probes.
* Host-based Ingress changes routing behavior compared with hostless Ingress.
* cert-manager separates issuer readiness, certificate creation, ACME orders, and challenges.
* Staging certificates should be used before production Let’s Encrypt.
* After TLS is enabled, HTTP may correctly return `308` instead of `200`.
