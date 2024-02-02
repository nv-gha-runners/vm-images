# Get SSH Client and Server
$ssh_client = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
$ssh_server = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

# Install SSH Client and Server
$ssh_client | Add-WindowsCapability -Online
$ssh_server | Add-WindowsCapability -Online

$password = ConvertTo-SecureString -Force -AsPlainText -String "Runner1!"
Set-LocalUser -Name Administrator -Password $password

Set-Service -Name sshd -StartupType Automatic
$pshost = [Diagnostics.Process]::GetCurrentProcess().Path
New-ItemProperty -Path "HKLM:/SOFTWARE/OpenSSH" -Name DefaultShell -Value "$pshost" -PropertyType String -Force

Start-Service -Name sshd
