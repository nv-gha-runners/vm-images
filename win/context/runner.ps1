$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# Getting CPU info
$cpuInfo = Get-CimInstance -ClassName Win32_Processor
# $coreCountPhysical = $cpuInfo.NumberOfCores
$coreCountLogical = $cpuInfo.NumberOfLogicalProcessors

$ENV:PARALLEL_LEVEL="$coreCountLogical"

# Briefly wait to start the runner
Start-Sleep -Seconds 10

# Setup runner hook and config
Write-Output "Trying to fetch JITConfig"
$ENV:ACTIONS_RUNNER_INPUT_JITCONFIG = Get-Content -Path "C:/jitconfig" -ErrorAction Stop
$ENV:ACTIONS_RUNNER_HOOK_JOB_STARTED = "C:/actions-runner/.initialize_runner.sh"

# Remove runner config
# Write-Output "Removing JITConfig file"
# Remove-Item -Force "C:/jitconfig"

Write-Output "Starting runner"
Set-Location C:/actions-runner
./run.cmd

Stop-Computer -Force -ComputerName localhost
