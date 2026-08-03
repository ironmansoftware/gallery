function New-AntDesignDemo {
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    @{
        type       = 'antd-docs'
        id         = 'antdesign-docs'
        title      = 'Ant Design Components'
        overview   = 'Component documentation for the PowerShell Universal Ant Design framework. The examples shown in the page are generated from the module command help so the docs and comment-based help stay aligned.'
        components = @(
            Get-AntDesignComponentDocumentation -Key 'button' -Title 'Button' -CommandName 'New-UDAntDesignButton' -SourceUrl 'https://ant.design/components/button/'
            Get-AntDesignComponentDocumentation -Key 'checkbox' -Title 'Checkbox' -CommandName 'New-UDAntDesignCheckbox' -Category 'Data Entry' -SourceUrl 'https://ant.design/components/checkbox'
            Get-AntDesignComponentDocumentation -Key 'grid' -Title 'Grid' -CommandName 'New-UDAntDesignRow' -Category 'Layout' -SourceUrl 'https://ant.design/components/grid/'
            Get-AntDesignComponentDocumentation -Key 'input' -Title 'Input' -CommandName 'New-UDAntDesignInput' -Category 'Data Entry' -SourceUrl 'https://ant.design/components/input'
            Get-AntDesignComponentDocumentation -Key 'layout' -Title 'Layout' -CommandName 'New-UDAntDesignLayout' -Category 'Layout' -SourceUrl 'https://ant.design/components/layout/'
            Get-AntDesignComponentDocumentation -Key 'rate' -Title 'Rate' -CommandName 'New-UDAntDesignRate' -Category 'Data Entry' -SourceUrl 'https://ant.design/components/rate'
            Get-AntDesignComponentDocumentation -Key 'switch' -Title 'Switch' -CommandName 'New-UDAntDesignSwitch' -Category 'Data Entry' -SourceUrl 'https://ant.design/components/switch'
            Get-AntDesignComponentDocumentation -Key 'typography' -Title 'Typography' -CommandName 'New-UDAntDesignTypography' -SourceUrl 'https://ant.design/components/typography'
            Get-AntDesignComponentDocumentation -Key 'message' -Title 'Message' -CommandName 'Show-AntDesignMessage' -Category 'Feedback' -SourceUrl 'https://ant.design/components/message/'
        )
    }
}

function New-AntDesignDemoApp {
    [CmdletBinding()]
    param()

    if (-not (Get-Command -Name 'New-UDApp' -ErrorAction Ignore)) {
        throw 'New-AntDesignDemoApp requires PowerShell Universal and the Universal cmdlets to be loaded.'
    }

    New-UDApp -Title 'Ant Design Components' -Content {
        New-AntDesignDemo
    }
}