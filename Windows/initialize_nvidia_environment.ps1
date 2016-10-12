# File: initiliaze_nvidia_environment.ps1
# Author: StrayWarrior
# Date:   2016-10-12
# Description: Add Nvidia-smi.exe to PATH; Add TdrDelay entry to registry to allow long-time CUDA kernel execution.
# Usage: powershell -executionpolicy RemoteSigned -File initiliaze_nvidia_environment.ps1

if (Get-Childitem -path env:NVTOOLSEXT_PATH -ErrorAction SilentlyContinue)
{
    $NVIDIA_PATH = Get-Childitem -path env:NVTOOLSEXT_PATH
    $NVISMI_PATH = $NVIDIA_PATH.value + "\..\NVSMI"
}
else
{
    $NVIDIA_PATH = Get-Childitem -path env:PROGRAMFILES
    $NVISMI_PATH = $NVIDIA_PATH.value + "\NVIDIA Corporation\NVSMI"
}

if (Test-Path $NVISMI_PATH)
{
    $NVISMI_PATH = [System.IO.Path]::GetFullPath($NVISMI_PATH)
    $NEW_PATH = $NVISMI_PATH + ";" + $env:PATH
    Write-Host "[Info] Setting System Path to:"  -foregroundcolor "Yellow"
    Write-Host $NEW_PATH
    $user_input = Read-Host "To continue, please enter [Y/n]"
    if ($user_input.Equals("Y"))
    {
        [Environment]::SetEnvironmentVariable( "Path", $NEW_PATH, [System.EnvironmentVariableTarget]::Machine )
    }
}
else
{
    Write-Host "[Error] Nvidia Corporation Directory Not Found."
}

if (Get-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers')
{
    Write-Host "[Info] Adding TdrDelay Registry Entry to HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -foregroundcolor "Yellow"
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'TdrDelay' -PropertyType DWord -Value 0x10000 -Force
}

Write-Host "[Info] All tasks done." -foregroundcolor "Yellow"