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
- Terraform output shows ingress public IP.

### Phase 2 — Install ingress-nginx
Install ingress-nginx using Helm and bind it to the static public IP.

Proof:
- ingress-nginx controller Service has the expected external IP.

### Phase 3 — Add app Ingress
Update the app Helm chart to create an Ingress rule.

Proof:
- HTTP request reaches the app through the public IP/host.

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