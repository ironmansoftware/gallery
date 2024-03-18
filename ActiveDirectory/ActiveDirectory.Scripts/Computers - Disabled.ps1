function Get-UDDisabledComputers {
    <#
    .SYNOPSIS
    Gets a list of disabled computers.
    
    .DESCRIPTION
    Gets a list of disabled computers.
    #>
    [System.ComponentModel.DisplayName("Disabled Computers")]
    param()
    Get-ADComputer -Filter { (Enabled -eq $False) } -ResultPageSize 2000 -ResultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName | Select-Object Name, OperatingSystem, SamAccountName, DistinguishedName
}