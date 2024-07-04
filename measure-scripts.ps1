$Modules = 0
$Functions = 0
$Apps = 0
$Widgets = 0

Get-ChildItem $PSScriptRoot\*.psd1 -Recurse -Exclude "portalWidgets.psd1" | ForEach-Object {
    $Modules++
    $Manifest = Import-PowerShellDataFile $_.FullName
    [array]$functionsToExport = $Manifest.FunctionsToExport
    $Functions += $functionsToExport.Length

    $Manifest.PrivateData.PSData.Tags | ForEach-Object {
        if ($_ -eq "powershell-app") {
            $Apps++
        }
    }
}

Get-ChildItem $PSScriptRoot\*\portalWidgets.psd1 -Recurse | ForEach-Object {
    $Widgets += (Import-PowerShellDataFile $_.FullName).Items.Length
}

Write-Host "Modules: $Modules"
Write-Host "Functions: $Functions"
Write-Host "Apps: $Apps"
Write-Host "Widgets: $Widgets"
