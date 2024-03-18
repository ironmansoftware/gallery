function Get-UDDomainControllers {
    <#
    .SYNOPSIS
    Gets a list of domain controllers.
    
    .DESCRIPTION
    Gets a list of domain controllers.
    #>
    [System.ComponentModel.DisplayName("Domain Controllers")]
    param()
    Get-ADDomainController | Select-Object HostName, IPv4Address, Domain, OperatingSystem
}