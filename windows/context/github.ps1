function Get-GithubLatestRelease {
    param (
        [String]
        [ValidatePattern(".+/.+")]
        [Parameter(Position=0, Mandatory=$true)]
        $Repo,
        $Regex=".*-[a-z]|beta"
    )

    # Probe that jq is on the path
    Get-Command jq | Out-Null

    $max_results = "100"
    $webreqParams = @{
        Uri = "https://api.github.com/repos/${Repo}/releases?per_page=${max_results}";
        UseBasicParsing = $true
    }

    if ("$env:GH_TOKEN" -ne "") {
        $webreqParams["Headers"] = @{ Authorization = "Bearer ${env:GH_TOKEN}" }
    }

    # Matches v2.3.4.foo.bar -> 2.3.4
    $versionRegex = "v?([0-9]+\.[0-9]+\.[0-9]+)\.?.*"

    $versions = @()
    (Invoke-WebRequest @webreqParams).Content |
        jq -r '.[] | select((.prerelease==false) and (.assets | length > 0)).tag_name' |
        Select-String -NotMatch -Pattern "$Regex" |
        %{ $_ -match "$versionRegex" | Out-Null; if ($Matches) {$versions += $Matches.1} }

    $versions = [Version[]]$versions | Sort-Object -Unique | Select-Object -Last 1 | %{ $_.ToString() }

    return $versions
}
