# Week 04 — Ingress and TLS Plan

## Problem
The application currently runs inside AKS and is reachable only through an internal ClusterIP Service.

This proves the app works inside the cluster, but it is not enough for a marketplace platform because users, browsers, and external monitoring cannot reach the app from the internet.

## Goal
Expose the application publicly over HTTPS using a stable DNS name.

Target flow:

Internet user → DNS → static public IP → ingress-nginx → Kubernetes Service → app pod

## Current state
- App runs in AKS.
- App is deployed by Helm.
- App has a ClusterIP Service.
- CI proves health from inside the cluster using a temporary curl pod.
- No public HTTP/HTTPS endpoint exists yet.

## Options considered

### Option 1 — kubectl port-forward
Useful for local debugging only. Not a real hosting solution.

### Option 2 — Service type LoadBalancer
Simple for one service, but does not scale well for multiple services because each service may need its own public IP and routing/TLS becomes messy.

### Option 3 — Ingress Controller
Provides one public entry point and can route traffic to multiple services based on host/path.

Example:
- shop.gkiladze.space → frontend
- api.gkiladze.space/products → product-api
- api.gkiladze.space/orders → order-api

### Option 4 — Azure Application Gateway
More Azure-native and enterprise-friendly, but more complex and not necessary for the first version of the platform.

## Decision
Use ingress-nginx first.

Reasons:
- cheap enough for a learning project
- standard Kubernetes pattern
- teaches Ingress, routing, annotations, TLS, Services
- portable across clouds
- good fit before moving to more Azure-specific options

## Ownership model

### Terraform owns
- static public IP
- future DNS records
- future identity/RBAC required for DNS automation

### Platform deployment owns
- ingress-nginx installation
- cert-manager installation later

### App Helm chart owns
- Ingress rules for the app
- hostname/path routing
- TLS secret reference

### GitHub Actions owns
- automation flow
- verification steps

## Implementation phases

### Phase 1 — Static public IP
Create a Terraform-managed static public IP for ingress.

Proof:
- Terraform apply succeeded.
- Static ingress public IP created by Terraform.
- Outputs added:
ingress_public_ip = "20.126.28.109"
ingress_public_ip_id = "/subscriptions/d5f8aa68-aa66-4608-b915-02a8051662e1/resourceGroups/rg-azproj-prod/providers/Microsoft.Network/publicIPAddresses/pip-azproj-ingress"

### Phase 2 — Install ingress-nginx
Install ingress-nginx using Helm and bind it to the static public IP.

Proof:
- Terraform plan/apply succeeded after importing the existing AKS Network Contributor role assignment.
- Terraform now manages:
  - static ingress public IP
  - AKS identity `Network Contributor` role on `rg-azproj-prod`
- `platform-ingress` workflow succeeded.
- ingress-nginx installed by Helm in namespace `ingress-nginx`.
- ingress-nginx controller rolled out successfully.
- Static public IP bound successfully:
  - Expected IP: `20.126.28.109`
  - Actual IP: `20.126.28.109`

## Issue found
AKS could not bind the Terraform-created public IP because the AKS cloud controller identity lacked permission to read/manage public IPs in `rg-azproj-prod`.

## Fix
Granted the AKS system-assigned identity `Network Contributor` on `rg-azproj-prod` and imported the existing manual role assignment into Terraform state.

### Phase 3 — Add app Ingress
Update the app Helm chart to create an Ingress rule.

Proof:
- `app-build-push` workflow succeeded.
- App Helm chart now creates an Ingress resource.
- Ingress routes public HTTP traffic through ingress-nginx to the `azproj-api` Service.
- Public HTTP proof succeeded:
  - `http://20.126.28.109/healthz`
  - `PUBLIC_HTTP_PROOF=http_200`

### Phase 4 — Add DNS
Point a DNS record to the ingress public IP.

Proof:
- hostname resolves to the public IP.

### Phase 5 — Add TLS
Install cert-manager and issue a certificate.

Proof:
- HTTPS works.
- Certificate resource is Ready.
- curl/browser confirms TLS.