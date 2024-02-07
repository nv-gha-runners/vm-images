. "${env:NV_CONTEXT_DIR}\init.ps1"

$uri = "https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
Invoke-WebRequest -UseBasicParsing -Uri "${uri}" -OutFile "CloudbaseInitSetup_Stable_x64.msi"

Write-Output "Installing cloudbase-init..."
Start-Process -Wait -FilePath "msiexec" -ArgumentList "/i CloudbaseInitSetup_Stable_x64.msi /qn /l*v log.txt"
Write-Output "cloudbase-init installation finished"

Copy-Item "${env:NV_CONTEXT_DIR}/cloudbase-init.conf" "${env:ProgramFiles}/Cloudbase Solutions/Cloudbase-Init/conf/cloudbase-init.conf"

Remove-Item CloudbaseInitSetup_Stable_x64.msi

# Stop cloudbase to prevent reboot timeout
Write-Output "Sleeping before stopping cloudbase to prevent reboot timeout"
Start-Sleep -Seconds 5
Stop-Service cloudbase-init
