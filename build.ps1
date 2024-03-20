Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue

Remove-Item -Path "$PSScriptRoot/output/*.nupkg" -Force -ErrorAction SilentlyContinue # needed for local testing
New-Item -Path "$PSScriptRoot/output" -ItemType Directory -Force


Unregister-PSResourceRepository -Name PSUScriptLibrary -ErrorAction SilentlyContinue
Register-PSResourceRepository -Name PSUScriptLibrary -Uri "$PSScriptRoot/output"

#get a list of dependencies
# TODO: handle dependencies that we do not own, eg, install-module ImportExcel
$dependencies = @('ActiveDirectory.Scripts')

# Publish Dependencies First
foreach($dependency in $dependencies) {
    $dependencyPath = Get-ChildItem "$PSScriptRoot/**/$dependency*.psd1" -Recurse | Where-Object {$_.Name.Replace('.psd1', '') -eq $dependency}
    if ($dependencyPath) {
        Write-Host "Publishing $dependencyPath"
        Publish-PSResource -Repository PSUScriptLibrary -Path $dependencyPath.FullName
        $env:PSModulePath = $env:PSModulePath + ";$($dependencyPath.Directory)"
    }
}

# Then publish the rest of the resources
Get-ChildItem "$PSScriptRoot/**/*.psd1" -Recurse | ForEach-Object {
    if ($_.BaseName -notin $dependencies) {
        Publish-PSResource -Repository PSUScriptLibrary -Path $_.FullName
    }
}