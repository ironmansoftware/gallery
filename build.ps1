Function Build-RequiredModuleFiles {

    if (Test-Path -Path "/home/runner/.local/share/powershell/Modules") {
        [array]$RequiredModules = @()
        Get-ChildItem "$PSScriptRoot/**/*.psd1" -Recurse | ForEach-Object {

            # Get .psd1 data
            $Data = Import-PowerShellDataFile $_.FullName

            # Get the RequiredModules
            if ($data.RequiredModules) {
                $RequiredModules = $RequiredModules + $data.RequiredModules
                Write-Host "Found required modules: $($data.RequiredModules))"
            }
        }

        If ($RequiredModules.Length -gt 0) {

            Set-Location '/home/runner/.local/share/powershell/Modules'

            # Create the required module manifests
            ForEach ($module in $requiredModules) {
                New-Item $module -type Directory
                Write-Output "Creating empty .psd1 file for module $module at $((Get-Location).Path)\$module\$module.psd1"

                # Create manifest
                New-Item ".\$module\$module.psd1"
            }
        }
    }
}
Build-RequiredModuleFiles

Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue

Remove-Item -Path "$PSScriptRoot/output/*.nupkg" -Force -ErrorAction SilentlyContinue # needed for local testing
New-Item -Path "$PSScriptRoot/output" -ItemType Directory -Force


Unregister-PSResourceRepository -Name PSUScriptLibrary -ErrorAction SilentlyContinue
Register-PSResourceRepository -Name PSUScriptLibrary -Uri "$PSScriptRoot/output"

#get a list of dependencies
# TODO: handle dependencies that we do not own, eg, install-module ImportExcel
$dependencies = @('ActiveDirectory.Scripts')

# Publish Dependencies First
foreach ($dependency in $dependencies) {
    $dependencyPath = Get-ChildItem "$PSScriptRoot/**/$dependency*.psd1" -Recurse | Where-Object { $_.Name.Replace('.psd1', '') -eq $dependency }
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
Get-ChildItem "$PSScriptRoot/**/*.psd1" -Recurse | ForEach-Object {
    if ($_.BaseName -notin $dependencies) {
        Publish-PSResource -Repository PSUScriptLibrary -Path $_.FullName
    }
}