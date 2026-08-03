$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

if (Test-Path -Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' -File |
        Sort-Object -Property Name |
        ForEach-Object {
            . $_.FullName
        }
}

if (Test-Path -Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter '*.ps1' -File |
        Sort-Object -Property Name |
        ForEach-Object {
            . $_.FullName
        }
}

Export-ModuleMember -Function @(
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
