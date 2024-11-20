$global:url = "https://raw.githubusercontent.com/ChrisTitusTech/winutil/refs/heads/main/config/tweaks.json"
$global:revert = $false
Function Set-WinUtilService {
    <#

    .SYNOPSIS
        Changes the startup type of the given service

    .PARAMETER Name
        The name of the service to modify

    .PARAMETER StartupType
        The startup type to set the service to

    .EXAMPLE
        Set-WinUtilService -Name "HomeGroupListener" -StartupType "Manual"

    #>
    param (
        $Name,
        $StartupType
    )
    try {
        Write-Host "Setting Service $Name to $StartupType"

        # Check if the service exists
        $service = Get-Service -Name $Name -ErrorAction Stop

        # Service exists, proceed with changing properties
        $service | Set-Service -StartupType $StartupType -ErrorAction Stop
    } catch {
        Write-Warning "Unable to set $Name due to unhandled exception"
        Write-Warning $_.Exception.Message
    }

}


$config = Invoke-WebRequest $url | ConvertFrom-Json 

foreach ( $service in $config.WPFTweaksServices.service ) {
    $changeservice = $true
    try {
        $serviceRunning = Get-Service -Name $service.Name -ErrorAction Stop
        if(!($serviceRunning.StartType.ToString() -eq $service.OriginalType)) {
            Write-Host "Service $($serviceRunning.Name) was changed in the past to $($serviceRunning.StartType.ToString()) from it's original type of $($service.OriginalType), will not change it to $($service.StartupType)"
            $changeservice = $false
        }
    } catch {
        Write-Warning "Service $($service.Name) was not found"
        $changeservice = $false
    }
    if($changeservice) {
        Write-Host "$($service.Name) and state is $($serviceRunning.StartupType)"
        Set-WinUtilService -Name $service.Name -StartupType $service.StartupType
    }
    if($revert) {
        Set-WinUtilService -Name $service.Name -StartupType $service.OriginalType
    }
}