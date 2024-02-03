. "${env:NV_CONTEXT_DIR}\init.ps1"

mkdir -Force -ErrorAction SilentlyContinue "${env:NV_EXE_DIR}" | Out-Null

$yq_amd64 = "https://github.com/mikefarah/yq/releases/latest/download/yq_windows_amd64.exe"
Invoke-WebRequest -UseBasicParsing -OutFile "${env:NV_EXE_DIR}/yq.exe" -Uri "${yq_amd64}"

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "${env:NV_EXE_DIR}"
