# CarbonBlack Complete Uninstaller (Enhanced)
# Must be run as Administrator

# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges!"
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    pause
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CarbonBlack Complete Uninstaller" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to safely delete registry key
function Remove-RegistryKeyIfExists {
    param($Path)
    
    if (Test-Path $Path) {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Removed: $Path" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "[ERROR] Failed to remove: $Path" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
            return $false
        }
    }
    else {
        Write-Host "[INFO] Not found: $Path" -ForegroundColor Gray
        return $true
    }
}

# Function to delete service
function Remove-ServiceIfExists {
    param($ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($service) {
        try {
            # Stop service if running
            if ($service.Status -eq 'Running') {
                Write-Host "[INFO] Stopping service: $ServiceName..." -ForegroundColor Yellow
                Stop-Service -Name $ServiceName -Force -ErrorAction Stop
                Start-Sleep -Seconds 2
            }
            
            # Delete service
            sc.exe delete $ServiceName
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS] Deleted service: $ServiceName" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "[ERROR] Failed to delete service: $ServiceName" -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "[ERROR] Error with service $ServiceName : $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "[INFO] Service not found: $ServiceName" -ForegroundColor Gray
        return $true
    }
}

# Function to find CarbonBlack product codes
function Find-CarbonBlackProductCodes {
    Write-Host "[INFO] Searching for CarbonBlack product codes..." -ForegroundColor Yellow
    
    $searchPath = "Registry::HKEY_CLASSES_ROOT\Installer\Products"
    $foundPaths = @()
    
    if (Test-Path $searchPath) {
        $products = Get-ChildItem -Path $searchPath -ErrorAction SilentlyContinue
        
        foreach ($product in $products) {
            $productName = (Get-ItemProperty -Path $product.PSPath -Name "ProductName" -ErrorAction SilentlyContinue).ProductName
            
            # Search for both old and new naming conventions
            if ($productName -like "*carbonblack*sensor*" -or $productName -like "*vmware*carbon*black*") {
                Write-Host "[FOUND] Product Code: $($product.PSChildName)" -ForegroundColor Green
                Write-Host "        Product Name: $productName" -ForegroundColor Green
                $foundPaths += $product.PSPath
            }
        }
    }
    
    if ($foundPaths.Count -eq 0) {
        Write-Host "[INFO] No CarbonBlack product codes found" -ForegroundColor Gray
    }
    
    return $foundPaths
}

# Function to remove folder
function Remove-FolderIfExists {
    param($Path)
    
    if (Test-Path $Path) {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Host "[SUCCESS] Removed folder: $Path" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "[ERROR] Failed to remove folder: $Path" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
            return $false
        }
    }
    else {
        Write-Host "[INFO] Folder not found: $Path" -ForegroundColor Gray
        return $true
    }
}

# Function to remove from Add/Remove Programs
function Remove-FromPrograms {
    param($DisplayName)
    
    Write-Host "[INFO] Attempting to remove '$DisplayName' from Programs..." -ForegroundColor Yellow
    
    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($keyPath in $uninstallKeys) {
        $apps = Get-ItemProperty $keyPath -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -like "*$DisplayName*" }
        
        foreach ($app in $apps) {
            Write-Host "[FOUND] Uninstall entry: $($app.DisplayName)" -ForegroundColor Green
            
            # Try to execute uninstall string
            if ($app.UninstallString) {
                try {
                    $uninstallCmd = $app.UninstallString -replace 'MsiExec.exe', 'msiexec.exe'
                    if ($uninstallCmd -like "*msiexec*") {
                        $uninstallCmd += " /qn /norestart"
                        Write-Host "[INFO] Running: $uninstallCmd" -ForegroundColor Yellow
                        Start-Process "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait -NoNewWindow
                        Write-Host "[SUCCESS] Uninstall command completed" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "[WARNING] Could not execute uninstall string" -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host "Step 1: Stopping Services" -ForegroundColor Cyan
Write-Host "-------------------------" -ForegroundColor Cyan

# Stop services first
$services = @("CarbonBlack", "carbonblackk", "cbstream")
foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        try {
            Write-Host "[INFO] Stopping service: $svc..." -ForegroundColor Yellow
            Stop-Service -Name $svc -Force -ErrorAction Stop
            Start-Sleep -Seconds 2
            Write-Host "[SUCCESS] Stopped service: $svc" -ForegroundColor Green
        }
        catch {
            Write-Host "[WARNING] Could not stop service: $svc" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Step 2: Uninstalling from Programs" -ForegroundColor Cyan
Write-Host "-----------------------------------" -ForegroundColor Cyan

# Try to uninstall via Windows uninstaller
Remove-FromPrograms -DisplayName "Carbon Black"
Remove-FromPrograms -DisplayName "Cb Defense"
Remove-FromPrograms -DisplayName "Cb Enterprise Response"

Write-Host ""
Write-Host "Step 3: Removing Installation Folders" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

# Remove installation directories
$folders = @(
    "$env:windir\CarbonBlack",
    "$env:ProgramFiles\CarbonBlack",
    "$env:ProgramFiles\Confer",
    "$env:ProgramFiles (x86)\CarbonBlack",
    "$env:ProgramData\CarbonBlack"
)

foreach ($folder in $folders) {
    Remove-FolderIfExists -Path $folder
}

Write-Host ""
Write-Host "Step 4: Removing Registry Keys" -ForegroundColor Cyan
Write-Host "-------------------------------" -ForegroundColor Cyan

# Remove service registry keys
$registryKeys = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\CarbonBlack",
    "HKLM:\SYSTEM\CurrentControlSet\Services\carbonblackk",
    "HKLM:\SYSTEM\CurrentControlSet\Services\cbstream"
)

foreach ($key in $registryKeys) {
    Remove-RegistryKeyIfExists -Path $key
}

# Remove config and software registry keys
$configKeys = @(
    "HKLM:\SOFTWARE\CarbonBlack",
    "HKLM:\SOFTWARE\WOW6432Node\CarbonBlack"
)

foreach ($key in $configKeys) {
    Remove-RegistryKeyIfExists -Path $key
}

# Find and remove product codes
$productCodePaths = Find-CarbonBlackProductCodes
foreach ($productPath in $productCodePaths) {
    Remove-RegistryKeyIfExists -Path $productPath
}

Write-Host ""
Write-Host "Step 5: Deleting Services" -ForegroundColor Cyan
Write-Host "-------------------------" -ForegroundColor Cyan

# Delete services
foreach ($svc in $services) {
    Remove-ServiceIfExists -ServiceName $svc
}

Write-Host ""
Write-Host "Step 6: Cleaning up Windows Installer Cache" -ForegroundColor Cyan
Write-Host "--------------------------------------------" -ForegroundColor Cyan

# Clean up Windows Installer cache for CarbonBlack
$installerPath = "$env:windir\Installer"
if (Test-Path $installerPath) {
    try {
        $msiFiles = Get-ChildItem -Path $installerPath -Filter "*.msi" -ErrorAction SilentlyContinue
        foreach ($msi in $msiFiles) {
            try {
                $msiInfo = & msiexec /qn /log "$env:TEMP\msi_check.log" /x "$($msi.FullName)" REBOOT=ReallySuppress 2>&1
                $logContent = Get-Content "$env:TEMP\msi_check.log" -ErrorAction SilentlyContinue
                if ($logContent -match "Carbon Black|CarbonBlack|Cb Defense") {
                    Write-Host "[INFO] Found CarbonBlack MSI: $($msi.Name)" -ForegroundColor Yellow
                }
            }
            catch {
                # Silent failure for permission issues
            }
        }
        Remove-Item "$env:TEMP\msi_check.log" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "[INFO] Could not scan Windows Installer cache" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uninstallation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: A system restart is REQUIRED to complete the removal." -ForegroundColor Yellow
Write-Host "Some components may remain until reboot." -ForegroundColor Yellow
Write-Host ""
pause
