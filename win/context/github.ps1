function Get-GithubLatestRelease {
    param (
        [String]
        [ValidatePattern(".+/.+")]
        [Parameter(Position=0, Mandatory=$true)]
        $Repo
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

    $latestVersion = (Invoke-WebRequest @webreqParams).Content |
                        jq -r '.[] | select((.prerelease==false) and (.assets | length > 0)).tag_name' |
                        Select-String -NotMatch -Pattern ".*-[a-z]|beta" |
                        %{ [Version]"$_".Replace("v", "") } | # Cast input string to a version 'type'
                        Sort-Object -Unique | Select-Object -Last 1 | %{ $_.ToString() }

    Write-Output "$latestVersion"
}
