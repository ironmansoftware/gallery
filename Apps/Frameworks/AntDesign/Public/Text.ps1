function New-UDAntDesignText {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [Parameter(Mandatory)]
        [string]$Text
    )

    @{
        type = 'antd-text'
        id   = $Id
        text = $Text
    }
}