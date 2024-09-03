@{
    RootModule        = 'FileSystem.Apps.Components.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '8ad6965e-9319-42e1-baa0-e88123549619'
    Author            = 'Ironman Software'
    CompanyName       = 'Ironman Software'
    Copyright         = '(c) Ironman Software. All rights reserved.'
    Description       = 'File System components for Apps.'
    FunctionsToExport = @(
        'New-UDFileSystemBrowser'
    )

    PrivateData       = @{
        PSData = @{
            Tags       = @('app', 'filesystem')
            LicenseUri = 'https://github.com/ironmansoftware/scripts/blob/main/LICENSE'
            ProjectUri = 'https://github.com/ironmansoftware/scripts/tree/main/System/FileSystem.Apps.Components'
            IconUri    = 'https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/app.png'
        } 
    } 
}

