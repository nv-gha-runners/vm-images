$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

. "$PSScriptRoot/envvars.ps1"

Get-MachineEnvironmentVariable -Variable "Path"
