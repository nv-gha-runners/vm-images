$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

$jitconfig = "C:/jitconfig"
$maxPollCount = 20

for ($count = 0; $count -lt $maxPollCount; $count++) {
    $exists = Test-Path $jitconfig

    if ($exists) {
        break
    }

    Write-Output "waiting for jitconfig ($count / $maxPollCount)"
    Start-Sleep -Seconds 10
}

if (-not $exists) {
    Write-Error -ErrorAction Continue "$jitconfig not found after 200 seconds, exiting"
    Stop-Computer -Force
    exit 1
}

# Setup runner hook and config
Write-Output "Trying to fetch JITConfig"
$ENV:ACTIONS_RUNNER_INPUT_JITCONFIG = Get-Content -Path $jitconfig -ErrorAction Stop
$ENV:ACTIONS_RUNNER_HOOK_JOB_STARTED = "C:/actions-runner/.initialize_runner.ps1"

# Remove runner config
Write-Output "Removing JITConfig file"
Remove-Item -Force "C:/jitconfig"

Write-Output "Starting runner"
Set-Location C:/actions-runner
./run.cmd

Stop-Computer -Force -ComputerName localhost
