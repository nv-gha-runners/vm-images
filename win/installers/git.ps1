$nul = mkdir -Force C:/git -ErrorAction Ignore
Set-Location C:/git

# Download the latest git package
# TODO: Use the latest version. Requires adapting `linux/context/github.sh` for Windows.
$gitUri = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
Invoke-WebRequest -UseBasicParsing -Uri "$gitUri" -OutFile "C:/git/git_setup.exe"

Start-Process -Wait -FilePath "C:/git/git_setup.exe" -ArgumentList "/SP- /VERYSILENT /NORESTART /NOCLOSEAPPLICATIONS"

Remove-Item git_setup.exe

git --version
