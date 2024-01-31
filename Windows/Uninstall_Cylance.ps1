$serviceName = "CylanceSvc"

if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    $cylanceGuid = Get-WmiObject -Class Win32_Product | 
                    Where-Object { $_.Name -match "Cylance PROTECT" } | 
                    Select-Object -ExpandProperty IdentifyingNumber

    $msiExecArgs = "/x $cylanceGuid /qn /norestart /L*v $Env:Temp\cylance-uninstall.log"
    Start-Process -FilePath "$Env:SystemRoot\System32\msiexec.exe" -ArgumentList $msiExecArgs -Wait
}
