function Get-PSUInstalledModule {
    <#
    .SYNOPSIS
    Get installed modules
    
    .DESCRIPTION
    Get installed modules
    #>
    Get-Module -ListAvailable
}

function Get-PSUAssembly {
    <#
    .SYNOPSIS
    Get loaded assemblies
    
    .DESCRIPTION
    Get loaded assemblies
    #>
    [System.AppDomain]::CurrentDomain.GetAssemblies()
}

function Get-PSUSystemInfo {
    <#
    .SYNOPSIS
    Get system information
    
    .DESCRIPTION
    Get system information
    #>
    @{
        OS                = [System.Environment]::OSVersion.VersionString
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        CLRVersion        = [System.Environment]::Version
        ProcessorCount    = [System.Environment]::ProcessorCount
        MachineName       = [System.Environment]::MachineName
        UserName          = [System.Environment]::UserName
    }
}

