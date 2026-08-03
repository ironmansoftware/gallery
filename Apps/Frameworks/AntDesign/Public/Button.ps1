function New-UDAntDesignButton {
    <#
    .SYNOPSIS
    Creates an Ant Design button descriptor.

    .DESCRIPTION
    Creates an antd-button descriptor that maps the PowerShell command surface to the core Ant Design Button TypeScript definition used by the client runtime. The command mirrors the Ant Design Button API closely so the documented PowerShell examples can follow the same usage patterns as the upstream docs.

    .NOTES
    A button represents an operation or a short sequence of operations.
    Use a primary button for the main action in a section, and keep it to one primary action when possible.
    Use default buttons for secondary actions, dashed buttons for add-more style actions, text buttons for the least prominent actions, and link buttons for navigation.
    Use danger for destructive actions, ghost when the button sits on a strong background, disabled when the action is unavailable, and loading to prevent repeated submissions.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Text
    Specifies the plain text content rendered inside the button.

    .PARAMETER Content
    Specifies descriptor content rendered inside the button when you need more than plain text.

    .PARAMETER Icon
    Specifies descriptor content rendered in the Ant Design icon slot.

    .PARAMETER Type
    Specifies the legacy Ant Design button type shortcut. Valid values are default, primary, dashed, link, and text.

    .PARAMETER Color
    Specifies the Ant Design button color token.

    .PARAMETER Variant
    Specifies the Ant Design button variant.

    .PARAMETER Shape
    Specifies the button shape.

    .PARAMETER Size
    Specifies the button size.

    .PARAMETER Disabled
    Disables the button.

    .PARAMETER Loading
    Shows the Ant Design loading state.

    .PARAMETER LoadingDelay
    Delays the loading spinner by the specified number of milliseconds.

    .PARAMETER LoadingIcon
    Specifies descriptor content or an Ant Design icon name rendered inside the loading indicator.

    .PARAMETER Ghost
    Renders the button with Ant Design ghost styling.

    .PARAMETER Danger
    Applies the Ant Design danger treatment.

    .PARAMETER Block
    Expands the button to the full available width.

    .PARAMETER Href
    Renders the button as a link when specified.

    .PARAMETER HtmlType
    Specifies the underlying HTML button type.

    .PARAMETER AutoInsertSpace
    Controls Ant Design automatic spacing for two Chinese characters.

    .PARAMETER IconPosition
    Specifies whether the icon renders before or after the button content.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design button element.

    .PARAMETER RootClassName
    Specifies a root class name applied by Ant Design.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered button. Keys are emitted as data-* attributes.

    .PARAMETER OnClick
    Specifies the endpoint invoked when the button is clicked.

    .PARAMETER Value
    Specifies the value sent back through the click event payload.

    .EXAMPLE
    # Syntactic sugar
    @(
        New-UDAntDesignButton -Text 'Primary Button' -Type primary
        New-UDAntDesignButton -Text 'Default Button' -Type default
        New-UDAntDesignButton -Text 'Dashed Button' -Type dashed
        New-UDAntDesignButton -Text 'Text Button' -Type text
        New-UDAntDesignButton -Text 'Link Button' -Type link -Href 'https://ant.design/components/button/'
    )

    Uses the Ant Design type shortcuts to mirror the core button styles from the upstream docs.

    .EXAMPLE
    # Color and variant
    @(
        New-UDAntDesignButton -Text 'Primary Solid' -Color primary -Variant solid
        New-UDAntDesignButton -Text 'Default Outlined' -Color default -Variant outlined
        New-UDAntDesignButton -Text 'Success Filled' -Color green -Variant filled
        New-UDAntDesignButton -Text 'Danger Text' -Color danger -Variant text -Danger
        New-UDAntDesignButton -Text 'Geekblue Link' -Color geekblue -Variant link -Href 'https://ant.design/components/button/'
    )

    Combines color and variant to show the newer styling model behind the Ant Design type aliases.

    .EXAMPLE
    # Icon
    @(
        New-UDAntDesignButton -Text 'Search Primary' -Type primary -Icon 'SearchOutlined'
        New-UDAntDesignButton -Text 'Download File' -Icon 'DownloadOutlined'
        New-UDAntDesignButton -Text 'External Link' -Type link -Icon 'LinkOutlined' -Href 'https://ant.design/components/button/'
    )

    Adds Ant Design icons through the PowerShell command surface while keeping the same button API.

    .EXAMPLE
    # Icon placement
    @(
        New-UDAntDesignButton -Text 'Search Start' -Type primary -Icon 'SearchOutlined' -IconPosition start
        New-UDAntDesignButton -Text 'Search End' -Type primary -Icon 'SearchOutlined' -IconPosition end
    )

    Moves the icon before or after the label to match the icon placement examples from the docs.

    .EXAMPLE
    # Size
    @(
        New-UDAntDesignButton -Text 'Large Action' -Type primary -Size large
        New-UDAntDesignButton -Text 'Medium Action' -Type default -Size middle
        New-UDAntDesignButton -Text 'Small Action' -Type dashed -Size small
    )

    Shows the three Ant Design button sizes exposed by the PowerShell wrapper.

    .EXAMPLE
    # Disabled
    @(
        New-UDAntDesignButton -Text 'Primary Disabled' -Type primary -Disabled
        New-UDAntDesignButton -Text 'Default Disabled' -Type default -Disabled
        New-UDAntDesignButton -Text 'Dashed Disabled' -Type dashed -Disabled
        New-UDAntDesignButton -Text 'Text Disabled' -Type text -Disabled
        New-UDAntDesignButton -Text 'Link Disabled' -Type link -Disabled -Href 'https://ant.design/components/button/'
    )

    Disables each style to document the unavailable state consistently.

    .EXAMPLE
    # Loading
    @(
        New-UDAntDesignButton -Text 'Saving Changes' -Type primary -Loading
        New-UDAntDesignButton -Text 'Queued Request' -Loading -LoadingDelay 400
        New-UDAntDesignButton -Text 'Syncing Data' -Type default -Loading -LoadingIcon 'LoadingOutlined'
    )

    Uses loading states to communicate in-progress work and to discourage repeated clicks.

    .EXAMPLE
    # Multiple buttons
    @(
        New-UDAntDesignButton -Text 'Primary Action' -Type primary
        New-UDAntDesignButton -Text 'Secondary Action' -Type default
        New-UDAntDesignButton -Text 'More Actions' -Type dashed -Icon 'EllipsisOutlined'
    )

    Follows the Ant Design guidance of one primary action plus secondary actions in the same group.

    .EXAMPLE
    # Ghost button
    @(
        New-UDAntDesignButton -Text 'Ghost Primary' -Type primary -Ghost
        New-UDAntDesignButton -Text 'Ghost Default' -Type default -Ghost
        New-UDAntDesignButton -Text 'Ghost Dashed' -Type dashed -Ghost
    )

    Shows the transparent ghost treatment that is useful on stronger or more colorful backgrounds.

    .EXAMPLE
    # Danger buttons
    @(
        New-UDAntDesignButton -Text 'Delete Record' -Type primary -Danger
        New-UDAntDesignButton -Text 'Danger Default' -Type default -Danger
        New-UDAntDesignButton -Text 'Danger Text' -Type text -Danger
        New-UDAntDesignButton -Text 'Danger Link' -Type link -Danger -Href 'https://ant.design/components/button/'
    )

    Applies the danger treatment for destructive or high-risk actions.

    .EXAMPLE
    # Block button
    @(
        New-UDAntDesignButton -Text 'Full Width Primary' -Type primary -Block
        New-UDAntDesignButton -Text 'Full Width Default' -Type default -Block
    )

    Expands buttons to the available width to match the block layout from the Ant Design docs.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [string]$Text,
        [object]$Content,
        [object]$Icon,
        [ValidateSet('default', 'primary', 'dashed', 'link', 'text')]
        [string]$Type,
        [ValidateSet('default', 'primary', 'danger', 'blue', 'purple', 'cyan', 'green', 'magenta', 'pink', 'red', 'orange', 'yellow', 'volcano', 'geekblue', 'lime', 'gold')]
        [string]$Color,
        [ValidateSet('outlined', 'dashed', 'solid', 'filled', 'text', 'link')]
        [string]$Variant,
        [ValidateSet('default', 'circle', 'round')]
        [string]$Shape,
        [ValidateSet('small', 'middle', 'large')]
        [string]$Size,
        [switch]$Disabled,
        [switch]$Loading,
        [int]$LoadingDelay,
        [object]$LoadingIcon,
        [switch]$Ghost,
        [switch]$Danger,
        [switch]$Block,
        [string]$Href,
        [ValidateSet('submit', 'button', 'reset')]
        [string]$HtmlType,
        [bool]$AutoInsertSpace,
        [ValidateSet('start', 'end')]
        [string]$IconPosition,
        [string]$ClassName,
        [string]$RootClassName,
        [hashtable]$DataAttributes,
        [Endpoint]$OnClick,
        [object]$Value
    )

    if (-not $PSBoundParameters.ContainsKey('Text') -and -not $PSBoundParameters.ContainsKey('Content')) {
        throw 'New-UDAntDesignButton requires -Text or -Content.'
    }

    if ($null -ne $OnClick -and $OnClick.PSObject.Methods.Name -contains 'Register') {
        $OnClick.Register($Id, $PSCmdlet)
    }

    $descriptor = @{
        type = 'antd-button'
        id   = $Id
    }

    if ($PSBoundParameters.ContainsKey('Text')) {
        $descriptor.text = $Text
    }

    if ($PSBoundParameters.ContainsKey('Content')) {
        $descriptor.content = $Content
    }

    if ($PSBoundParameters.ContainsKey('Icon')) {
        $descriptor.icon = $Icon
    }

    if ($PSBoundParameters.ContainsKey('Type')) {
        $descriptor.buttonType = $Type
    }

    foreach ($property in 'Color', 'Variant', 'Shape', 'Size', 'Href', 'HtmlType', 'IconPosition', 'ClassName', 'RootClassName') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    foreach ($switchProperty in 'Disabled', 'Ghost', 'Danger', 'Block') {
        if ($PSBoundParameters.ContainsKey($switchProperty)) {
            $descriptor[$switchProperty.Substring(0, 1).ToLowerInvariant() + $switchProperty.Substring(1)] = [bool]$PSBoundParameters[$switchProperty]
        }
    }

    if ($PSBoundParameters.ContainsKey('AutoInsertSpace')) {
        $descriptor.autoInsertSpace = $AutoInsertSpace
    }

    if ($PSBoundParameters.ContainsKey('Loading') -or $PSBoundParameters.ContainsKey('LoadingDelay') -or $PSBoundParameters.ContainsKey('LoadingIcon')) {
        if ($PSBoundParameters.ContainsKey('LoadingDelay') -or $PSBoundParameters.ContainsKey('LoadingIcon')) {
            $loadingDescriptor = @{}

            if ($PSBoundParameters.ContainsKey('LoadingDelay')) {
                $loadingDescriptor.delay = $LoadingDelay
            }

            if ($PSBoundParameters.ContainsKey('LoadingIcon')) {
                $loadingDescriptor.icon = $LoadingIcon
            }

            $descriptor.loading = $loadingDescriptor
        }
        else {
            $descriptor.loading = [bool]$Loading
        }
    }
    elseif ($PSBoundParameters.ContainsKey('Loading')) {
        $descriptor.loading = [bool]$Loading
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    if ($PSBoundParameters.ContainsKey('Value')) {
        $descriptor.value = $Value
    }

    if ($null -ne $OnClick) {
        $descriptor.onClick = $OnClick
    }

    $descriptor
}