. "${env:NV_CONTEXT_DIR}\init.ps1"

Write-Output "Prepopulating servercore images"
docker pull mcr.microsoft.com/windows/servercore:ltsc2022
