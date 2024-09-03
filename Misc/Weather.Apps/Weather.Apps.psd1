@{
    RootModule        = 'Weather.Apps.psm1'
    ModuleVersion     = '1.0.1'
    GUID              = '36bc5153-97b0-4447-8b45-64b0cb31213d'
    Author            = 'Ironman Software'
    CompanyName       = 'Ironman Software'
    Copyright         = '(c) Ironman Software. All rights reserved.'
    Description       = 'Weather components for Apps.'
    FunctionsToExport = @(
        'New-UDWeatherCard'
    )

    PrivateData       = @{
        PSData = @{
            Tags        = @('app', 'weather')
            LicenseUri  = 'https://github.com/ironmansoftware/scripts/blob/main/LICENSE'
            ProjectUri  = 'https://github.com/ironmansoftware/scripts/tree/main/Misc/Weather.Apps'
            IconUri     = 'https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/app.png'
            DisplayName = 'PowerShell Scripts'
        } 
    } 
}

