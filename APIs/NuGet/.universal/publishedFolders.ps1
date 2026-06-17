$NuGetFeedPath = if ($env:PSU_NUGET_FEED_PATH) {
    $env:PSU_NUGET_FEED_PATH
}
elseif ($env:Data__RepositoryPath) {
    Join-Path $env:Data__RepositoryPath '.nuget'
}
else {
    Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'PowerShellUniversal\NuGet'
}

$FlatContainerPath = Join-Path $NuGetFeedPath 'v3-flatcontainer'
$RegistrationPath = Join-Path $NuGetFeedPath 'v3\registration'

New-Item -ItemType Directory -Path $FlatContainerPath -Force | Out-Null
New-Item -ItemType Directory -Path $RegistrationPath -Force | Out-Null

New-PSUPublishedFolder -RequestPath '/nuget/static/v3-flatcontainer' -Path $FlatContainerPath -Name 'NuGet Flat Container'
New-PSUPublishedFolder -RequestPath '/nuget/static/v3/registration' -Path $RegistrationPath -Name 'NuGet Registration Metadata'