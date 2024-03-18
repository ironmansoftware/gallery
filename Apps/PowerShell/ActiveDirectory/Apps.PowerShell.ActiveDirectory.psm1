function New-UDActiveDirectoryApp {
    $Navigation = {
        Protect-UDSection -Role @("Administrator", "AD Admin", "AD Users") -Children {
            New-UDListItem -Label 'Users' -Icon (New-UDIcon -Icon 'User') -Children {
                New-UDListItem -Label 'Search Users' -Icon (New-UDIcon -Icon 'Search') -Href '/search-users' -Nested
                New-UDListItem -Label 'Create User' -Icon (New-UDIcon -Icon 'UserPlus') -Href '/create-user' -Nested
                New-UDListItem -Label 'Reset Password' -Icon (New-UDIcon -Icon 'Key') -Href '/reset-password' -Nested
                New-UDListItem -Label 'Restore Deleted User' -Icon (New-UDIcon -Icon 'Trash') -Href '/restore-deleted-user' -Nested
            }
        }
        Protect-UDSection -Role @("Administrator", "AD Admin", "AD Groups") -Children {
            New-UDListItem -Label 'Groups' -Icon (New-UDIcon -Icon 'Users') -Children {
                New-UDListItem -Label 'Search Groups' -Icon (New-UDIcon -Icon 'Search') -Href '/groups' -Nested
                New-UDListItem -Label 'Create Group' -Icon (New-UDIcon -Icon 'UsersCog') -Href '/create-group' -Nested
                New-UDListItem -Label 'Group Membership' -Icon (New-UDIcon -Icon 'Users') -Href '/group-membership' -Nested
            }
        }
        Protect-UDSection -Role @("Administrator", "AD Admin") -Children {
            New-UDListItem -Label 'Infrastructure' -Icon (New-UDIcon -Icon 'Server') -Children {
                New-UDListItem -Label 'Search Computers' -Icon (New-UDIcon -Icon 'Search') -Href '/Search-Computers' -Nested
                New-UDListItem -Label 'Domain Controllers' -Icon (New-UDIcon -Icon 'Database') -Href '/Domain-Controllers' -Nested
            }
        }
        New-UDListItem -Label 'Object Search' -Icon (New-UDIcon -Icon 'Search') -Href '/object-search'
        New-UDListItem -Label 'Reports' -Icon (New-UDIcon -Icon 'UsersGear') -Href '/reports'
    }
      
    function New-ADReportPage {
        param(
            $Title,  
            $Description,
            $Module,
            $Command,
            $Url)

        $Script = "$Module\$Command"
      
        New-UDPage -Name $Title -Url $Url -Content {
            New-UDStack -Direction row -Content {
                New-UDButton -Text 'Back to Reports' -Icon (New-UDIcon -Icon ArrowAltCircleLeft) -OnClick {
                    Invoke-UDRedirect "/reports"
                }
      
                New-UDButton -Text 'Run Report' -OnClick {
                    Show-UDToast "Running report..."
                    Invoke-PSUScript -Integrated -Name $Script | Wait-PSUJob -Integrated
                    Sync-UDElement -Id "$($Title)_Table" 
                    Show-UDToast "Report complete."
                } -Icon (New-UDIcon -Icon 'Play') -ShowLoading 
            }
      
            New-UDAlert -Severity info -Title $Title -Text $Description
      
            New-UDDynamic -Id "$($Title)_Table" -Content {
                $Job = Get-PSUScript -Integrated -Name $Script | Get-PSUJob -Integrated -OrderDirection Descending -OrderBy StartTime -First 1
                if ($Job -eq $null) {
                    Show-UDToast 'Running report...'
                    $Data = Invoke-PSUScript -Integrated -Name $Script -Wait 
                    $JobTime = Get-Date
                }
                else {
                    $Data = $Job | Get-PSUJobPipelineOutput -Integrated
                    $JobTime = $Job.EndTime
                }
      
                New-UDTable -Title $Title -Icon (New-UDIcon -Icon User -Style @{ marginRight = "10px" }) -Data $Data -ShowExport -ShowPagination
                New-UDStack -Direction column -Content {
                    New-UDTypography -Text "Report Created: $JobTime"
                }
            } -LoadingComponent {
                New-UDSkeleton -Height 10
            }
        }
    }
      
    $Reports = @(
        @{
            Title       = "Computers - Disabled"
            Url         = "/reports/computers/disabled"
            Description = "A report of computers that are disabled."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDDisabledComputers"
        }
        @{
            Title       = "Computers - Domain Controllers"
            Url         = "/reports/computers/domain-controllers"
            Description = "A report of domain controllers."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDDomainControllers"
        }
        @{
            Title       = "Computers - Inactive"
            Url         = "/reports/computers/inactive"
            Description = "A report of computers that have been inactive for 30 days or more."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDInactiveComputers"
        }
        @{
            Title       = "Users - Inactive"
            Url         = "/reports/users/inactive"
            Description = "A report of users that have been inactive for 30 days or more."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDInactiveUsers"
        }
        @{
            Title       = "Users - Locked Out"
            Url         = "/reports/users/locked-out"
            Description = "A report of users that are locked out."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDLockedOutUsers"
        }
        @{
            Title       = "Users - Never Logged On"
            Url         = "/reports/users/never-logged-on"
            Description = "A report of users that have never logged on."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDUsersNeverLoggedOn"
        }
        @{
            Title       = "Users - Recently Created"
            Url         = "/reports/users/recently-created"
            Description = "A report of users that have been created in the last 30 days."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDUsersRecentlyCreated"
        }
        @{
            Title       = "Users - Recently Modified"
            Url         = "/reports/users/recently-modified"
            Description = "A report of users that have been modified in the last 30 days."
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDUsersRecentlyModified"
        }
        @{
            Title       = "Users - Without Manager"
            Url         = "/reports/users/without-manager"
            Description = "A report of users that do not have managers"
            Module      = "ActiveDirectory.Scripts"
            Command     = "Get-UDUsersWithoutManager"
        }
    )
      
    New-UDDashboard -Title "Active Directory Tools" -Pages @(
        & "$PSScriptRoot\pages\Create User.ps1"
        & "$PSScriptRoot\pages\Create Group.ps1"
        & "$PSScriptRoot\pages\Domain Controllers.ps1"
        & "$PSScriptRoot\pages\Groups.ps1"
        & "$PSScriptRoot\pages\Group Membership.ps1"
        & "$PSScriptRoot\pages\Object Info.ps1"
        & "$PSScriptRoot\pages\Object Search.ps1"
        & "$PSScriptRoot\pages\Search Computers.ps1"
        & "$PSScriptRoot\pages\Search Users.ps1"
        & "$PSScriptRoot\pages\Reset Password.ps1"
        & "$PSScriptRoot\pages\Restore Deleted User.ps1"
        New-UDPage -Name 'Reports' -Content {
            New-UDTypography -Text 'Reports' -Variant h4
            New-UDHtml -Markup '<hr/>'
            New-UDLayout -Columns 3 -Content {
                $Reports | ForEach-Object {
                    $Job = Get-PSUScript -Integrated -Name "$($_.Module)\$($_.Command)" | Get-PSUJob -Integrated -OrderDirection Descending -OrderBy StartTime -First 1
                    $LastRun = "Never"
                    $Objects = "Unknown"
                    if ($Job) {
                        $LastRun = $Job.EndTime
                        $Objects = ($Job | Get-PSUJobPipelineOutput -Integrated | Measure-Object).Count
                    }
                    New-UDElement -Content {
                        New-UDCard -Title $_.Title -Content {
                            New-UDStack -Direction column -Content {
                                New-UDTypography -Text $_.Description -Style @{ fontWeight = 'bold'; marginBottom = '5px' }
                                New-UDTypography -Text "Last Run: $LastRun"
                                New-UDTypography -Text "Object Count: $Objects"
                            }
      
                        }
                    } -Tag 'div' -Attributes @{
                        onClick = {
                            Invoke-UDRedirect $_.Url
                        }
                        style   = @{
                            cursor = 'pointer'
                        }
                    }
                }
            }
      
        }
        $Reports | ForEach-Object {
            New-ADReportPage @_
        }
    ) -NavigationLayout Permanent -LoadNavigation $Navigation
}