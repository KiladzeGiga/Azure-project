# Cloud-Native Marketplace Platform

## Goal
Build and operate a small marketplace-style platform to demonstrate Cloud DevOps engineering skills: infrastructure automation, CI/CD, Kubernetes deployment, routing, TLS, data services, autoscaling, monitoring, and incident response.

## Product scope
The application is intentionally small. The goal is not to build a full e-commerce product, but to create enough real application behavior to make platform decisions meaningful.

## Services
- `frontend`: simple web UI for browsing products and creating orders
- `product-api`: returns product catalog data
- `order-api`: creates and reads orders

## Core user flows
1. User opens the frontend.
2. Frontend calls Product API to list products.
3. User creates an order.
4. Order API stores the order in a managed database.
5. Platform exposes health/version endpoints for deployment verification and operations.

## Platform capabilities to demonstrate
- Terraform-managed cloud infrastructure
- OIDC-based CI/CD authentication
- Container build and push to registry
- Helm-based Kubernetes deployment
- Ingress routing and HTTPS
- Managed database and cache
- Autoscaling under load
- Observability and alerting
- Failure drills and incident notes
- Cost-aware destroy/recreate workflow

## Non-goals
- Full e-commerce functionality
- Payment processing
- User authentication
- Complex frontend design
- Production-scale architecture