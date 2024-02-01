$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$root = "C:/docker"

Set-Location "${root}"

$webreqCommon = @{
    UseBasicParsing = $true;
}

$uri = "https://download.docker.com/win/static/stable/x86_64/"

Write-Output "Finding latest docker release"
# Fetch list of docker releases
$resp = Invoke-WebRequest @webreqCommon -Uri $uri
# Match input strings for binary downloads, files are ordered so just set the latest each time a match is encountered
$resp.Content.Split() | %{ $_ -match "(docker-[0-9\.]+\.zip)" | Out-Null; if ($matches) { $script:latest = $matches.1 } }

Write-Output "Found $latest"
Invoke-WebRequest @webreqCommon -OutFile docker.zip -Uri "${uri}${latest}"
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
