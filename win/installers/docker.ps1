$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$root = "C:/docker"

. "$NV_CONTEXT_DIR/envvars.ps1"

Stop-Service docker -ErrorAction Ignore
Remove-Item -Recurse -Force -Path $root -ErrorAction Ignore
$nul = mkdir -Force $root -ErrorAction Ignore

Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Containers

Set-Location $root

# TODO: Get latest release version from `moby/moby` repository. Requires adapting `linux/context/github.sh` for Windows.
$Uri = "https://download.docker.com/win/static/stable/x86_64/docker-25.0.0.zip"
Invoke-WebRequest -UseBasicParsing -OutFile docker.zip -Uri $Uri
tar --strip-components=1 -xf docker.zip
Remove-Item docker.zip

./dockerd.exe --register-service
Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "$root"
