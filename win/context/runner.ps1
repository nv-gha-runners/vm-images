$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# TODO: switch this to a `for` loop to poll for `C:/jitconfig` file
# Briefly wait to start the runner
Start-Sleep -Seconds 10

# Setup runner hook and config
Write-Output "Trying to fetch JITConfig"
$ENV:ACTIONS_RUNNER_INPUT_JITCONFIG = Get-Content -Path "C:/jitconfig" -ErrorAction Stop
$ENV:ACTIONS_RUNNER_HOOK_JOB_STARTED = "C:/actions-runner/.initialize_runner.sh"

# Remove runner config
Write-Output "Removing JITConfig file"
Remove-Item -Force "C:/jitconfig"

Write-Output "Starting runner"
Set-Location C:/actions-runner
./run.cmd

Stop-Computer -Force -ComputerName localhost
