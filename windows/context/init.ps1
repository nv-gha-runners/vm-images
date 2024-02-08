$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

. "$PSScriptRoot/envvars.ps1"

Write-MachineEnvironmentVariable -Variable "Path"
