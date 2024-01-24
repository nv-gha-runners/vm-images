. "${env:NV_CONTEXT_DIR}/envvars.ps1"

mkdir -Force -ErrorAction SilentlyContinue ${env:NV_EXE_DIR} | Out-Null

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "${env:NV_EXE_DIR}"
