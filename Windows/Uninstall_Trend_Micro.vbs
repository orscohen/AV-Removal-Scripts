Set WshShell = WScript.CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")
strApp = "C:\Program Files\Trend Micro\OfficeScan Client\ntrmv.exe"
strPara1 = "-980223"
strPara2 = "-331"

If OSarchitecture() Then
    strApp = "C:\Program Files\Trend Micro\OfficeScan Client\ntrmv.exe"
Else
    strApp = "C:\Program Files (x86)\Trend Micro\OfficeScan Client\ntrmv.exe"
End If

Dim myExit, return
myExit = 0

currentDirectory = Left(WScript.ScriptFullName, (Len(WScript.ScriptFullName)) - (Len(WScript.ScriptName)))

' Run UnInstall of TrendMicro
WshShell.Run Chr(34) & strApp & Chr(34) & " " & Chr(34) & strPara1 & Chr(34) & " " & Chr(34) & strPara2 & Chr(34), 0, True

' Activate the loop until the result is "myExit" = 1
Do Until myExit = 1
    ' Triggers the check on the active "ntrmv.exe" process
    CheckTrendMicro
Loop

Sub CheckTrendMicro()
    myExit = 1
    Set service = GetObject("winmgmts:")

    ' Check for an active ntrmv.exe process.
    For Each Process In Service.InstancesOf("Win32_Process")
        If Process.Name = "ntrmv.exe" Then
            myExit = 0
            ' Wait for X time before checking for the running process again.
            WScript.Sleep(60000)
        End If
    Next
End Sub

' Function to check if architecture is X86 or X64 (AMD64)'
Function OSarchitecture()
    Const HKLM = &H80000002
    Dim strComputer, WshShell, sOSarch
    strComputer = "."
    Set WshShell = WScript.CreateObject("WScript.Shell")
    sOSarch = WshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")

    If sOSarch = "x86" Then
        OSarchitecture = False
    End If

    If sOSarch = "AMD64" Then
        OSarchitecture = True
    End If

    Set WshShell = Nothing
End Function
