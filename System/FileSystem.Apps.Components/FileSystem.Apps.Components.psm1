function New-UDFileSystemBrowser {
    param(
        [Parameter(Mandatory)]
        [string]$PublishedFolder
    )

    $PublishedFolderObj = Get-PSUPublishedFolder | Where-Object Name -eq $PublishedFolder

    New-UDGrid -Container -Children {
        New-UDGrid -SmallSize 2 -Children {
            New-UDTreeView -Node { New-UDTreeNode -Name $PublishedFolder -Id "$Repository$($PublishedFolderObj.Path)" } -OnNodeClicked {
                $Items = Get-ChildItem $EventData.Id -Directory
                $Items | ForEach-Object {
                    New-UDTreeNode -Name $_.Name -Id $_.FullName
                }

                $Page:Folder = $EventData.Id
                Sync-UDElement -Id 'files'
            }
        }

        New-UDGrid -SmallSize 10 -Children {
            New-UDDynamic -Id 'files' -Content {
                $Children = Get-ChildItem $Page:Folder | Select-Object Name
                New-UDTable -Id 'files' -Data $Children -Columns @(
                    New-UDTableColumn -Property Name
                )
            }
        }
    }
}