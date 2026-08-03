function New-UDAntDesignRate {
    <#
    .SYNOPSIS
    Creates an Ant Design rate descriptor.

    .DESCRIPTION
    Creates an antd-rate descriptor that maps the PowerShell command surface to the Ant Design Rate component used by the client runtime. The command mirrors the core Rate API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.

    .NOTES
    Show evaluation.
    A quick rating operation on something.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER AllowClear
    Whether clicking the current value clears the selection.

    .PARAMETER AllowHalf
    Enables half-step selection.

    .PARAMETER Character
    Specifies custom content rendered for each rating character. Provide plain text, descriptor content, or an Ant Design icon name.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design rate element.

    .PARAMETER Count
    Specifies how many rating characters are displayed.

    .PARAMETER DefaultValue
    Specifies the initial selected value.

    .PARAMETER Disabled
    Makes the rate read only.

    .PARAMETER Keyboard
    Enables keyboard interactions for the control.

    .PARAMETER Size
    Specifies the Ant Design rate size. Valid values are small, medium, and large.

    .PARAMETER Style
    Specifies inline styles applied to the Ant Design rate element.

    .PARAMETER Tooltips
    Specifies tooltip text for each rating character.

    .PARAMETER Value
    Specifies the current selected value.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered rate. Keys are emitted as data-* attributes.

    .PARAMETER OnChange
    Specifies the endpoint invoked when the selected value changes.

    .PARAMETER OnHoverChange
    Specifies the endpoint invoked when the hovered value changes.

    .EXAMPLE
    # Basic
    New-UDAntDesignRate

    Demonstrates the default Ant Design rating control.

    .EXAMPLE
    # Sizes
    @(
        New-UDAntDesignRate -Size small -DefaultValue 2
        New-UDAntDesignRate -DefaultValue 3
        New-UDAntDesignRate -Size large -DefaultValue 4
    )

    Shows the small, medium, and large Ant Design rate sizes.

    .EXAMPLE
    # Half star
    New-UDAntDesignRate -AllowHalf:$true -DefaultValue 2.5

    Enables half-step selection like the upstream half star example.

    .EXAMPLE
    # Show copywriting
    @(
        New-UDAntDesignRate -Tooltips @('terrible', 'bad', 'normal', 'good', 'wonderful')
        New-UDAntDesignTypography -Text 'normal'
    )

    Adds tooltip copy alongside the rating control to mirror the upstream copywriting example.

    .EXAMPLE
    # Read only
    New-UDAntDesignRate -Disabled -DefaultValue 3

    Renders a non-interactive rating control.

    .EXAMPLE
    # Clear star
    @(
        New-UDAntDesignTypography -Text 'allowClear: true'
        New-UDAntDesignRate -DefaultValue 3
        New-UDAntDesignTypography -Text 'allowClear: false'
        New-UDAntDesignRate -AllowClear:$false -DefaultValue 3
    )

    Demonstrates clearing the current value when clicking the selected character again.

    .EXAMPLE
    # Other character
    @(
        New-UDAntDesignRate -Character 'HeartFilled'
        New-UDAntDesignRate -Character 'A'
        New-UDAntDesignRate -Character '好'
    )

    Replaces the default star with icon and text characters.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [bool]$AllowClear,
        [bool]$AllowHalf,
        [object]$Character,
        [string]$ClassName,
        [int]$Count,
        [double]$DefaultValue,
        [switch]$Disabled,
        [bool]$Keyboard,
        [ValidateSet('small', 'medium', 'large')]
        [string]$Size,
        [hashtable]$Style,
        [string[]]$Tooltips,
        [double]$Value,
        [hashtable]$DataAttributes,
        [Endpoint]$OnChange,
        [Endpoint]$OnHoverChange
    )

    foreach ($endpoint in @($OnChange, $OnHoverChange)) {
        if ($null -ne $endpoint -and $endpoint.PSObject.Methods.Name -contains 'Register') {
            $endpoint.Register($Id, $PSCmdlet)
        }
    }

    $descriptor = @{
        type = 'antd-rate'
        id   = $Id
    }

    foreach ($property in 'AllowClear', 'AllowHalf', 'Character', 'ClassName', 'Count', 'DefaultValue', 'Keyboard', 'Size', 'Style', 'Tooltips', 'Value') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    if ($PSBoundParameters.ContainsKey('Disabled')) {
        $descriptor.disabled = [bool]$Disabled
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    if ($null -ne $OnChange) {
        $descriptor.onChange = $OnChange
    }

    if ($null -ne $OnHoverChange) {
        $descriptor.onHoverChange = $OnHoverChange
    }

    $descriptor
}