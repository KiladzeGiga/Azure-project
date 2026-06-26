* Ingress: NGINX Ingress (simple, common)
* TLS: cert-manager + Let’s Encrypt via DNS-01 using Azure DNS (strong signal: real cert automation) 
* CI/CD: GitHub Actions
* Auth: GitHub Actions → Azure via OIDC (no long-lived secret)
* Autoscaling: HPA + (optional) cluster autoscaler
* Observability: Azure Monitor / Log Analytics (Container Insights)
