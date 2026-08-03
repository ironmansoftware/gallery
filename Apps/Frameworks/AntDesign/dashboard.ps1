$moduleRoot = if (-not [string]::IsNullOrWhiteSpace($HarnessScriptRoot)) {
    $HarnessScriptRoot
}
else {
    $PSScriptRoot
}

$modulePath = Join-Path $moduleRoot 'Devolutions.PowerShellUniversal.Frameworks.AntDesign.psd1'
Import-Module $modulePath -Force

@{
    dashboard = New-AntDesignDemo
    dashboardName = 'Ant Design Demo'
    developerLicense = $true
}