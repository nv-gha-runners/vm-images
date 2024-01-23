$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

. "$NV_CONTEXT_DIR/envvars.ps1"

$root = "$NV_EXE_DIR"
$nul = mkdir -Force $root -ErrorAction Ignore

$yq_amd64 = "https://github.com/mikefarah/yq/releases/latest/download/yq_windows_amd64.exe"

Invoke-WebRequest -UseBasicParsing -OutFile "$root/yq.exe" -Uri $yq_amd64

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "$root"

yq --version
