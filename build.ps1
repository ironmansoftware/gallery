Function Build-RequiredModuleFiles {

    if (Test-Path -Path "/home/runner/.local/share/powershell/Modules") {
        # Get .psd1 data
        $Data = Import-PowerShellDataFile .\**\*.psd1

        # Get the RequiredModules
        [array]$RequiredModules = $data.RequiredModules


        If ($RequiredModules) {

            Set-Location '/home/runner/.local/share/powershell/Modules'

            # Create the required module manifests
            ForEach ($module in $requiredModules) {
                $moduleName = $module.ModuleName
                New-Item $moduleName -type Directory
                Write-Output "Creating empty .psd1 file for module $modulename at $((Get-Location).Path)\$moduleName\$moduleName.psd1"

                # Create manifest
                New-Item ".\$moduleName\$moduleName.psd1"
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