@{
    RootModule        = 'PowerShellUniversal.NuGet.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '8c096e3b-8c04-4a8f-9bab-3261b32d69f3'
    Author            = 'Devolutions, Inc.'
    CompanyName       = 'Devolutions, Inc.'
    Copyright         = '(c) Devolutions, Inc. All rights reserved.'
    Description       = 'A NuGet V3 package feed for PowerShell Universal.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Get-PSUNuGetFeedPath',
        'Get-PSUNuGetRequestBaseUrl',
        'Test-PSUNuGetSafeSegment',
        'New-PSUNuGetJsonFileResponse',
        'Initialize-PSUNuGetRepository',
        'Publish-PSUNuGetPackage',
        'Get-PSUNuGetPackage',
        'Set-PSUNuGetPackageListed',
        'Remove-PSUNuGetPackage',
        'Update-PSUNuGetStaticMetadata',
        'Get-PSUNuGetServiceIndex',
        'Search-PSUNuGetPackage',
        'Get-PSUNuGetAutocomplete'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('PowerShell', 'NuGet', 'PowerShellUniversal')
            LicenseUri = 'https://github.com/devolutions/powershell-universal-gallery/blob/main/LICENSE'
            ProjectUri = 'https://github.com/devolutions/powershell-universal-gallery/tree/main/APIs/NuGet'
            IconUri    = 'https://raw.githubusercontent.com/devolutions/powershell-universal-gallery/main/images/script.png'
        }
    }
}