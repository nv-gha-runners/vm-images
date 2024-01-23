function Set-MachineEnvironmentVariable {
    param(
        [switch]
        $Append,
        [string]
        [parameter(Mandatory=$true)]
        $Variable,
        [string]
        [parameter(Mandatory=$true)]
        $Value
    )

    $ProgressPreference = "SilentlyContinue"
    $ErrorActionPreference = "Stop"

    if ($Append) {
        $old = [Environment]::GetEnvironmentVariable("$Variable", [EnvironmentVariableTarget]::Machine)
        if ($old -And $old.Split(';') -icontains "$Value") {
            Write-Warning "Environment variable already configured"
            return
        }
        elseif ($old) {
            $Value = "${Value};${old}"
        }
    }

    [Environment]::SetEnvironmentVariable("${Variable}", "${Value}", [EnvironmentVariableTarget]::Machine)

    $check = [Environment]::GetEnvironmentVariable("${Variable}", [EnvironmentVariableTarget]::Machine)
    if ($check -And $check -icontains "${Value}") {
        Write-Warning "Succesfully set ${Variable} = '${Value}'"
        return
    }
    else {
        Write-Error "Failed to set ${Variable} = '${Value}'"
        return
    }

}
