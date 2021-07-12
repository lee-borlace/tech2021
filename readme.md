# Terraform to Azure Local
https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started

`choco install terraform`

`az login`

`terraform init`

`terraform fmt`

`terraform validate`

`terraform apply -var-file ".\environments\dev.tfvars"`

# Terraform to Azure via GitHub
Started with this : https://thomasthornton.cloud/2021/03/19/deploy-terraform-using-github-actions-into-azure/

However it appears that it's obsolete and has been superseded by this : https://github.com/hashicorp/setup-terraform

This uses a single blob container for the Terraform backend. This is because the terraform file doesn't allow variables in the backend section - so you can't have different back ends for different environments. So test, stage, prod all share the same container but with different folders - not ideal! TODO : In future, would it make sense to use Terraform Cloud as the backend? Does that give the advantage of environmental separation?

## Create the resource group
Note that although we could have let Terraform do this, we want to set it up here first so that when we create a service principal later, we can just grant it access to the RG.

`az group create -n lee-syd-tst-arg-rwa -l australiaeast`

## Create storage for holding terraform state
This will be shared for all environments.

Create storage and container

```
az group create -n lee-syd-all-arg-rwaterra -l australiaeast
az storage account create -n leesydallstarwaterra -g lee-syd-all-arg-rwaterra -l australiaeast --sku Standard_LRS
az storage container create -n terrastate --account-name leesydallstarwaterra
```

TODO : In future, look at whether we can turn off shared keys via the following for extra security.

`az storage account update --name leesydallstarwaterra --resource-group lee-syd-all-arg-rwaterra --allow-shared-key-access false`    

## Create service principal for deployments

Create service principal - note that this doesn't assign any permissions, especially not the default subscription perms!

`az ad sp create-for-rbac --name lee-syd-tst-spr-rwaterra --skip-assignment`

Take note of the resulting client ID, secret etc and store somewhere out of source control.

## Add permissions to resources for the service principal

Note that these need the object ID of the service principal not the application ID!

### Storage

See here for info on blob permissions : 
https://docs.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=portal 
https://docs.microsoft.com/en-us/azure/storage/blobs/authorize-data-operations-portal
https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage

It seems that you need to add a role for the service principal which has this action : *Microsoft.Storage/storageAccounts/listkeys/action*. This will allow the account to retrieve the keys which it would then use to actually access the data.

It seems these are the roles (with increasing power) which allow this :

- The Reader and Data Access role
- The Storage Account Contributor role
- The Azure Resource Manager Contributor role
- The Azure Resource Manager Owner role

Add the service principal to storage container. We'll use the 1st role above for minimum permissions, and we'll add it at the storage account level :

`az role assignment create --assignee-principal-type ServicePrincipal --role "Reader and Data Access" --assignee-object-id aae1e7e4-68f8-4c7a-91d9-4eb4143a1095 --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-all-arg-rwaterra/providers/Microsoft.Storage/storageAccounts/leesydallstarwaterra"`

### Resource Group

`az role assignment create --assignee-principal-type ServicePrincipal --role "Contributor" --assignee-object-id aae1e7e4-68f8-4c7a-91d9-4eb4143a1095 --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-tst-arg-rwaterra"`

## Set up variables in relevant environment for the deployment service principal
We need to tell GH about the service principal so it can use it to deploy. Set up these for each environment, and plug in the details from our service principal.

AZURE_AD_CLIENT_ID – Will be the service principal ID from above
AZURE_AD_CLIENT_SECRET – The secret that was created as part of the Azure Service Principal
AZURE_AD_TENANT_ID – The Azure AD tenant ID to where the service principal was created
AZURE_SUBSCRIPTION_ID – Subscription ID of where you want to deploy the Terraform

## Set up workspace in remote backend
Before the workflow will work OK, need to set up workspaces in the backend.

TODO : In future, can this part happen as part of the workflow? I.e. check if workspace exists and if not create it, otherwise switch to it.

```
terraform workspace new test
terraform workspace new stage
terraform workspace new prod
```

## Variable files
Variable files are gitignored. Don't check them in, and find other ways of injecting the values - via environment variables.
