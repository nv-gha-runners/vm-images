$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

$jitconfig = "C:/jitconfig"
$maxPollCount = 20

for ($count = 0; $count -lt $maxPollCount; $count++) {
    Write-Output "waiting for jitconfig ($count / $maxPollCount)"
    Start-Sleep -Seconds 10
    $exists = Test-Path $jitconfig

    if ($exists) {
        break
    }
}

if (-not $exists) {
    Stop-Computer -Force & # background job so that we can exit after writing an error.
    Write-Error "$jitconfig not found after 200 seconds, exiting"
}

# Setup runner hook and config
Write-Output "Trying to fetch JITConfig"
$ENV:ACTIONS_RUNNER_INPUT_JITCONFIG = Get-Content -Path $jitconfig -ErrorAction Stop
$ENV:ACTIONS_RUNNER_HOOK_JOB_STARTED = "C:/actions-runner/.initialize_runner.sh"

# Remove runner config
Write-Output "Removing JITConfig file"
Remove-Item -Force "C:/jitconfig"

Write-Output "Starting runner"
Set-Location C:/actions-runner
./run.cmd

Stop-Computer -Force -ComputerName localhost
