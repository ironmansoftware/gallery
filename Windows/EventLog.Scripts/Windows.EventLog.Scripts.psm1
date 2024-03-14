function Get-PSUEventLog {
    <#
    .SYNOPSIS
    Get Windows Event Log
    
    .DESCRIPTION
    This function gets the Windows Event Log
    
    .PARAMETER LogName
    The name of the log to get
    
    .PARAMETER MaxEvents
    The maximum number of events to get
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogName,
        [Parameter(Mandatory = $false)]
        [int]$MaxEvents = 100
    )

    Get-EventLog -LogName $logName -Newest $maxEvents
}