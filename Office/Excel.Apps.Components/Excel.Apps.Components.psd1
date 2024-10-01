@{
    RootModule        = 'Excel.Apps.Components.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'd7a94e51-2532-4cc4-8dad-0784c9f0a6b9'
    Author            = 'Ironman Software'
    CompanyName       = 'Ironman Software'
    Copyright         = '(c) Ironman Software. All rights reserved.'
    Description       = 'Excel components for Apps.'
    FunctionsToExport = @(
        'New-UDExcelTable'
    )

    PrivateData       = @{
        PSData = @{
            Tags       = @('app', 'excel', 'office')
            LicenseUri = 'https://github.com/ironmansoftware/scripts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/ironmansoftware/scripts/tree/main/Office/Excel.Apps.Components'
            IconUri    = 'https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/app.png'
        } 
    } 
}

