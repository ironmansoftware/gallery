Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue

Remove-Item -Path "$PSScriptRoot/output/**/*.nupkg" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path "$PSScriptRoot/output" -ItemType Directory -Force

Unregister-PSResourceRepository -Name PSUScriptLibrary -ErrorAction SilentlyContinue
Register-PSResourceRepository -Name PSUScriptLibrary -Uri "$PSScriptRoot/output" 

Get-ChildItem "$PSScriptRoot/**/*.psd1" -Recurse | ForEach-Object {
    Publish-PSResource -Repository PSUScriptLibrary -Path $_.FullName
}