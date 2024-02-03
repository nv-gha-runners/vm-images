. "$PSScriptRoot/init.ps1"

$pshost = [Diagnostics.Process]::GetCurrentProcess().Path

$taskName = "GHA Launcher"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction Ignore) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

#Enable runner task at startup
$jobSettings = @{
    TaskName    = $taskName
    Trigger     = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
    Settings    = New-ScheduledTaskSettingsSet -StartWhenAvailable
    Principal   = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Action      = New-ScheduledTaskAction -Execute "$pshost" -Argument "-File C:\actions-runner\runner.ps1"
    AsJob       = $true
}

Register-ScheduledTask @jobSettings

# Tasks are possibly asynchronously submitted to the task sched.
# We sleep to possibly give it time to submit.
Start-Sleep -Seconds 2
Get-ScheduledTask -TaskName $taskName
