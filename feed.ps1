@{
    sources = @(
        @{
            name             = "feed"
            type             = "azure"
            container        = "feed"
            connectionString = "$ENV:StorageConnectionString"
        }
    )
} | ConvertTo-Json | Out-File "sleet.json"

dotnet tool install -g sleet
sleet push $PSScriptRoot\output