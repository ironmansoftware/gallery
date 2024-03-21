$Modules = 0
$Functions = 0
$Apps = 0
Get-ChildItem $PSScriptRoot\*.psd1 -Recurse | ForEach-Object {
    $Modules++
    $Manifest = Import-PowerShellDataFile $_.FullName
    [array]$functionsToExport = $Manifest.FunctionsToExport
    $Functions += $functionsToExport.Length

    $Manifest.PrivateData.PSData.Tags | ForEach-Object {
        if ($_ -eq "powershell-app" -or $_ -eq 'blazor-app') {
            $Apps++
        }
    }
}

Write-Host "Modules: $Modules"
Write-Host "Functions: $Functions"
Write-Host "Apps: $Apps"
