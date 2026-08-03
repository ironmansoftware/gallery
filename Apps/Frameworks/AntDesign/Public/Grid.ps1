function New-UDAntDesignRow {
    <#
    .SYNOPSIS
    Creates an Ant Design grid row descriptor.

    .DESCRIPTION
    Creates an antd-row descriptor that maps the PowerShell command surface to the Ant Design Row component used by the client runtime. Use grid rows as the outer layout container for Ant Design grid columns so dashboard content can be arranged in the standard 24-column grid system.

    .NOTES
    Use rows to define horizontal layout bands and place only Ant Design grid columns directly inside the row content.
    Grid rows support horizontal and vertical gutters, flex alignment, and wrapping.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Content
    Specifies the descriptor content rendered inside the row. This should generally contain one or more Ant Design grid columns.

    .PARAMETER Align
    Specifies the vertical alignment of columns within the row.

    .PARAMETER Justify
    Specifies the horizontal alignment and distribution of columns within the row.

    .PARAMETER Gutter
    Specifies spacing between columns. Provide a number, a responsive hashtable such as `@{ xs = 8; md = 24 }`, or a two-item array for horizontal and vertical spacing.

    .PARAMETER Wrap
    Controls whether columns wrap onto additional lines when they exceed the available width.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design row element.

    .PARAMETER Style
    Specifies inline styles applied to the Ant Design row element.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered row. Keys are emitted as data-* attributes.

    .EXAMPLE
    # Basic grid
    New-UDAntDesignRow -Gutter 16 -Content @(
        New-UDAntDesignCol -Span 12 -Content (New-UDAntDesignText -Text 'col-12')
        New-UDAntDesignCol -Span 12 -Content (New-UDAntDesignText -Text 'col-12')
    )

    Creates a simple two-column row using the Ant Design 24-column grid system.

    .EXAMPLE
    # Mixed spans
    New-UDAntDesignRow -Gutter 16 -Content @(
        New-UDAntDesignCol -Span 8 -Content (New-UDAntDesignText -Text 'col-8')
        New-UDAntDesignCol -Span 8 -Content (New-UDAntDesignText -Text 'col-8')
        New-UDAntDesignCol -Span 8 -Content (New-UDAntDesignText -Text 'col-8')
    )

    Splits the row into three equal-width columns.

    .EXAMPLE
    # Responsive gutter
    New-UDAntDesignRow -Gutter @(@{ xs = 8; sm = 16; md = 24 }, 16) -Content @(
        New-UDAntDesignCol -Span 12 -Content (New-UDAntDesignText -Text 'Responsive gutter')
        New-UDAntDesignCol -Span 12 -Content (New-UDAntDesignText -Text 'Horizontal and vertical spacing')
    )

    Uses responsive horizontal gutter values with a fixed vertical gutter.

    .EXAMPLE
    # Justify and align
    New-UDAntDesignRow -Justify space-between -Align middle -Style @{ minHeight = '96px'; border = '1px dashed #d9d9d9'; paddingInline = '12px' } -Content @(
        New-UDAntDesignCol -Span 4 -Content (New-UDAntDesignText -Text 'Left')
        New-UDAntDesignCol -Span 4 -Content (New-UDAntDesignText -Text 'Center')
        New-UDAntDesignCol -Span 4 -Content (New-UDAntDesignText -Text 'Right')
    )

    Demonstrates row-level flex alignment and distribution.

    .EXAMPLE
    # Offset and order
    New-UDAntDesignRow -Gutter 16 -Content @(
        New-UDAntDesignCol -Span 6 -Order 2 -Content (New-UDAntDesignText -Text 'Second in visual order')
        New-UDAntDesignCol -Span 6 -Offset 6 -Order 1 -Content (New-UDAntDesignText -Text 'First with offset')
    )

    Shows how column order and offset can reshape a row layout.

    .EXAMPLE
    # Flex fill
    New-UDAntDesignRow -Gutter 16 -Wrap:$false -Content @(
        New-UDAntDesignCol -Flex '100px' -Content (New-UDAntDesignText -Text '100px')
        New-UDAntDesignCol -Flex auto -Content (New-UDAntDesignText -Text 'Auto width')
        New-UDAntDesignCol -Flex '1 1 240px' -Content (New-UDAntDesignText -Text 'Flexible remainder')
    )

    Uses column flex values instead of span-only sizing.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [ValidateSet('top', 'middle', 'bottom', 'stretch')]
        [string]$Align,
        [ValidateSet('start', 'end', 'center', 'space-around', 'space-between', 'space-evenly')]
        [string]$Justify,
        [object]$Gutter,
        [bool]$Wrap,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    $descriptor = @{
        type = 'antd-row'
        id   = $Id
    }

    foreach ($property in 'Content', 'Align', 'Justify', 'Gutter', 'Wrap', 'ClassName', 'Style') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    $descriptor
}

function New-UDAntDesignCol {
    <#
    .SYNOPSIS
    Creates an Ant Design grid column descriptor.

    .DESCRIPTION
    Creates an antd-col descriptor that maps the PowerShell command surface to the Ant Design Col component used by the client runtime. Use grid columns inside Ant Design rows to size and position dashboard content across the 24-column layout system.

    .NOTES
    Grid columns should be rendered inside Ant Design grid rows.
    Columns support fixed spans, offsets, ordering, flex sizing, and responsive breakpoint-specific settings.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Content
    Specifies the descriptor content rendered inside the column.

    .PARAMETER Span
    Specifies the number of grid columns occupied by this column.

    .PARAMETER Order
    Specifies the display order when the row uses flex layout.

    .PARAMETER Offset
    Specifies how many grid columns to shift this column to the right.

    .PARAMETER Push
    Specifies how many grid columns to push this column to the right.

    .PARAMETER Pull
    Specifies how many grid columns to pull this column to the left.

    .PARAMETER Flex
    Specifies the flex sizing value for the column.

    .PARAMETER Xs
    Specifies the responsive configuration for viewports smaller than 576 pixels.

    .PARAMETER Sm
    Specifies the responsive configuration for viewports at least 576 pixels wide.

    .PARAMETER Md
    Specifies the responsive configuration for viewports at least 768 pixels wide.

    .PARAMETER Lg
    Specifies the responsive configuration for viewports at least 992 pixels wide.

    .PARAMETER Xl
    Specifies the responsive configuration for viewports at least 1200 pixels wide.

    .PARAMETER Xxl
    Specifies the responsive configuration for viewports at least 1600 pixels wide.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design column element.

    .PARAMETER Style
    Specifies inline styles applied to the Ant Design column element.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered column. Keys are emitted as data-* attributes.

    .EXAMPLE
    # Basic column
    New-UDAntDesignCol -Span 6 -Content (New-UDAntDesignText -Text 'col-6')

    Creates a simple 6-span grid column.

    .EXAMPLE
    # Responsive span
    New-UDAntDesignCol -Xs 24 -Md @{ span = 12; offset = 6 } -Content (New-UDAntDesignText -Text 'Responsive column')

    Uses a full-width mobile layout and a centered medium breakpoint layout.

    .EXAMPLE
    # Flexible width
    New-UDAntDesignCol -Flex '1 1 240px' -Content (New-UDAntDesignText -Text 'Flexible column')

    Uses CSS flex sizing instead of a fixed span.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [object]$Span,
        [object]$Order,
        [object]$Offset,
        [object]$Push,
        [object]$Pull,
        [object]$Flex,
        [object]$Xs,
        [object]$Sm,
        [object]$Md,
        [object]$Lg,
        [object]$Xl,
        [object]$Xxl,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    $descriptor = @{
        type = 'antd-col'
        id   = $Id
    }

    foreach ($property in 'Content', 'Span', 'Order', 'Offset', 'Push', 'Pull', 'Flex', 'Xs', 'Sm', 'Md', 'Lg', 'Xl', 'Xxl', 'ClassName', 'Style') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    $descriptor
}