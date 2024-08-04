# Define the sensor names for both architectures
$cb64 = 'Carbon Black Cloud Sensor 64-bit'
$cb32 = 'Carbon Black Cloud Sensor 32-bit'

# Function to uninstall Carbon Black based on sensor name
function Uninstall-CarbonBlack {
    param (
        [string]$sensorName
    )

    Write-Host "Uninstalling $sensorName..."
    Set-Location -Path "C:\Program Files\Confer"
    $CBremove = ".\Uninstall.exe"
    $bypass = "/bypass 1"
    $removalCode = '*************'
    $uninstall = "/uninstall"

    Invoke-Expression "$CBremove $bypass $removalCode"
    Invoke-Expression "$CBremove $uninstall $removalCode"
}

# Check for Carbon Black Installation using WMI
$installCb64 = (Get-WmiObject -Class Win32_Product -Filter "Name='$cb64'" | Where-Object { $_.Name -eq $cb64 }) -ne $null
$installCb32 = (Get-WmiObject -Class Win32_Product -Filter "Name='$cb32'" | Where-Object { $_.Name -eq $cb32 }) -ne $null

# Determine the OS architecture
$is64BitOS = [Environment]::Is64BitOperatingSystem

if ($is64BitOS) {
    if ($installCb64) {
        Uninstall-CarbonBlack -sensorName $cb64
    } elseif ($installCb32) {
        Write-Host "32-bit Carbon Black Sensor detected on a 64-bit OS. Uninstalling..."
        Uninstall-CarbonBlack -sensorName $cb32
    } else {
        Write-Host "Carbon Black is not installed"
    }
} else {
    if ($installCb32) {
        Uninstall-CarbonBlack -sensorName $cb32
    } elseif ($installCb64) {
        Write-Host "64-bit Carbon Black Sensor detected on a 32-bit OS. Uninstalling..."
        Uninstall-CarbonBlack -sensorName $cb64
    } else {
        Write-Host "Carbon Black is not installed"
    }
}
