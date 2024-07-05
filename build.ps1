param(
    $UserModulePath = "/home/runner/.local/share/powershell/Modules", 
    $ModuleUrl = "https://www.ironmansoftware.com/api/v1/module/$ENV:MODULEKEY",
    [Switch]$UpdateModuleDirectory
)

Function Build-RequiredModuleFiles {

    if (Test-Path -Path $UserModulePath) {
        $ModuleManifest = @{
            Modules = @()
        }

        [array]$RequiredModules = @()
        Get-ChildItem "$PSScriptRoot/**/*.psd1" -Recurse -Exclude "portalWidgets.psd1" | ForEach-Object {
            # Get .psd1 data
            $Data = Import-PowerShellDataFile $_.FullName

            # Get the RequiredModules
            if ($data.RequiredModules) {
                $RequiredModules = $RequiredModules + $data.RequiredModules
                Write-Host "Found required modules: $($data.RequiredModules)"
            }

            $ModuleInformation = @{
                Name        = [IO.Path]::GetFileNameWithoutExtension($_.FullName)
                Version     = $Data.ModuleVersion
                Description = $Data.Description
                Tags        = $Data.PrivateData.PSData.Tags
                Icon        = $Data.PrivateData.PSData.IconUri
                Functions   = $Data.FunctionsToExport
                Widgets     = @()
            }

            $ModuleDirectory = [IO.Path]::GetDirectoryName($_.FullName)

            Get-ChildItem $ModuleDirectory/**/portalWidgets.psd1 -Recurse | ForEach-Object {
                $ModuleInformation.Widgets += (Import-PowerShellDataFile $_.FullName).Items
            }

            $ModuleManifest.Modules += $ModuleInformation
        }

        If ($RequiredModules.Length -gt 0) {

            Push-Location $UserModulePath

            # Create the required module manifests
            ForEach ($module in $requiredModules) {
                if (Test-Path $module) {
                    Write-Output "Module $module already exists at $((Get-Location).Path)\$module"
                    continue
                }

                New-Item $module -type Directory 
                Write-Output "Creating empty .psd1 file for module $module at $((Get-Location).Path)\$module\$module.psd1"

                # Create manifest
                New-Item ".\$module\$module.psd1"
            }

            Pop-Location
        }
        $RequiredModules

        if ($UpdateModuleDirectory -or $ENV:UPDATE_MODULE_DIRECTORY -eq 'true') {
            $ModuleManifest | ConvertTo-Json -Depth 10 | Set-Content "$PSScriptRoot/output/Modules.json"
            Invoke-WebRequest -InFile "$PSScriptRoot/output/Modules.json" -Uri $ModuleUrl -Method "POST" -ContentType "application/json" -ErrorAction Continue  | Out-Null
            Remove-Item "$PSScriptRoot/output/Modules.json"
        }
    }
}

Remove-Item -Path "$PSScriptRoot/output/*.nupkg" -Force -ErrorAction SilentlyContinue # needed for local testing
New-Item -Path "$PSScriptRoot/output" -ItemType Directory -Force

$dependencies = Build-RequiredModuleFiles

Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue

Unregister-PSResourceRepository -Name PSUScriptLibrary -ErrorAction SilentlyContinue
Register-PSResourceRepository -Name PSUScriptLibrary -Uri "$PSScriptRoot/output"

#get a list of dependencies
# TODO: handle dependencies that we do not own, eg, install-module ImportExcel
# $dependencies = @('ActiveDirectory.Scripts')

# Publish Dependencies First
foreach ($dependency in $dependencies) {
    $dependencyPath = Get-ChildItem "$PSScriptRoot/**/$dependency*.psd1" -Exclude "portalWidgets.psd1" -Recurse | Where-Object { $_.Name.Replace('.psd1', '') -eq $dependency }
    if ($dependencyPath) {
        Write-Host "Publishing $dependencyPath"
        Publish-PSResource -Repository PSUScriptLibrary -Path $dependencyPath.FullName
        # $env:PSModulePath = $env:PSModulePath + ";$(Split-Path -Path $dependencyPath.Directory -Parent)"
        # $env:PSModulePath = $env:PSModulePath + ";$($dependencyPath.Directory)"
        # Import-Module $dependencyPath.FullName -Force -Verbose
        # write-host ($env:PSModulePath -split ';')
    }
}

# Then publish the rest of the resources
Get-ChildItem "$PSScriptRoot/**/*.psd1" -Exclude "portalWidgets.psd1" -Recurse | ForEach-Object {
    if ($_.BaseName -notin $dependencies) {
        Publish-PSResource -Repository PSUScriptLibrary -Path $_.FullName
    }
}