$APIKey = "XXXXXXXXXx"
$headers = @{
"Content-Type" = "application/json"
"Accept" = "application/json"
"X-Cisco-Meraki-API-Key" = $APIKey
}

$orgs = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations" -Headers $Headers
$networks = @()
foreach ($org in $orgs){
  $x = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations/$($org.id)/networks" -Headers $Headers
  $networks += $X
}

$clients = @()
$devices = @()
foreach ($network in $networks){
  #Write-Host $network.name
  $x = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/networks/$($network.id)/clients?perPage=1000" -Headers $Headers
  $clients += $x

  $y = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/networks/$($network.id)/devices" -Headers $Headers
  $devices += $y
}


function get-name{
 param (
        $serial
    )
    ($networks | where {$_.id -eq (($devices | where {$_.serial -eq $serial}).networkId)}).name
}



$clients | select mac,description,ip,ssid,vlan,switchport,user,firstSeen,lastSeen,status, @{Name = 'NetName'; Expression = {get-name($_.recentDeviceSerial)}} | sort User | where {$_.User -ne $null} | where {$_.Status -Like "Online"}| Out-GridView

