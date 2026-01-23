\# Destroy / Recreate Runbook (Cost-Control Mode)

If I’m not actively working: destroy the cluster the same day.

\## Goal

Keep monthly cost low by destroying AKS + ACR between sessions while keeping Terraform remote state intact.



\## What must survive

\- `rg-azproj-tfstate` (Terraform backend RG)

\- Storage account + container holding `prod.terraform.tfstate`



\## What is safe to destroy

\- `rg-azproj-prod` (AKS, ACR, networking created for the platform)



\## Commands (PowerShell)



\### Create / Update

```powershell

cd infra/live/prod

terraform init -reconfigure

terraform apply -auto-approve



