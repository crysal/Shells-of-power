$HowManyNames = (Get-ChildItem | Where-Object {$_.Mode -gt 'd'}).FullName
$ChildItems = (Get-ChildItem $HowManyNames | Where-Object {$_.Mode -gt 'd'}).FullName
$Combi = $HowManyNames + $ChildItems
$ChildItems2 = (Get-ChildItem $ChildItems | Where-Object {$_.Mode -gt 'd'}).FullName
$Combi2 = $Combi + $ChildItems2
$HowMany = ($Combi2).Count
$UnixEpoch = '1. january 1970 00:00:00'
while ($HowMany -ne 0)
{
$HowMany--
((Get-Item $Combi2[$HowMany]).CreationTime) = $UnixEpoch
((Get-Item $Combi2[$HowMany]).LastWriteTime) = $UnixEpoch
((Get-Item $Combi2[$HowMany]).LastAccessTime) = $UnixEpoch
}
