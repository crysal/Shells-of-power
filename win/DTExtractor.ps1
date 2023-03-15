#EDIT ME
$PathToDarkTide="C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE" #Where Darktide is installed
$PathToExtract="U:\ripaudio\extract" #Where to put the .wem files
$PathToRavioli="U:\ripaudio\RavioliGameTools" #The path to where RavioliGameTools is stored (Download link https://www.scampers.org/steve/sms/other/RavioliGameTools_v2.10.zip)
#

$PFolders=Get-ChildItem -Name "$PathToDarkTide\bundle\data\"
foreach ($folder in $PFolders)
{
$ListOFiles=Get-ChildItem -Name "$PathToDarkTide\bundle\data\$folder\*.STREAM"
foreach ($item in $ListOFiles){
if ( -not (Test-Path "$PathToExtract\$item" -PathType Container)){
& $PathToRavioli\RScannerConsole.exe "$PathToDarkTide\bundle\data\$folder\$item" /e:$PathToExtract\$item
if ( -not (Test-Path "$PathToExtract\$item" -PathType Container)){
mkdir "$PathToExtract\$item"
}
}
echo "$folder $item"
}
}
