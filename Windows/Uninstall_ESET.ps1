$software = 'ESET Management Agent'
$esetEndpoint = 'ESET Endpoint Security'

$esetEndpointInstalled = (Get-WmiObject -Class Win32_Product -Filter "Name='$esetEndpoint'" | Where-Object { $_.Name -eq $esetEndpoint }) -ne $null
$esetEndpointDetails = (Get-WmiObject -Class Win32_Product -Filter "Name='$esetEndpoint'")

if ($esetEndpointInstalled) {
    sc.exe delete eraagentsvc
    $esetEndpointUUID = $esetEndpointDetails['IdentifyingNumber']
    msiexec.exe /X $esetEndpointUUID /qn /norestart
    Write-Output "Uninstalling ESET Endpoint Security"
}

$installed = (Get-WmiObject -Class Win32_Product -Filter "Name='$software'" | Where-Object { $_.Name -eq $software }) -ne $null
$softwareDetails = (Get-WmiObject -Class Win32_Product -Filter "Name='$software'")

while ($installed) {
    # Uninstall ESET Management Agent
    $uuid = $softwareDetails['IdentifyingNumber']
    msiexec.exe /X $uuid /qn
    Start-Sleep -Seconds 10
    $installed = (Get-WmiObject -Class Win32_Product -Filter "Name='$software'" | Where-Object { $_.Name -eq $software }) -ne $null
}
