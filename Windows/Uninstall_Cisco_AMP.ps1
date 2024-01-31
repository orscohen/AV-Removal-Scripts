$Password = "Removal_password_here"
$regkey = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Immunet Protect'

if (Test-Path $regkey) {
    $uninstallString = (Get-ItemProperty -Path $regKey -Name UninstallString).UninstallString

    if (-not $uninstallString) {
        Write-Error "Uninstall string not specified."
        exit 1
    } else {
        Write-Host "Running uninstallation..."
        Start-Process -Wait -FilePath $uninstallString -ArgumentList "/S", "/password", $Password
        Write-Host "Uninstallation completed successfully."
        exit 0
    }
} else {
    Write-Error "Immunet Protect registry key not found: $regkey"
    exit 2
}
