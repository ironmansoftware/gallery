function New-UDAntDesignTypography {
    <#
    .SYNOPSIS
    Creates an Ant Design typography descriptor.

    .DESCRIPTION
    Creates an antd-typography descriptor that maps the PowerShell command surface to the Ant Design Typography family used by the client runtime. The command wraps Typography.Text, Typography.Title, Typography.Paragraph, and Typography.Link so the documented PowerShell examples can follow the same patterns shown in the upstream Ant Design typography docs.

    .NOTES
    Basic text writing, including headings, body text, lists, and more.
    When you need to display a title or paragraph contents in Articles/Blogs/Notes.
    When you need copyable, editable, or ellipsis text treatments.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Kind
    Specifies which Ant Design typography primitive to render. Valid values are text, title, paragraph, and link.

    .PARAMETER Text
    Specifies the plain text content rendered by the typography component.

    .PARAMETER Content
    Specifies descriptor content rendered by the typography component when you need more than plain text.

    .PARAMETER TypographyType
    Specifies the Ant Design typography tone. Valid values are secondary, success, warning, and danger.

    .PARAMETER Level
    Specifies the title level for title typography. Valid values are 1 through 5.

    .PARAMETER Href
    Specifies the link target when Kind is link.

    .PARAMETER Target
    Specifies the anchor target when Kind is link.

    .PARAMETER Code
    Renders the content with Ant Design code styling.

    .PARAMETER Delete
    Renders the content with deleted text styling.

    .PARAMETER Disabled
    Renders the content with disabled styling.

    .PARAMETER Italic
    Renders the content with italic styling.

    .PARAMETER Keyboard
    Renders the content with keyboard styling.

    .PARAMETER Mark
    Renders the content with highlighted styling.

    .PARAMETER Strong
    Renders the content with strong emphasis.

    .PARAMETER Underline
    Renders the content with underline styling.

    .PARAMETER Copyable
    Enables the Ant Design copyable affordance.

    .PARAMETER CopyText
    Specifies the text copied when the copyable action is used.

    .PARAMETER CopyIcon
    Specifies custom icon content for the copyable action. Provide two items to mirror the Ant Design [copy, copied] icon pair.

    .PARAMETER CopyTooltips
    Specifies the copyable tooltips. Pass `$false` to hide them or an array with two values to mirror the default pair.

    .PARAMETER CopyFormat
    Specifies the MIME type used for copied content.

    .PARAMETER Editable
    Enables the Ant Design editable affordance.

    .PARAMETER EditText
    Specifies the editable text value shown while editing.

    .PARAMETER EditIcon
    Specifies custom icon content for the edit action.

    .PARAMETER EditTooltip
    Specifies the editable tooltip content. Pass `$false` to hide the tooltip.

    .PARAMETER EditTriggerType
    Specifies how editing is triggered. Valid values are icon, text, and both.

    .PARAMETER EditEnterIcon
    Specifies the confirmation icon shown while editing. Pass `$false` to remove it.

    .PARAMETER EditMaxLength
    Specifies the maximum edit length.

    .PARAMETER Ellipsis
    Enables Ant Design ellipsis handling.

    .PARAMETER EllipsisRows
    Specifies the maximum number of rows rendered before ellipsis is applied.

    .PARAMETER EllipsisExpandable
    Adds the Ant Design expand affordance for ellipsis content.

    .PARAMETER EllipsisSuffix
    Specifies the suffix preserved at the end of ellipsis content.

    .PARAMETER EllipsisSymbol
    Specifies the custom expand label or content.

    .PARAMETER EllipsisTooltip
    Specifies tooltip content shown for ellipsis text. Pass `$false` to hide it.

    .PARAMETER EllipsisDefaultExpanded
    Expands the ellipsis content by default.

    .PARAMETER OnClick
    Specifies the endpoint invoked when the typography component is clicked.

    .PARAMETER OnCopy
    Specifies the endpoint invoked after copyable text is copied.

    .PARAMETER OnChange
    Specifies the endpoint invoked when editable text is committed.

    .PARAMETER OnEditStart
    Specifies the endpoint invoked when editable mode starts.

    .PARAMETER OnEditEnd
    Specifies the endpoint invoked when editable mode ends.

    .PARAMETER OnEditCancel
    Specifies the endpoint invoked when editable mode is cancelled.

    .PARAMETER OnExpand
    Specifies the endpoint invoked when ellipsis content expands or collapses.

    .PARAMETER Value
    Specifies the value sent back through click events.

    .EXAMPLE
    # Basic
    @(
        New-UDAntDesignTypography -Kind title -Level 2 -Text 'Typography'
        New-UDAntDesignTypography -Kind paragraph -Text 'Basic text writing, including headings, body text, lists, and more.'
        New-UDAntDesignTypography -Kind paragraph -Text 'Typography is the foundation for readable titles, paragraphs, links, and inline semantic emphasis in the Ant Design framework.'
    )

    Displays the document-style introduction shown in the upstream typography examples.

    .EXAMPLE
    # Title Component
    @(
        New-UDAntDesignTypography -Kind title -Level 1 -Text 'h1. Ant Design'
        New-UDAntDesignTypography -Kind title -Level 2 -Text 'h2. Ant Design'
        New-UDAntDesignTypography -Kind title -Level 3 -Text 'h3. Ant Design'
        New-UDAntDesignTypography -Kind title -Level 4 -Text 'h4. Ant Design'
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'h5. Ant Design'
    )

    Shows the five title levels exposed by the Ant Design Typography.Title wrapper.

    .EXAMPLE
    # Text and Link Component
    @(
        New-UDAntDesignTypography -Text 'Ant Design (default)'
        New-UDAntDesignTypography -Text 'Ant Design (secondary)' -TypographyType secondary
        New-UDAntDesignTypography -Text 'Ant Design (success)' -TypographyType success
        New-UDAntDesignTypography -Text 'Ant Design (warning)' -TypographyType warning
        New-UDAntDesignTypography -Text 'Ant Design (danger)' -TypographyType danger
        New-UDAntDesignTypography -Text 'Ant Design (disabled)' -Disabled
        New-UDAntDesignTypography -Text 'Ant Design (mark)' -Mark
        New-UDAntDesignTypography -Text 'Ant Design (code)' -Code
        New-UDAntDesignTypography -Text 'Ant Design (keyboard)' -Keyboard
        New-UDAntDesignTypography -Text 'Ant Design (underline)' -Underline
        New-UDAntDesignTypography -Text 'Ant Design (delete)' -Delete
        New-UDAntDesignTypography -Text 'Ant Design (strong)' -Strong
        New-UDAntDesignTypography -Text 'Ant Design (italic)' -Italic
        New-UDAntDesignTypography -Kind link -Text 'Ant Design (Link)' -Href 'https://ant.design/' -Target '_blank'
    )

    Mirrors the text-style examples from the Ant Design docs, including semantic emphasis and links.

    .EXAMPLE
    # Copyable
    @(
        New-UDAntDesignTypography -Text 'This is a copyable text.' -Copyable
        New-UDAntDesignTypography -Text 'Replace copy text.' -Copyable -CopyText 'Hello, Ant Design!'
        New-UDAntDesignTypography -Text 'Hide copy tooltips.' -Copyable -CopyTooltips $false
    )

    Enables the Ant Design copy affordance with default, overridden, and tooltip-free variants.

    .EXAMPLE
    # Editable
    @(
        New-UDAntDesignTypography -Kind paragraph -Text 'This is an editable text.' -Editable
        New-UDAntDesignTypography -Kind paragraph -Text 'Click the icon or text to start editing.' -Editable -EditTriggerType both -EditTooltip 'Edit typography'
    )

    Uses the Ant Design editable affordance and keeps the edited value in the client preview.

    .EXAMPLE
    # Ellipsis
    @(
        New-UDAntDesignTypography -Kind paragraph -Text 'Ant Design, a design language for background applications, is refined by Ant UED Team. Ant Design, a design language for background applications, is refined by Ant UED Team. Ant Design, a design language for background applications, is refined by Ant UED Team.' -Ellipsis -EllipsisRows 2 -EllipsisExpandable -EllipsisSymbol 'Expand'
        New-UDAntDesignTypography -Kind paragraph -Text 'Ant Design, a design language for background applications, is refined by Ant UED Team.' -Ellipsis -EllipsisRows 1 -EllipsisSuffix '--Ant Design' -EllipsisTooltip 'Ellipsis preview'
    )

    Demonstrates expandable and suffix-preserving ellipsis patterns from the upstream docs.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [ValidateSet('text', 'title', 'paragraph', 'link')]
        [string]$Kind = 'text',
        [string]$Text,
        [object]$Content,
        [ValidateSet('secondary', 'success', 'warning', 'danger')]
        [string]$TypographyType,
        [ValidateRange(1, 5)]
        [int]$Level,
        [string]$Href,
        [ValidateSet('_blank', '_self', '_parent', '_top')]
        [string]$Target,
        [switch]$Code,
        [switch]$Delete,
        [switch]$Disabled,
        [switch]$Italic,
        [switch]$Keyboard,
        [switch]$Mark,
        [switch]$Strong,
        [switch]$Underline,
        [switch]$Copyable,
        [string]$CopyText,
        [object[]]$CopyIcon,
        [object]$CopyTooltips,
        [ValidateSet('text/plain', 'text/html')]
        [string]$CopyFormat,
        [switch]$Editable,
        [string]$EditText,
        [object]$EditIcon,
        [object]$EditTooltip,
        [ValidateSet('icon', 'text', 'both')]
        [string[]]$EditTriggerType,
        [object]$EditEnterIcon,
        [int]$EditMaxLength,
        [switch]$Ellipsis,
        [int]$EllipsisRows,
        [switch]$EllipsisExpandable,
        [string]$EllipsisSuffix,
        [object]$EllipsisSymbol,
        [object]$EllipsisTooltip,
        [bool]$EllipsisDefaultExpanded,
        [Endpoint]$OnClick,
        [Endpoint]$OnCopy,
        [Endpoint]$OnChange,
        [Endpoint]$OnEditStart,
        [Endpoint]$OnEditEnd,
        [Endpoint]$OnEditCancel,
        [Endpoint]$OnExpand,
        [object]$Value
    )

    if (-not $PSBoundParameters.ContainsKey('Text') -and -not $PSBoundParameters.ContainsKey('Content')) {
        throw 'New-UDAntDesignTypography requires -Text or -Content.'
    }

    foreach ($endpoint in @($OnClick, $OnCopy, $OnChange, $OnEditStart, $OnEditEnd, $OnEditCancel, $OnExpand)) {
        if ($null -ne $endpoint -and $endpoint.PSObject.Methods.Name -contains 'Register') {
            $endpoint.Register($Id, $PSCmdlet)
        }
    }

    $descriptor = @{
        type = 'antd-typography'
        id   = $Id
        kind = $Kind
    }

    if ($PSBoundParameters.ContainsKey('Text')) {
        $descriptor.text = $Text
    }

    if ($PSBoundParameters.ContainsKey('Content')) {
        $descriptor.content = $Content
    }

    foreach ($property in 'TypographyType', 'Level', 'Href', 'Target') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    foreach ($switchProperty in 'Code', 'Delete', 'Disabled', 'Italic', 'Keyboard', 'Mark', 'Strong', 'Underline') {
        if ($PSBoundParameters.ContainsKey($switchProperty)) {
            $descriptor[$switchProperty.Substring(0, 1).ToLowerInvariant() + $switchProperty.Substring(1)] = [bool]$PSBoundParameters[$switchProperty]
        }
    }

    if ($PSBoundParameters.ContainsKey('Copyable') -or $PSBoundParameters.ContainsKey('CopyText') -or $PSBoundParameters.ContainsKey('CopyIcon') -or $PSBoundParameters.ContainsKey('CopyTooltips') -or $PSBoundParameters.ContainsKey('CopyFormat')) {
        $copyableDescriptor = @{}

        if ($PSBoundParameters.ContainsKey('CopyText')) {
            $copyableDescriptor['text'] = $CopyText
        }

        if ($PSBoundParameters.ContainsKey('CopyIcon')) {
            $copyableDescriptor['icon'] = @($CopyIcon)
        }

        if ($PSBoundParameters.ContainsKey('CopyTooltips')) {
            $copyableDescriptor['tooltips'] = $CopyTooltips
        }

        if ($PSBoundParameters.ContainsKey('CopyFormat')) {
            $copyableDescriptor['format'] = $CopyFormat
        }

        if ($copyableDescriptor.Count -eq 0 -and $Copyable) {
            $descriptor.copyable = $true
        }
        else {
            $descriptor.copyable = $copyableDescriptor
        }
    }

    if ($PSBoundParameters.ContainsKey('Editable') -or $PSBoundParameters.ContainsKey('EditText') -or $PSBoundParameters.ContainsKey('EditIcon') -or $PSBoundParameters.ContainsKey('EditTooltip') -or $PSBoundParameters.ContainsKey('EditTriggerType') -or $PSBoundParameters.ContainsKey('EditEnterIcon') -or $PSBoundParameters.ContainsKey('EditMaxLength')) {
        $editableDescriptor = @{}

        if ($PSBoundParameters.ContainsKey('EditText')) {
            $editableDescriptor['text'] = $EditText
        }

        if ($PSBoundParameters.ContainsKey('EditIcon')) {
            $editableDescriptor['icon'] = $EditIcon
        }

        if ($PSBoundParameters.ContainsKey('EditTooltip')) {
            $editableDescriptor['tooltip'] = $EditTooltip
        }

        if ($PSBoundParameters.ContainsKey('EditTriggerType')) {
            $editableDescriptor['triggerType'] = @($EditTriggerType)
        }

        if ($PSBoundParameters.ContainsKey('EditEnterIcon')) {
            $editableDescriptor['enterIcon'] = $EditEnterIcon
        }

        if ($PSBoundParameters.ContainsKey('EditMaxLength')) {
            $editableDescriptor['maxLength'] = $EditMaxLength
        }

        if ($editableDescriptor.Count -eq 0 -and $Editable) {
            $descriptor.editable = $true
        }
        else {
            $descriptor.editable = $editableDescriptor
        }
    }

    if ($PSBoundParameters.ContainsKey('Ellipsis') -or $PSBoundParameters.ContainsKey('EllipsisRows') -or $PSBoundParameters.ContainsKey('EllipsisExpandable') -or $PSBoundParameters.ContainsKey('EllipsisSuffix') -or $PSBoundParameters.ContainsKey('EllipsisSymbol') -or $PSBoundParameters.ContainsKey('EllipsisTooltip') -or $PSBoundParameters.ContainsKey('EllipsisDefaultExpanded')) {
        $ellipsisDescriptor = @{}

        if ($PSBoundParameters.ContainsKey('EllipsisRows')) {
            $ellipsisDescriptor['rows'] = $EllipsisRows
        }

        if ($PSBoundParameters.ContainsKey('EllipsisExpandable')) {
            $ellipsisDescriptor['expandable'] = [bool]$EllipsisExpandable
        }

        if ($PSBoundParameters.ContainsKey('EllipsisSuffix')) {
            $ellipsisDescriptor['suffix'] = $EllipsisSuffix
        }

        if ($PSBoundParameters.ContainsKey('EllipsisSymbol')) {
            $ellipsisDescriptor['symbol'] = $EllipsisSymbol
        }

        if ($PSBoundParameters.ContainsKey('EllipsisTooltip')) {
            $ellipsisDescriptor['tooltip'] = $EllipsisTooltip
        }

        if ($PSBoundParameters.ContainsKey('EllipsisDefaultExpanded')) {
            $ellipsisDescriptor['defaultExpanded'] = $EllipsisDefaultExpanded
        }

        if ($ellipsisDescriptor.Count -eq 0 -and $Ellipsis) {
            $descriptor.ellipsis = $true
        }
        else {
            $descriptor.ellipsis = $ellipsisDescriptor
        }
    }

    foreach ($endpointProperty in 'OnClick', 'OnCopy', 'OnChange', 'OnEditStart', 'OnEditEnd', 'OnEditCancel', 'OnExpand') {
        $endpointValue = Get-Variable -Name $endpointProperty -ValueOnly

        if ($null -ne $endpointValue) {
            $descriptor[$endpointProperty.Substring(0, 1).ToLowerInvariant() + $endpointProperty.Substring(1)] = $endpointValue
        }
    }

    if ($PSBoundParameters.ContainsKey('Value')) {
        $descriptor.value = $Value
    }

    $descriptor
}