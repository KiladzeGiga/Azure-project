measurable acceptance criteria:

**1. TLS / certificates**



* A new hostname gets a valid cert automatically (cert-manager).
* Proof: kubectl describe certificate shows Ready=True; browser shows a valid chain.
* Renewal is configured (you don’t need to wait 60 days—just show the controller + config).
* kubectl get issuer,clusterissuer
* kubectl describe certificate <name> shows Ready=True
* kubectl describe challenge shows DNS-01 success (or equivalent)
* Screenshot: browser lock icon + cert issuer



**2. Autoscaling that actually works**



* HPA scales your Deployment from 2 → 6 pods under load within 5 minutes.
* Proof: kubectl get hpa shows current replicas rising; events show scaling decisions.
* Cluster Autoscaler scales nodes only if needed (when pods are Pending due to insufficient resources). Microsoft explicitly separates HPA (pods) and cluster autoscaler (nodes).
* You demonstrate it with a load test + resource requests set (no requests = autoscaling is meaningless).
* kubectl get hpa -w output captured
* kubectl top pods captured
* Load test command + duration + target RPS
* Note: if pods go Pending, explain if/why cluster autoscaler acted



**3. Zero-downtime deploys**



* During helm upgrade, a continuous probe (curl loop) shows 0 failed requests (no 5xx, no connection errors) for a 3–5 minute window.
* You enforce this with: readiness probe, rolling update strategy (maxUnavailable=0), and graceful termination.
* your probe script output (0 failures) during helm upgrade
* deployment strategy snippet (maxUnavailable=0, maxSurge=1) referenced
