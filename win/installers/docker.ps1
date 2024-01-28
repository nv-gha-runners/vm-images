$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$root = "C:/docker"

Set-Location "${root}"

# TODO: Get latest release version from `moby/moby` repository. Requires adapting `linux/context/github.sh` for Windows.
$uri = "https://download.docker.com/win/static/stable/x86_64/docker-25.0.0.zip"
Invoke-WebRequest -UseBasicParsing -OutFile docker.zip -Uri "${uri}"
tar --strip-components=1 -xf docker.zip
Remove-Item docker.zip

$dockerDefaultConfigPath = "$env:ProgramData/docker/config"
mkdir -Force -ErrorAction SilentlyContinue -Path "$dockerDefaultConfigPath"
$domain = yq '.[env(NV_RUNNER_ENV)].domain' "${env:NV_CONTEXT_DIR}/config.yaml"

@"
{
    "group": "docker",
    "registry-mirrors": ["https://dc.${domain}.gha-runners.nvidia.com"]
}
"@ > "$dockerDefaultConfigPath/daemon.json"

./dockerd.exe --register-service
./dockerd.exe --validate
Start-Service Docker
