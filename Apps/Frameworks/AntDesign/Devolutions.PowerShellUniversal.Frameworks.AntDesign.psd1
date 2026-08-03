@{
    RootModule        = 'Devolutions.PowerShellUniversal.Frameworks.AntDesign.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '458668d8-d3f4-4f68-bdc5-4f24836b4bd5'
    Author            = 'Devolutions, Inc.'
    CompanyName       = 'Devolutions, Inc.'
    Copyright         = '(c) Devolutions, Inc. All rights reserved.'
    Description       = 'Ant Design dashboard framework scaffold for PowerShell Universal.'
    FunctionsToExport = @(
        'Get-PSUAntDesignFrameworkAssetBasePath',
        'Get-PSUAntDesignFrameworkEntryPoint',
        'New-UDAntDesignText',
        'New-UDAntDesignButton',
        'New-UDAntDesignCheckbox',
        'New-UDAntDesignCol',
        'New-UDAntDesignInput',
        'New-UDAntDesignLayout',
        'New-UDAntDesignLayoutContent',
        'New-UDAntDesignLayoutFooter',
        'New-UDAntDesignLayoutHeader',
        'New-UDAntDesignLayoutSider',
        'New-UDAntDesignRate',
        'New-UDAntDesignRow',
        'New-UDAntDesignSwitch',
        'New-UDAntDesignTypography',
        'Show-AntDesignMessage',
        'New-AntDesignDemo',
        'New-AntDesignDemoApp'
    )
    PrivateData       = @{
        PSData = @{
            Tags       = @('PowerShellUniversal', 'framework', 'app', 'dashboard', 'antd')
            LicenseUri = 'https://github.com/devolutions/powershell-universal-gallery/blob/main/LICENSE'
            ProjectUri = 'https://github.com/devolutions/powershell-universal-gallery/tree/main/Apps/Frameworks/AntDesign'
            IconUri    = 'https://raw.githubusercontent.com/devolutions/powershell-universal-gallery/main/images/app.png'
        }
    }
}
