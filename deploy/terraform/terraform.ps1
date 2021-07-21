param (
    [string] $github_ref, 
    [string] $workspace
)

    
Write-Host "***********************************************"
Write-Host "Startup"
Write-Host "***********************************************"
Write-Host "Called with these params :"
Write-Host "github_ref=$github_ref"
Write-Host "workspace=$workspace"

Write-Host "***********************************************"
Write-Host "Main init"
Write-Host "***********************************************"
terraform init

if($? -eq $False) {
    exit 1
}

Write-Host "***********************************************"
Write-Host "Workspace select"
Write-Host "***********************************************"
terraform workspace select $workspace

if($? -eq $False) {
    exit 1
}

Write-Host "***********************************************"
Write-Host "Workspace init"
Write-Host "***********************************************"
terraform init

if($? -eq $False) {
    exit 1
}

Write-Host "***********************************************"
Write-Host "Validate"
Write-Host "***********************************************"
terraform validate

if($? -eq $False) {
    exit 1
}

Write-Host "***********************************************"
Write-Host "Plan"
Write-Host "***********************************************"
terraform plan 

if($? -eq $False) {
    exit 1
}

if ($github_ref -eq "refs/heads/master") {
    Write-Host "***********************************************"
    Write-Host "Called from master branch, applying."
    Write-Host "***********************************************"

    terraform apply -input=false -auto-approve

    if($? -eq $False) {
        exit 1
    }
}
else {
    Write-Host "***********************************************"
    Write-Host "Not called from master branch, not applying."
    Write-Host "***********************************************"
}

