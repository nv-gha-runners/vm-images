$nul = mkdir -Force C:/actions-runner -ErrorAction Ignore
Set-Location C:/actions-runner

# Download the latest runner package
$actionRunnerUri = "https://github.com/actions/runner/releases/download/v$NV_RUNNER_VERSION/actions-runner-win-x64-$NV_RUNNER_VERSION.zip"
Invoke-WebRequest -UseBasicParsing -Uri "$actionRunnerUri" -OutFile actions-runner.zip

# Extract the installer
tar -xf actions-runner.zip
Remove-Item actions-runner.zip
