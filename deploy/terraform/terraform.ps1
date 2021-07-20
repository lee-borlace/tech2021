param ([bool] $apply = $false)

terraform init -no-color
terraform workspace select test -no-color
terraform init -no-color
terraform validate -no-color

if($apply -eq $True) {
    terraform plan -no-color
}