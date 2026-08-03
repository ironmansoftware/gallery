function New-UDAntDesignCheckbox {
    <#
    .SYNOPSIS
    Creates an Ant Design checkbox descriptor.

    .DESCRIPTION
    Creates an antd-checkbox descriptor that maps the PowerShell command surface to the Ant Design Checkbox component used by the client runtime. The command mirrors the core Checkbox API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.

    .NOTES
    Used for selecting multiple values from several options.
    If you use only one checkbox, it is the same as using Switch to toggle between two states. The difference is that Switch will trigger the state change directly, but Checkbox just marks the state as changed and this needs to be submitted.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Label
    Specifies the checkbox label content. Provide plain text or descriptor content.

    .PARAMETER Checked
    Determines whether the checkbox is selected.

    .PARAMETER DefaultChecked
    Specifies the initial selected state of the checkbox.

    .PARAMETER Disabled
    Disables the checkbox.

    .PARAMETER Indeterminate
    Displays the checkbox in the indeterminate state.

    .PARAMETER AutoFocus
    Automatically focuses the checkbox when it is rendered.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design checkbox wrapper.

    .PARAMETER ClassNames
    Specifies semantic DOM class mappings passed to the Ant Design checkbox classNames prop.

    .PARAMETER Styles
    Specifies semantic DOM inline style mappings passed to the Ant Design checkbox styles prop.

    .PARAMETER Style
    Specifies inline styles applied to the Ant Design checkbox wrapper.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered checkbox. Keys are emitted as data-* attributes.

    .PARAMETER OnChange
    Specifies the endpoint invoked when the checked state changes.

    .PARAMETER Value
    Specifies a value sent back through the change event payload.

    .EXAMPLE
    # Basic
    @(
        New-UDAntDesignCheckbox -Label 'Remember me'
        New-UDAntDesignCheckbox -Label 'Send status updates' -DefaultChecked $true
    )

    Demonstrates the default unchecked and checked Ant Design checkbox states.

    .EXAMPLE
    # Disabled
    @(
        New-UDAntDesignCheckbox -Label 'Archived item' -Disabled
        New-UDAntDesignCheckbox -Label 'Pinned item' -DefaultChecked $true -Disabled
    )

    Shows disabled checkbox states for unchecked and checked options.

    .EXAMPLE
    # Indeterminate
    New-UDAntDesignCheckbox -Label 'Partially selected permissions' -Indeterminate

    Renders the checkbox in the indeterminate state, which is useful for partial selection flows.

    .EXAMPLE
    # Custom styling
    New-UDAntDesignCheckbox -DefaultChecked $true -Label 'Styled option' -Style @{
        color = '#d46b08'
        backgroundColor = '#fff7e6'
        paddingInline = '12px'
        paddingBlock = '6px'
        borderRadius = '8px'
    }

    Applies wrapper-level inline styling to the checkbox so the option can match surrounding content.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Label,
        [bool]$Checked,
        [bool]$DefaultChecked,
        [switch]$Disabled,
        [switch]$Indeterminate,
        [switch]$AutoFocus,
        [string]$ClassName,
        [hashtable]$ClassNames,
        [hashtable]$Styles,
        [hashtable]$Style,
        [hashtable]$DataAttributes,
        [Endpoint]$OnChange,
        [object]$Value
    )

    if ($null -ne $OnChange -and $OnChange.PSObject.Methods.Name -contains 'Register') {
        $OnChange.Register($Id, $PSCmdlet)
    }

    $descriptor = @{
        type = 'antd-checkbox'
        id   = $Id
    }

    foreach ($property in 'Label', 'Checked', 'DefaultChecked', 'ClassName', 'ClassNames', 'Styles', 'Style', 'Value') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    foreach ($switchProperty in 'Disabled', 'Indeterminate', 'AutoFocus') {
        if ($PSBoundParameters.ContainsKey($switchProperty)) {
            $descriptor[$switchProperty.Substring(0, 1).ToLowerInvariant() + $switchProperty.Substring(1)] = [bool]$PSBoundParameters[$switchProperty]
        }
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    if ($null -ne $OnChange) {
        $descriptor.onChange = $OnChange
    }

    $descriptor
}