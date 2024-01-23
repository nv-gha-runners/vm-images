$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

$yq_amd64 = "https://github.com/mikefarah/yq/releases/latest/download/yq_windows_amd64.exe"

Invoke-WebRequest -UseBasicParsing -OutFile "${env:NV_EXE_DIR}/yq.exe" -Uri "${yq_amd64}"

yq --version
