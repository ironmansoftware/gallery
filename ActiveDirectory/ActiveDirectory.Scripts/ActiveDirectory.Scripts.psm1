Get-ChildItem $PSScriptRoot\*.ps1 | ForEach-Object {
    . $_.FullName
}