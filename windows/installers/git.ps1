. "${env:NV_CONTEXT_DIR}\init.ps1"
. "${env:NV_CONTEXT_DIR}\github.ps1"

# Find the latest git package
$latestVersion = Get-GithubLatestRelease -Repo "git-for-windows/git"

# .0 is typically an RC, .2 is a patch release of git-for-windows.
# Hardcode the .1 release version.
$gitUri = "https://github.com/git-for-windows/git/releases/download/v$latestVersion.windows.1/Git-$latestVersion-64-bit.exe"
Write-Output "Fetching: $gitUri"
Invoke-WebRequest -UseBasicParsing -Uri "${gitUri}" -OutFile "./git_setup.exe"

# Use Start-Process to wait for installer to finish completely
Start-Process -Wait -FilePath "./git_setup.exe" -ArgumentList "/SP- /VERYSILENT /NORESTART /NOCLOSEAPPLICATIONS"

# For bash.exe, add 'C:\Program Files\Git\bin' to PATH
[Environment]::SetEnvironmentVariable('Path', "$([Environment]::GetEnvironmentVariable('Path', 'Machine'));C:\Program Files\Git\bin", 'Machine')

# Cleanup
Remove-Item "./git_setup.exe"
