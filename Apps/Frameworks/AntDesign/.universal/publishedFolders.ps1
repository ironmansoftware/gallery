$assetPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\dist'))

if (Test-Path -LiteralPath $assetPath) {
    New-PSUPublishedFolder -Name 'AntDesign Dashboard Framework' -RequestPath '/frameworks/ant-design' -Path $assetPath -DefaultDocument @('index.html')
}
