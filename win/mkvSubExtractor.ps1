$items=Get-ChildItem -Name *.mkv
$Track=0
foreach ($item in $items)
{
$info = & 'C:\Program Files\MKVToolNix\mkvinfo.exe' $item | Where-Object -FilterScript {($_ -like '*Track number*') -or ($_ -like '*Language: dan*')}
$info = $info -replace '.*: ', '' -replace '\)',''
for ($i=0;$i -lt $info.count;$i=$i+1){if ($info[$i] -like "dan")
{
	$Track=$info[$i-1]
	$Destination=($item).replace("mkv","srt")
	& 'C:\Program Files\MKVToolNix\mkvextract.exe' "$item" tracks $Track`:`"$Destination`"
}}}
