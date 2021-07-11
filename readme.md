# Terraform to Azure Local
https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started

`choco install terraform`

`az login`

`terraform init`

`terraform fmt`

`terraform validate`

`terraform apply -var-file ".\environments\test.tfvars"`

# Terraform to Azure via GitHub
https://thomasthornton.cloud/2021/03/19/deploy-terraform-using-github-actions-into-azure/

## Create the resource group
Note that although we could have let Terraform do this, we want to set it up here first so that when we create a service principal later, we can just grant it access to the RG.

`az group create -n lee-syd-tst-arg-rwa -l australiaeast`

## Create storage for holding terraform state
Do this for each environment

Create storage and container

```
az group create -n lee-syd-tst-arg-rwaterra -l australiaeast
az storage account create -n leesydtststarwaterra -g lee-syd-tst-arg-rwaterra -l australiaeast --sku Standard_LRS
az storage container create -n terrastate --account-name leesydtststarwaterra
```

Turn off "Allow shared key access" for the storage account via configuration, so that only Azure AD-authorised requests may work. Note may need to update the az module via `az upgrade` first before this command will work.

TODO : May need to remove this point. In a later step I added explicit service principal access via Storage Blob Data Owner but I believe that may not work. May need to instead leave shared keys on, and add a perm at the storage level which includes *Microsoft.Storage/storageAccounts/listKeys/action* at the storage account level. As per https://docs.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=portal

`az storage account update --name leesydtststarwaterra --resource-group lee-syd-tst-arg-rwaterra --allow-shared-key-access false`    

## Create service principal for deployments

Create service principal - note that this doesn't assign any permissions, especially not the default subscription perms!

`az ad sp create-for-rbac --name lee-syd-tst-spr-rwaterra --skip-assignment`

Take note of the resulting client ID, secret etc and store somewhere out of source control.

## Add permissions to resources for the service principal

Note that these need the object ID not the application ID!

https://docs.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=portal

First need to add ourself to the storage account because we turned off shared access keys. Without this, you'll get errors in the portal.

`az role assignment create --role "Storage Blob Data Owner" --assignee lee@lee79.onmicrosoft.com --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-tst-arg-rwaterra/providers/Microsoft.Storage/storageAccounts/leesydtststarwaterra"`

Now add the service principal to storage container :

`az role assignment create --assignee-principal-type ServicePrincipal --role "Storage Blob Data Contributor" --assignee-object-id aae1e7e4-68f8-4c7a-91d9-4eb4143a1095 --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-tst-arg-rwaterra/providers/Microsoft.Storage/storageAccounts/leesydtststarwaterra/blobServices/default/containers/terrastate"`

TODO : Note that as noted above it may be needed to instead leave on shared access keys and add something like this at the storage account level as per https://docs.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access?tabs=portal :

`az role assignment create --role "TODO" --assignee-object-id aae1e7e4-68f8-4c7a-91d9-4eb4143a1095 --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-tst-arg-rwaterra/providers/Microsoft.Storage/storageAccounts/leesydtststarwaterra"`

Resource group :

`az role assignment create --assignee-principal-type ServicePrincipal --role "Contributor" --assignee-object-id aae1e7e4-68f8-4c7a-91d9-4eb4143a1095 --scope "/subscriptions/0a9a85bf-2d3c-47c6-bd3f-278487a44732/resourceGroups/lee-syd-tst-arg-rwaterra"`

## Set up variables in relevant environment for the deployment service principal
We need to tell GH about the service principal so it can use it to deploy. Set up these for each environment, and plug in the details from our SP



