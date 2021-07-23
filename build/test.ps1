Write-Host "***********************************************"
Write-Host "Testing code"
Write-Host "***********************************************"

Set-Location ../src/Leegle.ReactWebApp.Web/ClientApp
npm run test
Set-Location ../../../build