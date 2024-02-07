$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

# these strings are case-sensitive and should match the case of the GH org
$cloud_orgs = "dask-contrib", "dask", "NERSC", "numba"

foreach ($org in $cloud_orgs) {
    if ("$ENV:GITHUB_REPOSITORY_OWNER" -ceq "$cloud_orgs") {
        Write-Output "Runner initialized"
        exit 0
    }
}

$blocked_events = "pull_request", "pull_request_target"

foreach ($event in $blocked_events) {
    if ("$ENV:GITHUB_EVENT_NAME" -like "$event") {
        # Writing an error is an error
        Write-Error "Workflows triggered by '${GITHUB_EVENT_NAME}' events are not allowed to run on self-hosted runners."
        exit 1
    }
}

Write-Output "Runner initialized"
exit 0
