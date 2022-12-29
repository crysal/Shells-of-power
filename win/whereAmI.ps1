$authToken="MDEyMzQ1Njc4OWFiY2RlZmdoaWprbG1ub3BxcnN0dXZ4eXp6eXh2dXRzcnFwb21ubGtqaWhnZmVkY2JhOTg3NjU0MzIxMA=" #USE YOUR "Encoded for use:" from https://wigle.net/account
$bssid=((netsh wlan show networks mode=bssid | Select-String -Pattern "BSSID") -replace ".*: ","") -replace ":","%3A"
write-host "found"$bssid.count"networks"
$bssid.Split("`n") | %{
$headers = @{"Authorization"="Basic $authToken"} 
$response = Invoke-RestMethod -Method GET "https://api.wigle.net/api/v2/network/search?netid=$_" -Headers $headers
$array=$response.results.trilat,"+", $response.results.trilong
$latlong = -join $array
if ($latlong -eq "+"){}else{Write-Host "https://www.google.com/maps/place/$latlong"}
}
