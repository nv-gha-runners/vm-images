. "${env:NV_CONTEXT_DIR}\init.ps1"

mkdir -Force -ErrorAction SilentlyContinue "${env:NV_EXE_DIR}" | Out-Null

$jq_amd64 = "https://github.com/jqlang/jq/releases/latest/download/jq-windows-amd64.exe"
Invoke-WebRequest -UseBasicParsing -OutFile "${env:NV_EXE_DIR}/jq.exe" -Uri "${jq_amd64}"

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "${env:NV_EXE_DIR}"
