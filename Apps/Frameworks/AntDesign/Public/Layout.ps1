function New-AntDesignLayoutDescriptor {
    param(
        [Parameter(Mandatory)]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$Id,
        [object]$Content,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes,
        [hashtable]$AdditionalProperties = @{}
    )

    $descriptor = @{
        type = $Type
        id   = $Id
    }

    if ($PSBoundParameters.ContainsKey('Content')) {
        $descriptor.content = $Content
    }

    if ($PSBoundParameters.ContainsKey('ClassName')) {
        $descriptor.className = $ClassName
    }

    if ($PSBoundParameters.ContainsKey('Style')) {
        $descriptor.style = $Style
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    foreach ($key in $AdditionalProperties.Keys) {
        $descriptor[$key] = $AdditionalProperties[$key]
    }

    $descriptor
}

function New-UDAntDesignLayout {
    <#
    .SYNOPSIS
    Creates an Ant Design layout descriptor.

    .DESCRIPTION
    Creates an antd-layout descriptor that maps the PowerShell command surface to the Ant Design Layout component used by the client runtime. Use the layout wrapper to compose page chrome with Header, Sider, Content, and Footer regions while keeping the descriptor contract aligned with the upstream Ant Design layout model.

    .NOTES
    Layout is the outer container for page structure and can contain nested layouts when a page needs both top and side navigation.
    Use Header for top navigation or branding, Sider for navigation rails, Content for the main work area, and Footer for supporting information.
    Set HasSider when you want to make the presence of a nested sider explicit, which can help avoid SSR layout flicker.
    Sider supports collapsible and responsive behavior through the Ant Design built-in props exposed by the PowerShell wrapper.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Content
    Specifies the descriptor content rendered inside the layout. This can contain Header, Sider, Content, Footer, or nested Layout descriptors.

    .PARAMETER HasSider
    Indicates that the layout contains a sider.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design layout element.

    .PARAMETER Style
    Specifies inline styles applied to the rendered layout element.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered layout. Keys are emitted as data-* attributes.

    .EXAMPLE
    # Basic structure
    New-UDAntDesignLayout -Style @{ minHeight = '280px'; border = '1px solid #f0f0f0'; borderRadius = '8px'; overflow = 'hidden' } -Content @(
        New-UDAntDesignLayoutHeader -Style @{ background = '#1677ff'; color = '#fff'; padding = '0 24px'; display = 'flex'; alignItems = 'center' } -Content 'Header'
        New-UDAntDesignLayoutContent -Style @{ background = '#fff'; padding = '24px' } -Content 'Content'
        New-UDAntDesignLayoutFooter -Style @{ textAlign = 'center' } -Content 'Footer'
    )

    Creates the classic header-content-footer page structure.

    .EXAMPLE
    # Header and sider
    New-UDAntDesignLayout -Style @{ minHeight = '320px'; border = '1px solid #f0f0f0'; borderRadius = '8px'; overflow = 'hidden' } -Content @(
        New-UDAntDesignLayoutHeader -Style @{ background = '#001529'; color = '#fff'; padding = '0 24px'; display = 'flex'; alignItems = 'center' } -Content 'Header'
        New-UDAntDesignLayout -HasSider $true -Content @(
            New-UDAntDesignLayoutSider -Width 200 -Style @{ background = '#001529'; color = '#fff'; padding = '24px 16px' } -Content 'Sider'
            New-UDAntDesignLayoutContent -Style @{ background = '#fff'; padding = '24px' } -Content 'Content'
        )
    )

    Nests a layout inside the root so a top header and left navigation rail can be combined.

    .EXAMPLE
    # Sider content footer
    New-UDAntDesignLayout -HasSider $true -Style @{ minHeight = '320px'; border = '1px solid #f0f0f0'; borderRadius = '8px'; overflow = 'hidden' } -Content @(
        New-UDAntDesignLayoutSider -Width '220px' -Theme light -Style @{ padding = '24px 16px'; borderInlineEnd = '1px solid #f0f0f0' } -Content 'Navigation'
        New-UDAntDesignLayout -Content @(
            New-UDAntDesignLayoutContent -Style @{ background = '#fff'; padding = '24px' } -Content 'Work area'
            New-UDAntDesignLayoutFooter -Style @{ textAlign = 'center'; background = '#fafafa' } -Content 'Footer'
        )
    )

    Uses a fixed navigation sider with a nested content-and-footer layout.

    .EXAMPLE
    # Collapsible sider
    New-UDAntDesignLayout -HasSider $true -Style @{ minHeight = '320px'; border = '1px solid #f0f0f0'; borderRadius = '8px'; overflow = 'hidden' } -Content @(
        New-UDAntDesignLayoutSider -Collapsible $true -DefaultCollapsed $true -CollapsedWidth 80 -Width 220 -Style @{ paddingTop = '24px' } -Content 'Collapsible sider'
        New-UDAntDesignLayoutContent -Style @{ background = '#fff'; padding = '24px' } -Content 'Content with collapsible navigation'
    )

    Enables the Ant Design built-in collapsible sider behavior without adding custom event handling.

    .EXAMPLE
    # Responsive sider
    New-UDAntDesignLayout -HasSider $true -Style @{ minHeight = '320px'; border = '1px solid #f0f0f0'; borderRadius = '8px'; overflow = 'hidden' } -Content @(
        New-UDAntDesignLayoutSider -Breakpoint lg -CollapsedWidth 0 -Width 220 -Style @{ paddingTop = '24px' } -Content 'Responsive sider'
        New-UDAntDesignLayoutContent -Style @{ background = '#fff'; padding = '24px' } -Content 'Resize the page to let the sider collapse at the large breakpoint.'
    )

    Shows the responsive breakpoint support exposed by the sider wrapper.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [bool]$HasSider,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    $additionalProperties = @{}

    if ($PSBoundParameters.ContainsKey('HasSider')) {
        $additionalProperties.hasSider = $HasSider
    }

    New-AntDesignLayoutDescriptor -Type 'antd-layout' -Id $Id -Content $Content -ClassName $ClassName -Style $Style -DataAttributes $DataAttributes -AdditionalProperties $additionalProperties
}

function New-UDAntDesignLayoutHeader {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    New-AntDesignLayoutDescriptor -Type 'antd-layout-header' -Id $Id -Content $Content -ClassName $ClassName -Style $Style -DataAttributes $DataAttributes
}

function New-UDAntDesignLayoutContent {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    New-AntDesignLayoutDescriptor -Type 'antd-layout-content' -Id $Id -Content $Content -ClassName $ClassName -Style $Style -DataAttributes $DataAttributes
}

function New-UDAntDesignLayoutFooter {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    New-AntDesignLayoutDescriptor -Type 'antd-layout-footer' -Id $Id -Content $Content -ClassName $ClassName -Style $Style -DataAttributes $DataAttributes
}

function New-UDAntDesignLayoutSider {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [object]$Content,
        [ValidateSet('xs', 'sm', 'md', 'lg', 'xl', 'xxl', 'xxxl')]
        [string]$Breakpoint,
        [bool]$Collapsed,
        [object]$CollapsedWidth,
        [bool]$Collapsible,
        [bool]$DefaultCollapsed,
        [bool]$ReverseArrow,
        [ValidateSet('light', 'dark')]
        [string]$Theme,
        [AllowNull()]
        [object]$Trigger,
        [object]$Width,
        [hashtable]$ZeroWidthTriggerStyle,
        [string]$ClassName,
        [hashtable]$Style,
        [hashtable]$DataAttributes
    )

    $additionalProperties = @{}

    foreach ($property in 'Breakpoint', 'Collapsed', 'CollapsedWidth', 'Collapsible', 'DefaultCollapsed', 'ReverseArrow', 'Theme', 'Trigger', 'Width', 'ZeroWidthTriggerStyle') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $additionalProperties[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    New-AntDesignLayoutDescriptor -Type 'antd-layout-sider' -Id $Id -Content $Content -ClassName $ClassName -Style $Style -DataAttributes $DataAttributes -AdditionalProperties $additionalProperties
}