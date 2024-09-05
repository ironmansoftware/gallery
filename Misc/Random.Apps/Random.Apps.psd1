@{
    RootModule        = 'Random.Apps.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '36bc5153-97b0-4447-8b45-64b0cb31213d'
    Author            = 'Ironman Software'
    CompanyName       = 'Ironman Software'
    Copyright         = '(c) Ironman Software. All rights reserved.'
    Description       = 'Random tools for apps.'
    FunctionsToExport = @(
        'New-UDRandom'
    )

    PrivateData       = @{
        PSData = @{
            Tags       = @('app', 'random')
            LicenseUri = 'https://github.com/ironmansoftware/scripts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/ironmansoftware/scripts/tree/main/Misc/Random.Apps'
            IconUri    = 'https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/app.png'
        } 
    } 
}

