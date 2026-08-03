function New-UDAntDesignInput {
    <#
    .SYNOPSIS
    Creates an Ant Design input descriptor.

    .DESCRIPTION
    Creates an antd-input descriptor that maps the PowerShell command surface to the Ant Design Input family used by the client runtime. The command wraps Input, Input.TextArea, Input.Search, Input.Password, and Input.OTP behind a single descriptor model so the documented PowerShell examples can follow the same examples shown in the upstream Ant Design Input documentation while still supporting PowerShell Universal endpoint callbacks.

    .NOTES
    A user input in a form field is needed.
    A search input is required.

    .PARAMETER Id
    Specifies the component identifier used by PowerShell Universal for state and event routing.

    .PARAMETER Mode
    Specifies which Ant Design Input primitive to render. Valid values are input, textarea, search, password, and otp.

    .PARAMETER Placeholder
    Specifies the placeholder text rendered by the input.

    .PARAMETER Value
    Specifies the controlled value rendered by the input.

    .PARAMETER DefaultValue
    Specifies the initial value rendered by the input.

    .PARAMETER Disabled
    Disables the input.

    .PARAMETER AllowClear
    Displays the Ant Design clear affordance when the input mode supports it.

    .PARAMETER AutoFocus
    Automatically focuses the input when it is rendered.

    .PARAMETER AutoComplete
    Specifies the browser autocomplete behavior.

    .PARAMETER Type
    Specifies the native input type used by the base input control.

    .PARAMETER Size
    Specifies the Ant Design input size. Valid values are large, middle, and small.

    .PARAMETER Variant
    Specifies the Ant Design input variant. Valid values are outlined, filled, borderless, and underlined.

    .PARAMETER Status
    Specifies the validation status. Valid values are error and warning.

    .PARAMETER Prefix
    Specifies content rendered before the input value. Provide plain text, descriptor content, or an Ant Design icon name.

    .PARAMETER Suffix
    Specifies content rendered after the input value. Provide plain text, descriptor content, or an Ant Design icon name.

    .PARAMETER AddonBefore
    Specifies content rendered before the outer input wrapper.

    .PARAMETER AddonAfter
    Specifies content rendered after the outer input wrapper.

    .PARAMETER EnterButton
    Specifies the Ant Design search enter button. Provide `$true`, plain text, or descriptor content.

    .PARAMETER Loading
    Shows the Ant Design loading state for search input mode.

    .PARAMETER Rows
    Specifies the visible row count for textarea mode.

    .PARAMETER AutoSize
    Enables Ant Design textarea auto-sizing. Provide `$true` or a hashtable with `minRows` and `maxRows`.

    .PARAMETER MaxLength
    Specifies the maximum character length.

    .PARAMETER ShowCount
    Displays the Ant Design character count affordance.

    .PARAMETER Count
    Specifies count configuration for Input. Supported keys are `show`, `max`, `strategy`, and `exceedFormatter`. Use `strategy = 'graphemes'` and `exceedFormatter = 'truncate-graphemes'` to mirror the documented emoji counting examples.

    .PARAMETER OtpLength
    Specifies the number of OTP input slots rendered in otp mode.

    .PARAMETER OtpMask
    Specifies the OTP mask. Provide `$true` or a single display character.

    .PARAMETER OtpFormatter
    Specifies a built-in OTP formatter. Valid values are uppercase.

    .PARAMETER OtpSeparator
    Specifies the separator rendered between OTP fields. Provide plain text, descriptor content, or a hashtable like `@{ type = 'alternating-dash'; evenColor = 'red'; oddColor = 'blue' }`.

    .PARAMETER PasswordVisible
    Specifies the controlled visibility state used by password mode.

    .PARAMETER VisibilityToggle
    Specifies whether the password visibility toggle is shown.

    .PARAMETER Name
    Specifies the name attribute rendered by the input.

    .PARAMETER ClassName
    Specifies a class name applied to the Ant Design input element or wrapper.

    .PARAMETER ClassNames
    Specifies semantic DOM class mappings passed to the Ant Design input `classNames` prop when the rendered mode supports it.

    .PARAMETER Style
    Specifies inline styles applied to the rendered Ant Design input element or wrapper.

    .PARAMETER Styles
    Specifies semantic DOM inline style mappings passed to the Ant Design input `styles` prop when the rendered mode supports it.

    .PARAMETER DataAttributes
    Specifies custom data attributes added to the rendered input. Keys are emitted as data-* attributes.

    .PARAMETER OnChange
    Specifies the endpoint invoked when the input value changes.

    .PARAMETER OnPressEnter
    Specifies the endpoint invoked when Enter is pressed inside the input.

    .PARAMETER OnSearch
    Specifies the endpoint invoked when search input mode triggers a search.

    .PARAMETER OnClear
    Specifies the endpoint invoked when the clear affordance is used.

    .PARAMETER OnInput
    Specifies the endpoint invoked when otp mode emits its input array payload.

    .EXAMPLE
    # Basic usage
    New-UDAntDesignInput -Placeholder 'Basic usage'

    Basic usage example.

    .EXAMPLE
    # Three sizes of Input
    @(
        New-UDAntDesignInput -Size large -Placeholder 'large size' -Prefix 'UserOutlined'
        New-UDAntDesignInput -Placeholder 'default size' -Prefix 'UserOutlined'
        New-UDAntDesignInput -Size small -Placeholder 'small size' -Prefix 'UserOutlined'
    )

    There are three sizes of an Input box: `large` (40px), `medium` (32px) and `small` (24px).

    .EXAMPLE
    # Variants
    @(
        New-UDAntDesignInput -Placeholder 'Outlined'
        New-UDAntDesignInput -Placeholder 'Filled' -Variant filled
        New-UDAntDesignInput -Placeholder 'Borderless' -Variant borderless
        New-UDAntDesignInput -Placeholder 'Underlined' -Variant underlined
        New-UDAntDesignInput -Mode search -Placeholder 'Filled search' -Variant filled
    )

    Variants of Input, there are four variants: `outlined` `filled` `borderless` and `underlined`.

    .EXAMPLE
    # Compact Style
    @(
        New-UDAntDesignInput -DefaultValue '26888888'
        New-UDAntDesignInput -DefaultValue '0571' -Style @{ width = '20%' }
        New-UDAntDesignInput -DefaultValue '26888888' -Style @{ width = '80%' }
        New-UDAntDesignInput -Mode search -AddonBefore 'https://' -Placeholder 'input search text' -AllowClear
        New-UDAntDesignInput -DefaultValue 'Combine input and button' -AddonAfter (New-UDAntDesignButton -Text 'Submit' -ButtonType primary)
        New-UDAntDesignInput -AddonBefore 'Zhejiang' -DefaultValue 'Xihu District, Hangzhou'
    )

    Uses add-ons, search affordances, and paired values to reproduce the compact input arrangements shown in the Ant Design docs.

    .EXAMPLE
    # Search box
    @(
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -Style @{ width = 200 }
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -AllowClear -Style @{ width = 200 }
        New-UDAntDesignInput -Mode search -AddonBefore 'https://' -Placeholder 'input search text' -AllowClear
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -EnterButton $true
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -AllowClear -EnterButton 'Search' -Size large
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -EnterButton 'Search' -Size large -Suffix 'AudioOutlined'
    )

    Example of creating a search box by grouping a standard input with a search button.

    .EXAMPLE
    # Search box with loading
    @(
        New-UDAntDesignInput -Mode search -Placeholder 'input search loading default' -Loading
        New-UDAntDesignInput -Mode search -Placeholder 'input search loading with enterButton' -Loading -EnterButton $true
        New-UDAntDesignInput -Mode search -Placeholder 'input search text' -EnterButton 'Search' -Size large -Loading
    )

    Search loading when onSearch.

    .EXAMPLE
    # TextArea
    @(
        New-UDAntDesignInput -Mode textarea -Rows 4
        New-UDAntDesignInput -Mode textarea -Rows 4 -Placeholder 'maxLength is 6' -MaxLength 6
    )

    For multi-line input.

    .EXAMPLE
    # Autosizing the height to fit the content
    @(
        New-UDAntDesignInput -Mode textarea -Placeholder 'Autosize height based on content lines' -AutoSize $true
        New-UDAntDesignInput -Mode textarea -Placeholder 'Autosize height with minimum and maximum number of lines' -AutoSize @{ minRows = 2; maxRows = 6 }
        New-UDAntDesignInput -Mode textarea -Value 'Controlled autosize' -Placeholder 'Controlled autosize' -AutoSize @{ minRows = 3; maxRows = 5 }
    )

    `autoSize` for a textarea input automatically adjusts height based on the content. You can also supply `minRows` and `maxRows`.

    .EXAMPLE
    # OTP
    @(
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With formatter (Upcase)'
        New-UDAntDesignInput -Mode otp -OtpFormatter uppercase
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With Disabled'
        New-UDAntDesignInput -Mode otp -Disabled
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With Length (8)'
        New-UDAntDesignInput -Mode otp -OtpLength 8
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With variant'
        New-UDAntDesignInput -Mode otp -Variant filled
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With custom display character'
        New-UDAntDesignInput -Mode otp -OtpMask '🔒'
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With custom ReactNode separator'
        New-UDAntDesignInput -Mode otp -OtpSeparator '/'
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'With custom function separator'
        New-UDAntDesignInput -Mode otp -OtpSeparator @{ type = 'alternating-dash'; evenColor = 'red'; oddColor = 'blue' }
    )

    One time password input.

    .EXAMPLE
    # Format Tooltip Input
    New-UDAntDesignInput -Placeholder 'Input a number' -MaxLength 16 -Style @{ width = 120 } -Suffix 'InfoCircleOutlined'

    You can use Input alongside contextual hints to create a numeric input pattern that keeps extra-long values readable.

    .EXAMPLE
    # prefix and suffix
    @(
        New-UDAntDesignInput -Placeholder 'Enter your username' -Prefix 'UserOutlined' -Suffix 'InfoCircleOutlined'
        New-UDAntDesignInput -Prefix '￥' -Suffix 'RMB'
        New-UDAntDesignInput -Prefix '￥' -Suffix 'RMB' -Disabled
        New-UDAntDesignInput -Mode password -Suffix 'LockOutlined' -Placeholder 'input password support suffix'
    )

    Add a prefix or suffix icon or label inside the input.

    .EXAMPLE
    # Password box
    @(
        New-UDAntDesignInput -Mode password -Placeholder 'input password'
        New-UDAntDesignInput -Mode password -Placeholder 'input password' -PasswordVisible $true
        New-UDAntDesignInput -Mode password -Placeholder 'disabled input password' -Disabled
    )

    Input type of password.

    .EXAMPLE
    # With clear icon
    @(
        New-UDAntDesignInput -Placeholder 'input with clear icon' -AllowClear
        New-UDAntDesignInput -Mode textarea -Placeholder 'textarea with clear icon' -AllowClear
    )

    Input box with the remove icon, click the icon to delete everything.

    .EXAMPLE
    # With character counting
    @(
        New-UDAntDesignInput -ShowCount -MaxLength 20
        New-UDAntDesignInput -Mode textarea -ShowCount -MaxLength 100 -Placeholder 'can resize'
        New-UDAntDesignInput -Mode textarea -ShowCount -MaxLength 100 -Placeholder 'disable resize' -Style @{ height = 120; resize = 'none' }
    )

    Show character counting.

    .EXAMPLE
    # Custom count logic
    @(
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'Exceed Max'
        New-UDAntDesignInput -Count @{ show = $true; max = 10 } -DefaultValue 'Hello, antd!'
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'Emoji count as length 1'
        New-UDAntDesignInput -Count @{ show = $true; strategy = 'graphemes' } -DefaultValue '🔥🔥🔥'
        New-UDAntDesignTypography -Kind title -Level 5 -Text 'Not exceed max'
        New-UDAntDesignInput -Count @{ show = $true; max = 6; strategy = 'graphemes'; exceedFormatter = 'truncate-graphemes' } -DefaultValue '🔥 antd'
    )

    Customize the counting strategy in scenarios such as emoji-aware length counting by using the `count` configuration.

    .EXAMPLE
    # Status
    @(
        New-UDAntDesignInput -Status error -Placeholder 'Error'
        New-UDAntDesignInput -Status warning -Placeholder 'Warning'
        New-UDAntDesignInput -Status error -Prefix 'ClockCircleOutlined' -Placeholder 'Error with prefix'
        New-UDAntDesignInput -Status warning -Prefix 'ClockCircleOutlined' -Placeholder 'Warning with prefix'
    )

    Add status to Input with `status`, which could be `error` or `warning`.

    .EXAMPLE
    # Focus
    @(
        New-UDAntDesignTypography -Kind paragraph -Text 'Input focus methods are available on the underlying Ant Design controls.'
        New-UDAntDesignInput -DefaultValue 'Ant Design love you!' -AutoFocus
        New-UDAntDesignInput -Mode textarea -DefaultValue 'Ant Design love you!'
    )

    Focus with additional option.

    .EXAMPLE
    # Custom semantic dom styling
    @(
        New-UDAntDesignInput -ClassNames @{ root = 'input-example-root' } -Styles @{ root = @{ borderColor = '#696FC7' } } -Placeholder 'Object'
        New-UDAntDesignInput -Placeholder 'Function-inspired styling' -Styles @{ root = @{ borderColor = '#696FC7' } } -Size middle
        New-UDAntDesignInput -Mode textarea -Value 'TextArea' -ShowCount -Styles @{ root = @{ borderColor = '#BDE3C3' }; textarea = @{ resize = 'none' }; count = @{ color = '#BDE3C3' } }
        New-UDAntDesignInput -Mode password -Value 'Password' -Styles @{ root = @{ borderColor = '#F5D3C4' } } -Size middle
        New-UDAntDesignInput -Mode otp -OtpLength 6 -OtpSeparator '*'
        New-UDAntDesignInput -Mode search -Placeholder 'Search' -Size large -Styles @{ root = @{ color = '#4DA8DA' }; input = @{ color = '#4DA8DA'; borderColor = '#4DA8DA' }; prefix = @{ color = '#4DA8DA' }; suffix = @{ color = '#4DA8DA' }; count = @{ color = '#4DA8DA' } }
    )

    You can customize the semantic DOM styling of Input by passing objects through `classNames` and `styles`.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$Id = ([guid]::NewGuid().ToString()),
        [ValidateSet('input', 'textarea', 'search', 'password', 'otp')]
        [string]$Mode = 'input',
        [string]$Placeholder,
        [string]$Value,
        [string]$DefaultValue,
        [switch]$Disabled,
        [switch]$AllowClear,
        [switch]$AutoFocus,
        [string]$AutoComplete,
        [string]$Type,
        [ValidateSet('large', 'middle', 'small')]
        [string]$Size,
        [ValidateSet('outlined', 'filled', 'borderless', 'underlined')]
        [string]$Variant,
        [ValidateSet('error', 'warning')]
        [string]$Status,
        [object]$Prefix,
        [object]$Suffix,
        [object]$AddonBefore,
        [object]$AddonAfter,
        [object]$EnterButton,
        [switch]$Loading,
        [int]$Rows,
        [object]$AutoSize,
        [int]$MaxLength,
        [switch]$ShowCount,
        [hashtable]$Count,
        [int]$OtpLength,
        [object]$OtpMask,
        [ValidateSet('uppercase')]
        [string]$OtpFormatter,
        [object]$OtpSeparator,
        [bool]$PasswordVisible,
        [object]$VisibilityToggle,
        [string]$Name,
        [string]$ClassName,
        [hashtable]$ClassNames,
        [hashtable]$Style,
        [hashtable]$Styles,
        [hashtable]$DataAttributes,
        [Endpoint]$OnChange,
        [Endpoint]$OnPressEnter,
        [Endpoint]$OnSearch,
        [Endpoint]$OnClear,
        [Endpoint]$OnInput
    )

    foreach ($endpoint in @($OnChange, $OnPressEnter, $OnSearch, $OnClear, $OnInput)) {
        if ($null -ne $endpoint -and $endpoint.PSObject.Methods.Name -contains 'Register') {
            $endpoint.Register($Id, $PSCmdlet)
        }
    }

    $descriptor = @{
        type = 'antd-input'
        id   = $Id
    }

    foreach ($property in 'Mode', 'Placeholder', 'Value', 'DefaultValue', 'AutoComplete', 'Type', 'Size', 'Variant', 'Status', 'Prefix', 'Suffix', 'AddonBefore', 'AddonAfter', 'EnterButton', 'Rows', 'AutoSize', 'MaxLength', 'Count', 'OtpLength', 'OtpMask', 'OtpFormatter', 'OtpSeparator', 'PasswordVisible', 'VisibilityToggle', 'Name', 'ClassName', 'ClassNames', 'Style', 'Styles') {
        if ($PSBoundParameters.ContainsKey($property)) {
            $descriptor[$property.Substring(0, 1).ToLowerInvariant() + $property.Substring(1)] = $PSBoundParameters[$property]
        }
    }

    foreach ($switchProperty in 'Disabled', 'AllowClear', 'AutoFocus', 'Loading', 'ShowCount') {
        if ($PSBoundParameters.ContainsKey($switchProperty)) {
            $descriptor[$switchProperty.Substring(0, 1).ToLowerInvariant() + $switchProperty.Substring(1)] = [bool]$PSBoundParameters[$switchProperty]
        }
    }

    if ($PSBoundParameters.ContainsKey('DataAttributes')) {
        $descriptor.dataAttributes = $DataAttributes
    }

    foreach ($eventName in 'OnChange', 'OnPressEnter', 'OnSearch', 'OnClear', 'OnInput') {
        if ($PSBoundParameters.ContainsKey($eventName)) {
            $descriptor[$eventName.Substring(0, 1).ToLowerInvariant() + $eventName.Substring(1)] = $PSBoundParameters[$eventName]
        }
    }

    $descriptor
}