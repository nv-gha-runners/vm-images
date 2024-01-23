$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

. "$NV_CONTEXT_DIR/envvars.ps1"

$root = "$NV_EXE_DIR"
$nul = mkdir -Force $root -ErrorAction Ignore

$jq_amd64 = "https://github.com/jqlang/jq/releases/latest/download/jq-windows-amd64.exe"

Invoke-WebRequest -UseBasicParsing -OutFile "$root/jq.exe" -Uri $jq_amd64

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "$root"

jq --version
