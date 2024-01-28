. "${env:NV_CONTEXT_DIR}/envvars.ps1"

mkdir -Force -ErrorAction SilentlyContinue "${env:NV_EXE_DIR}" | Out-Null
mkdir -Force -ErrorAction SilentlyContinue "C:/docker"         | Out-Null

Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "${env:NV_EXE_DIR}"
Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "C:/docker"

Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Containers
