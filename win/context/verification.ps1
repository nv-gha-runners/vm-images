. "$PSScriptRoot/init.ps1"

Write-Output "Testing fetched tools"
jq --version
yq --version
git --version
gh --version
docker --version
docker info
