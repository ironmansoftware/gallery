function New-UDCenter {
    <#
    .SYNOPSIS
    Center items within a dashboard.

    .DESCRIPTION
    Center items within a dashboard.

    .PARAMETER Content
    The items to center.

    .EXAMPLE
    New-UDCenter -Content {
        New-UDTypography -Text 'Loading groups' -Variant h5
        New-UDProgress -Circular
    }
    #>
    param([ScriptBlock]$Content)

    New-UDElement -tag div -Content $Content -Attributes @{
        style = @{
            textAlign = 'center'
            width     = '100%'
        }
    }
}

function New-UDRight {
    <#
    .SYNOPSIS
    Pull items to the right

    .DESCRIPTION
    Pull items to the right

    .PARAMETER Content
    The content to move to the right.
    #>
    [CmdletBinding()]
    param([ScriptBlock]$Content)

    New-UDElement -Tag 'div' -Content $Content -Attributes @{
        style = @{
            "display"         = "flex"
            "justify-content" = "flex-end"
            "margin-left"     = "auto"
            "margin-right"    = "0"
            "align-items"     = "flex-end"
        }
    }
}

function New-UDConfirm {
    <#
    .SYNOPSIS
    Creates a confirmation dialog in Universal Dashboard.

    .DESCRIPTION
    The New-UDConfirm function creates a confirmation dialog in Universal Dashboard. It displays a modal dialog with a specified text and provides "Yes" and "No" buttons for the user to confirm or cancel the action.

    .PARAMETER Text
    Specifies the text to be displayed in the confirmation dialog. The default value is "Are you sure?".

    .EXAMPLE
    PS> if(New-UDConfirm -Text "Do you want to delete this item?") {
        # Delete the item
    }

    This example creates a confirmation dialog with the specified text "Do you want to delete this item?".

    .OUTPUTS
    System.Boolean
    Returns $true if the user clicks "Yes" and $false if the user clicks "No".

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Text = 'Are you sure?'
    )
    $Page:Result = $null
    Show-UDModal -Content {
        New-UDTypography -Text $Text
    } -Footer {
        New-UDButton -Text "Yes" -OnClick {
            $Page:Result = $true
            Hide-UDModal
        } -Style @{"border-radius" = "4px" }

        New-UDButton -Text "No" -OnClick {
            $Page:Result = $false
            Hide-UDModal
        } -Style @{"border-radius" = "4px" }

    } -Persistent
    while ($null -eq $Page:Result) {
        Start-Sleep -Milliseconds 100
    }
    return $Page:Result
}

function New-UDLineBreak {
    <#
    .SYNOPSIS
    Creates a line break element for Universal Dashboard.

    .DESCRIPTION
    The New-UDLineBreak function creates a line break element for Universal Dashboard. It can be used to add vertical spacing between elements.

    .PARAMETER Height
    Specifies the height of the line break element. The default value is "20px".

    .PARAMETER Fixed
    Indicates whether the height of the line break element is fixed using br. If this switch is specified, the height parameter is ignored.

    .EXAMPLE
    New-UDLineBreak
    Creates a line break element with a default height of 20 pixels.

    .EXAMPLE
    New-UDLineBreak -Height "30px"
    Creates a line break element with a height of 30 pixels.

    .EXAMPLE
    New-UDLineBreak -Fixed
    Creates a line break element with a fixed height.

    #>
    [CmdletBinding(DefaultParameterSetName = 'Variable Height')]
    param(
        [Parameter(ParameterSetName = 'Variable Height')]
        [string]$Height = "20px",
        [Parameter(ParameterSetName = 'Fixed Height')]
        [switch]$Fixed
    )
    Process {
        if ($Fixed) {
            New-UDElement -Tag 'div' -Content {
                New-UDElement -Tag 'br'
            }
        }
        else {
            New-UDElement -Tag 'div' -Content {} -Attributes @{
                style = @{
                    height = $Height
                }
            }
        }
    }
}


function Show-UDEventData {
    <#
    .SYNOPSIS
    Shows the $EventData object as JSON in a modal.

    .DESCRIPTION
    Shows the $EventData object as JSON in a modal.
    #>
    Show-UDModal -Content {
        New-UDElement -Tag 'pre' -Content {
            ConvertTo-Json -InputObject $EventData
        }
    }
}

function Reset-UDPage {
    <#
    .SYNOPSIS
    Reloads the current page.

    .DESCRIPTION
    Reloads the current page. This uses JavaScript directly.
    #>
    Invoke-UDJavaScript "window.location.reload()"
}

function Show-UDObject {
    <#
    .SYNOPSIS
    Displays an object in a modal dialog with syntax highlighting and copy functionality.

    .DESCRIPTION
    The Show-UDObject function displays an object in a modal dialog with syntax highlighting and copy functionality. It takes an input object and optional depth parameter to control the depth of the object's properties that will be displayed.

    .PARAMETER InputObject
    The input object to be displayed in the modal dialog.

    .PARAMETER Depth
    The maximum depth of the object's properties that will be displayed. Default value is 20.

    .EXAMPLE
    $myObject = Get-MyObject
    Show-UDObject -InputObject $myObject -Depth 10

    This example retrieves an object using the Get-MyObject function and displays it in a modal dialog with a maximum depth of 10.
    #>
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        $InputObject,
        $depth = 20
    )

    process {
        Show-UDModal -Header {
            New-UDTypography -Text $($inputObject.gettype()) -Variant h4
        } -Content {
            New-UDDynamic -LoadingComponent { New-UDProgress } -Content {
                New-UDSyntaxHighlighter -Code (ConvertTo-Json -InputObject $inputObject -Depth $depth) -Language json
            }
            New-UDButton -Text "Copy" -Icon Copy -OnClick { Set-UDClipboard -Data (ConvertTo-Json -InputObject $inputObject -Depth $depth) }
        }
    }
}

function Get-UDCache {
    <#
    .SYNOPSIS
    Returns all items in the $Cache: scope.

    .DESCRIPTION
    Returns all items in the $Cache: scope.
    #>
    [UniversalDashboard.Execution.GlobalCachedVariableProvider]::Cache
}

function Show-UDVariable {
    <#
    .SYNOPSIS
    Shows variables and their values in a modal.

    .DESCRIPTION
    Shows variables and their values in a modal.

    .PARAMETER Name
    A name. If not specified, all variables are returned.

    .EXAMPLE
    Show-UDVariable -Name 'EventData'
    #>
    param($Name)

    Show-UDModal -Content {
        New-UDDynamic -Content {
            $Variables = Get-Variable -Name "*$Name"

            New-UDTable -Title 'Variables' -Icon (New-UDIcon -Icon 'SquareRootVariable') -Data $Variables -Columns @(
                New-UDTableColumn -Property Name -ShowFilter
                New-UDTableColumn -Property Value -Render {
                    [string]$EventData.Value
                } -ShowFilter
            ) -ShowPagination -ShowFilter
        } -LoadingComponent {
            New-UDSkeleton
        }

    } -Footer {
        New-UDButton -Text 'Close' -OnClick {
            Hide-UDModal
        }
    } -FullScreen
}

function Show-UDThemeColorViewer {
    <#
    .SYNOPSIS
    Shows all the theme colors in a modal.

    .DESCRIPTION
    Shows all the theme colors in a modal.
    #>
    Show-UDModal -Header {
        New-UDTypography -Variant h3 -Content {
            New-UDIcon -Icon  Images
            "Themes"
        }
    } -Content {
        New-UDDynamic -Content {
            New-UDRow -Columns {
                Get-UDTheme | ForEach-Object {
                    New-UDColumn -SmallSize 4 -Content {
                        $Theme = Get-UDTheme -Name $_

                        New-UDStack -Direction row -Content {
                            New-UDCard -Title "$_ - Light" -Content {
                                New-UDElement -Content {
                                    "Background"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.light.palette.text.primary
                                        backgroundColor = $Theme.light.palette.background.default
                                    }
                                }  -Tag 'div'

                                New-UDElement -Content {
                                    "Primary"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.light.palette.text.primary
                                        backgroundColor = $Theme.light.palette.primary.main
                                    }
                                }  -Tag 'div'

                                New-UDElement -Content {
                                    "Secondary"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.light.palette.text.primary
                                        backgroundColor = $Theme.light.palette.secondary.main
                                    }
                                } -Tag 'div'
                            }

                            New-UDCard -Title "$_ - Dark" -Content {
                                New-UDElement -Content {
                                    "Background"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.dark.palette.text.primary
                                        backgroundColor = $Theme.dark.palette.background.default
                                    }
                                }  -Tag 'div'

                                New-UDElement -Content {
                                    "Primary"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.dark.palette.text.primary
                                        backgroundColor = $Theme.dark.palette.primary.main
                                    }
                                }  -Tag 'div'

                                New-UDElement -Content {
                                    "Secondary"
                                } -Attributes @{
                                    style = @{
                                        color           = $Theme.dark.palette.text.primary
                                        backgroundColor = $Theme.dark.palette.secondary.main
                                    }
                                } -Tag 'div'
                            }
                        }



                        # $Theme.light.palette.background.default
                        # $Theme.light.palette.text.primary
                        # $Theme.light.palette.primary.main
                        # $Theme.light.palette.secondary.main

                        # $Theme.dark.palette.background.default
                        # $Theme.dark.palette.text.primary
                        # $Theme.dark.palette.primary.main
                        # $Theme.dark.palette.secondary.main
                    }
                }
            }
        } -LoadingComponent {
            New-UDSkeleton
        }

    } -FullWidth -MaxWidth xl
}

Function ConvertTo-UDJson {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [int]
        $Depth
    )

    begin {
        $childDepth = $Depth - 1

        $isType = {
            [CmdletBinding()]
            param (
                [Object]
                $InputObject,

                [Type]
                $Type
            )

            if ($InputObject -is $Type) {
                return $true
            }

            $psTypes = @($InputObject.PSTypeNames | ForEach-Object -Process {
                    $_ -replace '^Deserialized.'
                })

            $Type.FullName -in $psTypes
        }
    }

    process {
        if ($null -eq $InputObject) {
            $null
        }
        elseif ((&$isType -InputObject $InputObject -Type ([Enum])) -and $Depth -ge 0) {
            # ToString() gives the human readable value but I thought it better to give some more context behind
            # these types.
            @{
                Type   = ($InputObject.PSTypeNames[0] -replace '^Deserialized.')
                String = $InputObject.ToString()
                Value  = [int]$InputObject
            }
        }
        elseif ($InputObject -is [DateTime]) {
            # The offset is based on the Kind value
            # Unspecified leaves it off
            # UTC set it to Z
            # Local sets it to the local timezone
            $InputObject.ToString('o')
        }
        elseif (&$isType -InputObject $InputObject -Type ([DateTimeOffset])) {
            # If this is a deserialized object (from an executable) we need recreate a live DateTimeOffset
            if ($InputObject -isnot [DateTimeOffset]) {
                $InputObject = New-Object -TypeName DateTimeOffset $InputObject.DateTime, $InputObject.Offset
            }
            $InputObject.ToString('o')
        }
        elseif (&$isType -InputObject $InputObject -Type ([Type])) {
            if ($Depth -lt 0) {
                $InputObject.FullName
            }
            else {
                # This type is very complex with circular properties, only return somewhat useful properties.
                # BaseType might be a string (serialized output), try and convert it back to a Type if possible.
                $baseType = $InputObject.BaseType -as [Type]
                if ($baseType) {
                    $baseType = Convert-OutputObject -InputObject $baseType -Depth $childDepth
                }

                @{
                    Name                  = $InputObject.Name
                    FullName              = $InputObject.FullName
                    AssemblyQualifiedName = $InputObject.AssemblyQualifiedName
                    BaseType              = $baseType
                }
            }
        }
        elseif ($InputObject -is [string]) {
            $InputObject
        }
        elseif (&$isType -InputObject $InputObject -Type ([switch])) {
            $InputObject.IsPresent
        }
        elseif ($InputObject.GetType().IsValueType) {
            # We want to display just this value and not any properties it has (if any).
            $InputObject
        }
        elseif ($Depth -lt 0) {
            # This must occur after the above to ensure ints and other ValueTypes are preserved as is.
            [string]$InputObject
        }
        elseif ($InputObject -is [Collections.IList]) {
            , @(foreach ($obj in $InputObject) {
                    Convert-OutputObject -InputObject $obj -Depth $childDepth
                })
        }
        elseif ($InputObject -is [Collections.IDictionary]) {
            $newObj = @{}

            # Replicate ConvertTo-Json, props are replaced by keys if they share the same name. We only want ETS
            # properties as well.
            foreach ($prop in $InputObject.PSObject.Properties) {
                if ($prop.MemberType -notin @('AliasProperty', 'ScriptProperty', 'NoteProperty')) {
                    continue
                }
                $newObj[$prop.Name] = Convert-OutputObject -InputObject $prop.Value -Depth $childDepth
            }
            foreach ($kvp in $InputObject.GetEnumerator()) {
                $newObj[$kvp.Key] = Convert-OutputObject -InputObject $kvp.Value -Depth $childDepth
            }
            $newObj
        }
        else {
            $newObj = @{}
            foreach ($prop in $InputObject.PSObject.Properties) {
                $newObj[$prop.Name] = Convert-OutputObject -InputObject $prop.Value -Depth $childDepth
            }
            $newObj
        }
    }
}