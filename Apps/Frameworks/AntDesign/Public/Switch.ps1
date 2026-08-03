function New-UDAntDesignSwitch {
    <#
    .SYNOPSIS
    Creates an Ant Design switch descriptor.

    .DESCRIPTION
    Creates an antd-switch descriptor that maps the PowerShell command surface to the Ant Design Switch component used by the client runtime. The command mirrors the core Switch API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs while still supporting PowerShell Universal endpoint callbacks.

    .NOTES
    If you need to represent the switching between two states or on-off state.
    The difference between Switch and Checkbox is that Switch will trigger a state change directly when you toggle it, while Checkbox is generally used for state marking, which should work in conjunction with submit operation.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Checked
    Determines whether the switch is on.

    .PARAMETER DefaultChecked
    Specifies the initial unchecked or checked state for the switch.

    .PARAMETER Disabled
    Disables the switch.

    .PARAMETER Loading
    Shows the Ant Design loading state for the switch.

    .PARAMETER Size
    Specifies the Ant Design switch size. Valid values are default and small.

    .PARAMETER CheckedChildren
    Specifies the content shown when the switch is checked. Provide plain text, descriptor content, or an Ant Design icon name.

    .PARAMETER UncheckedChildren
    Specifies the content shown when the switch is unchecked. Provide plain text, descriptor content, or an Ant Design icon name.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design switch element.

    .PARAMETER ClassNames
    Specifies semantic DOM class mappings passed to the Ant Design switch classNames prop.

    .PARAMETER Styles
    Specifies semantic DOM inline style mappings passed to the Ant Design switch styles prop.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered switch. Keys are emitted as data-* attributes.

    .PARAMETER OnChange
    Specifies the endpoint invoked when the checked state changes.

    .PARAMETER OnClick
    Specifies the endpoint invoked when the switch is clicked.

    .PARAMETER Value
    Specifies a value sent back through the click and change event payload.

    .EXAMPLE
    # Basic
    @(
        New-UDAntDesignSwitch
        New-UDAntDesignSwitch -DefaultChecked $true
    )

    Demonstrates the most basic usage of Ant Design switch descriptors.

    .EXAMPLE
    # Disabled
    @(
        New-UDAntDesignSwitch -Disabled
        New-UDAntDesignSwitch -DefaultChecked $true -Disabled
    )

    Shows the disabled state of the Ant Design switch for both unchecked and checked states.

    .EXAMPLE
    # Text & icon
    @(
        New-UDAntDesignSwitch -CheckedChildren '1' -UncheckedChildren '0'
        New-UDAntDesignSwitch -DefaultChecked $true -CheckedChildren 'CheckOutlined' -UncheckedChildren 'CloseOutlined'
    )

    Adds checked and unchecked content so the switch can show text and icon states like the upstream examples.

    .EXAMPLE
    # Two sizes
    @(
        New-UDAntDesignSwitch -DefaultChecked $true
        New-UDAntDesignSwitch -DefaultChecked $true -Size small
    )

    Uses the default and small Ant Design switch sizes.

    .EXAMPLE
    # Loading
    @(
        New-UDAntDesignSwitch -Loading
        New-UDAntDesignSwitch -DefaultChecked $true -Loading
    )

    Marks a pending state of the switch while preserving unchecked and checked loading examples.

    .EXAMPLE
    # Custom semantic dom styling
    New-UDAntDesignSwitch -DefaultChecked $true -CheckedChildren 'On' -UncheckedChildren 'Off' -Styles @{
        root = @{
            backgroundColor = '#fa8c16'
        }
        indicator = @{
            backgroundColor = '#fff7e6'
        }
    }

    Customizes semantic DOM styles by passing style objects through the Ant Design switch styles prop.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [bool]$Checked,
        [bool]$DefaultChecked,
        [switch]$Disabled,
        [switch]$Loading,
        [ValidateSet('default', 'small')]
        [string]$Size,
        [object]$CheckedChildren,
        [object]$UncheckedChildren,
        [string]$ClassName,
        [hashtable]$ClassNames,
        [hashtable]$Styles,
        [hashtable]$DataAttributes,
        [Endpoint]$OnChange,
        [Endpoint]$OnClick,
        [object]$Value
    )

    foreach ($endpoint in @($OnChange, $OnClick)) {
        if ($null -ne $endpoint -and $endpoint.PSObject.Methods.Name -contains 'Register') {
            $endpoint.Register($Id, $PSCmdlet)
        }
    }

    $descriptor = @{
        type = 'antd-switch'
        id   = $Id
    }

    foreach ($property in 'Checked', 'DefaultChecked', 'Size', 'CheckedChildren', 'UncheckedChildren', 'ClassName', 'ClassNames', 'Styles') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    foreach ($switchProperty in 'Disabled', 'Loading') {
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

    if ($null -ne $OnClick) {
        $descriptor.onClick = $OnClick
    }

    if ($PSBoundParameters.ContainsKey('Value')) {
        $descriptor.value = $Value
    }

    $descriptor
}