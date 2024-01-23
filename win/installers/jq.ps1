$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

$jq_amd64 = "https://github.com/jqlang/jq/releases/latest/download/jq-windows-amd64.exe"

Invoke-WebRequest -UseBasicParsing -OutFile "${env:NV_EXE_DIR}/jq.exe" -Uri "${jq_amd64}"

jq --version
