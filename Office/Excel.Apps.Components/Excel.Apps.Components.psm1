function New-UDExcelTable {
    <#
    .SYNOPSIS
    A function that creates a table from an Excel file.
    
    .DESCRIPTION
    A function that creates a table from an Excel file.
    
    .PARAMETER Path
    The path to the Excel file. If the path is not rooted, the function will look for the file in the repository.
    
    .EXAMPLE
    PS > New-UDExcelTable -Path 'data.xlsx'
    
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path 
    )

    if (-not [IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $Repository $Path
    }

    $Content = Import-Excel $Path

    New-UDTable -Data $Content
} 