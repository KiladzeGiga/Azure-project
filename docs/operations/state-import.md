# State Import: Existing Resource Group

## Problem
`terraform apply` failed because `rg-azproj-prod` already existed (created manually). Terraform refused to create it and required import.

## Decision
Import the existing RG into Terraform state instead of deleting/recreating it to avoid destructive changes and align with safe IaC ownership.

## Commands (PowerShell)
powershell
# reconfigure backend to ensure we target the remote state
PS C:\Users\gkiladze\source\github repos\Azure-project\infra\live\prod> terraform init -reconfigure `
>>   -backend-config="resource_group_name=rg-azproj-tfstate" `
>>   -backend-config="storage_account_name=stazprojbn0pn1" `
>>   -backend-config="container_name=tfstate" `
>>   -backend-config="key=prod.terraform.tfstate"
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.117.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

# import existing RG
PS C:\Users\gkiladze\source\github repos\Azure-project\infra\live\prod> terraform import azurerm_resource_group.prod "/subscriptions/$subId/resourceGroups/rg-azproj-prod"
Acquiring state lock. This may take a few moments...
azurerm_resource_group.prod: Importing from ID "/subscriptions/d5f8aa68-aa66-4608-b915-02a8051662e1/resourceGroups/rg-azproj-prod"...
azurerm_resource_group.prod: Import prepared!
  Prepared azurerm_resource_group for import
azurerm_resource_group.prod: Refreshing state... [id=/subscriptions/d5f8aa68-aa66-4608-b915-02a8051662e1/resourceGroups/rg-azproj-prod]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

Releasing state lock. This may take a few moments...

# verify
PS C:\Users\gkiladze\source\github repos\Azure-project\infra\live\prod> terraform state list
PS C:\Users\gkiladze\source\github repos\Azure-project\infra\live\prod> $subId = "d5f8aa68-aa66-4608-b915-02a8051662e1"

PS C:\Users\gkiladze\source\github repos\Azure-project\infra\live\prod> terraform plan
Acquiring state lock. This may take a few moments...
azurerm_resource_group.prod: Refreshing state... [id=/subscriptions/d5f8aa68-aa66-4608-b915-02a8051662e1/resourceGroups/rg-azproj-prod]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
Releasing state lock. This may take a few moments...
