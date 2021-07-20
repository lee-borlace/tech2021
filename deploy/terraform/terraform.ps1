param ([string] $github_ref)

terraform init -no-color
terraform workspace select test -no-color
terraform init -no-color
terraform validate -no-color
terraform plan -no-color

if($github_ref -eq "refs/heads/master") {
    Write-Host "Called from master branch, applying."
    terraform apply -no-color -input=false -auto-approve
} else {
    Write-Host "Not called from master branch, not applying."
}
