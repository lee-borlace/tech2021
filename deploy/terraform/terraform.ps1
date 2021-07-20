param ([string] $github_ref)

Write-Host "***********************************************"
Write-Host "Main init"
Write-Host "***********************************************"
terraform init -no-color

Write-Host "***********************************************"
Write-Host "Workspace select"
Write-Host "***********************************************"
terraform workspace select test -no-color

Write-Host "***********************************************"
Write-Host "Workspace init"
Write-Host "***********************************************"
terraform init -no-color

Write-Host "***********************************************"
Write-Host "Validate"
Write-Host "***********************************************"
terraform validate -no-color

Write-Host "***********************************************"
Write-Host "Plan"
Write-Host "***********************************************"
terraform plan -no-color

if($github_ref -eq "refs/heads/master") {
    Write-Host "***********************************************"
    Write-Host "Called from master branch, applying."
    Write-Host "***********************************************"

    terraform apply -no-color -input=false -auto-approve
} else {
    Write-Host "***********************************************"
    Write-Host "Not called from master branch, not applying."
    Write-Host "***********************************************"
}
