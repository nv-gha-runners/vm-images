. "${env:NV_CONTEXT_DIR}\init.ps1"

$root = "C:/docker"

mkdir -Force -ErrorAction SilentlyContinue "$root" | Out-Null
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

@"
{
    "group": "docker",
    "registry-mirrors": ["https://dc.local.gha-runners.nvidia.com"]
}
"@ > "$dockerDefaultConfigPath/daemon.json"

# Write and update envvars
Set-MachineEnvironmentVariable -Append -Variable "Path" -Value "C:/docker"
Write-MachineEnvironmentVariable -Variable "Path"

dockerd --register-service
dockerd --validate
Start-Service Docker
