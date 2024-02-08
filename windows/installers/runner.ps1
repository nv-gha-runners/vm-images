. "${env:NV_CONTEXT_DIR}\init.ps1"

$nul = mkdir -Force C:/actions-runner -ErrorAction Ignore
Set-Location C:/actions-runner

# Download the latest runner package
$actionRunnerUri = "https://github.com/actions/runner/releases/download/v${env:NV_RUNNER_VERSION}/actions-runner-win-x64-${env:NV_RUNNER_VERSION}.zip"
Invoke-WebRequest -UseBasicParsing -Uri "${actionRunnerUri}" -OutFile actions-runner.zip

# Extract the installer
tar -xf actions-runner.zip
Remove-Item actions-runner.zip

# Setup runner scripts
Copy-Item "${env:NV_CONTEXT_DIR}/initialize_runner.ps1" "C:/actions-runner/.initialize_runner.ps1"
Copy-Item "${env:NV_CONTEXT_DIR}/runner.ps1" "C:/actions-runner/runner.ps1"
