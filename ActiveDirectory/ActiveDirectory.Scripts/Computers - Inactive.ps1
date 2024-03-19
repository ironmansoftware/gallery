function Get-UDInactiveComputers {
    <#
    .SYNOPSIS
    Gets a list of inactive computers.
    
    .DESCRIPTION
    Gets a list of inactive computers.
    #>
    [System.ComponentModel.DisplayName("Inactive Computers")]
    param()
    $DaysInactive = 30
    $time = (Get-Date).Adddays( - ($DaysInactive))
    Get-ADComputer -Filter { LastLogonTimeStamp -lt $time } -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName | Select-Object Name, OperatingSystem, SamAccountName, DistinguishedName
}