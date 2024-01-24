param (
    [string]
    $root="${env:NV_EXE_DIR}"
)

$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

. "${env:NV_CONTEXT_DIR}\envvars.ps1"
. "${env:NV_CONTEXT_DIR}\github.ps1"

$latestVersion = Get-GithubLatestRelease -Repo "cli/cli"

$repoBaseUri = "https://github.com/cli/cli/releases/download/v${latestVersion}/"
$ghClientZip = "gh_${latestVersion}_windows_amd64.zip"

$webreqChk = @{
    UseBasicParsing = $true
    Uri = "${repoBaseUri}/gh_${latestVersion}_checksums.txt"
}
$webreqPkg = @{
    UseBasicParsing = $true
    Uri = "${repoBaseUri}/$ghClientZip"
}

# [String]::new((Invoke-WebRequest @webreqChk).Content) -> Convert incoming stream to a string
# Split the string to ease finding the correct sha
# Top it off by getting only the sha for the file we're fetching
$checksum = [String]::new((Invoke-WebRequest @webreqChk).Content).Split("`n") | Select-String -Pattern "[a-zA-Z0-9]+ +$ghClientZip"

$pkg = Invoke-WebRequest @webreqPkg
$hash = (Get-FileHash -Algorithm SHA256 -InputStream $pkg.RawContentStream).Hash

# Hash might have some extra characters, so ignore those
if ("$checksum" -inotlike "$hash*") {
    Write-Error "GitHub Client download failed, SHA256 mismatch"
}

[System.IO.File]::WriteAllBytes("$(pwd)/$ghClientZip", $pkg.Content)

mkdir -Force -ErrorAction Ignore -Path "$root" | Out-Null
tar -C "$root" --strip-components=1 -xf "./$ghClientZip"
Remove-Item "./$ghClientZip"
