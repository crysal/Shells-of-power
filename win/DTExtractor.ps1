$PFolders=Get-ChildItem -Name "C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE\bundle\data\"
foreach ($folder in $PFolders)
{
$ListOFiles=Get-ChildItem -Name "C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE\bundle\data\$folder\*.STREAM"
foreach ($item in $ListOFiles){
if ( -not (Test-Path "U:\ripaudio\extract\$item" -PathType Container)){
.\RavioliGameTools_v2.10\RScannerConsole.exe "C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE\bundle\data\$folder\$item" /e:U:\ripaudio\extract\$item
if ( -not (Test-Path "U:\ripaudio\extract\$item" -PathType Container)){
mkdir "U:\ripaudio\extract\$item"
}
}
echo "$folder $item"
}
}
