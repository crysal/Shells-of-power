$date = get-date -UFormat Year%Y/Mounth%m/Day%d/%H-%M-%S
start-transcript C:\Users\$env:username\Desktop\PowerShellTranscripts\$date.txt
cls
$911 = echo "09/11/2001 08:46am"
$911? = echo "(Get-ChildItem %item%).CreationTime/LastWriteTime/LastAccessTime = $911"
$GetUsername = read-host "Username"
$GetUsername = $GetUsername.substring(0,1).toupper()+$GetUsername.substring(1)
IF (([Security.Principal.WindowsPrincipal] ` [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
$host.ui.RawUI.WindowTitle = "Administrator: "+$GetUsername } Else
{ $host.ui.RawUI.WindowTitle = "Low level scrub: "+$GetUsername }
  
do {
$BasPassword =[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("#PUT PASSWORD HERE#"))
$GetPassword = read-host "Password" -AsSecureString
$ThePassword = $BasPassword | ConvertTo-SecureString -asPlainText -Force


If (([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($GetPassword))) -ceq ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ThePassword)))){$CheckPassword=$true}else{
Write-host "                                 _____                _            _ " -Foreground red
Write-host "     /\                         |  __ \              (_)          | |" -Foreground red
Write-host "    /  \    ___  ___  ___  ___  | |  | |  ___  _ __   _   ___   __| |" -Foreground red
Write-host "   / /\ \  / __|/ _ \/ __|/ __| | |  | | / _ \| '_ \ | | / _ \ / _' |" -Foreground red
Write-host "  / ____ \| (__|  __/\__ \\__ \ | |__| ||  __/| | | || ||  __/| (_| |" -Foreground red
Write-host " /_/    \_\\___|\___||___/|___/ |_____/  \___||_| |_||_| \___| \__,_|" -Foreground red

start-sleep 5
cls
}

}while ($CheckPassword -ne $true)

Write-host "                                  _____                  _______         _ " -ForegroundColor green
Write-host "     /\                          / ____|                |__   __|       | |" -ForegroundColor green
Write-host "    /  \    ___  ___  ___  ___  | |  __  _ __  __ _  _ __  | |  ___   __| |" -ForegroundColor green
Write-host "   / /\ \  / __|/ _ \/ __|/ __| | | |_ || '__|/ _' || '_ \ | | / _ \ / _' |" -ForegroundColor green
Write-host "  / ____ \| (__|  __/\__ \\__ \ | |__| || |  | (_| || | | || ||  __/| (_| |" -ForegroundColor green
Write-host " /_/    \_\\___|\___||___/|___/  \_____||_|   \__,_||_| |_||_| \___| \__,_|" -ForegroundColor green

start-sleep 1
cls

Write-host " __          __    _                                __  __           _______          " -ForegroundColor green
Write-host " \ \        / /   | |                              |  \/  |         |__   __|         " -ForegroundColor green
Write-host "  \ \  /\  / /___ | |  ___  ___   _ __ ___    ___  | \  / |  __ _  ___ | |  ___  _ __ " -ForegroundColor green
Write-host "   \ \/  \/ // _ \| | / __|/ _ \ | '_ ' _ \  / _ \ | |\/| | / _' |/ __|| | / _ \| '__|" -ForegroundColor green
Write-host "    \  /\  /|  __/| || (__| (_) || | | | | ||  __/ | |  | || (_| |\__ \| ||  __/| |   " -ForegroundColor green
Write-host "     \/  \/  \___||_| \___|\___/ |_| |_| |_| \___| |_|  |_| \__,_||___/|_| \___||_|   " -ForegroundColor green
