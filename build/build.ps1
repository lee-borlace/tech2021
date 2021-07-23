Write-Host "***********************************************"
Write-Host "Building code"
Write-Host "***********************************************"

Set-Location ../src/Leegle.ReactWebApp.Web/ClientApp
npm install
npm run build
Set-Location ../../../build