param (
    [string]
    $root="C:/git"
)

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

mkdir -Force $root -ErrorAction Ignore | Out-Null
Set-Location $root

# Download the latest git package
# TODO: Use the latest version. Requires adapting `linux/context/github.sh` for Windows.
$gitUri = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
Invoke-WebRequest -UseBasicParsing -Uri "${gitUri}" -OutFile "${root}/git_setup.exe"

Start-Process -Wait -FilePath "${root}/git_setup.exe" -ArgumentList "/SP- /VERYSILENT /NORESTART /NOCLOSEAPPLICATIONS"
