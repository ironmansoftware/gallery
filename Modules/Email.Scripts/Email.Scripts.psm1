function Send-PSUEmail {
    <#
    .SYNOPSIS
    Sends emails from PowerShell.
    
    .DESCRIPTION
    This function sends emails from PowerShell. It integrates with triggers. You will need to set the following variables in Platform \ Variables:

    - ToEmail
    - FromEmail
    - EmailServer
    - EmailUser
    - EmailPassword

    This module requires PSHtml
    
    .PARAMETER Job
    The job to send an email for. This is automatically set when the function is called from a trigger.
    
    #>
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Job')]
        $Job
    )

    if ($PSCmdlet.ParameterSetName -eq 'Job') {
        $JobId = $Job.Id
        $Script = $Job.ScriptFullPath
        $Message = "The job $JobId for script $Script failed."
        $Body = "<a href='$ApiUrl/admin/automation/jobs/$JobId'>View Job</a>"
    }
    else {
        # TODO: Support for other trigger types.
    }

    if (-not $ToEmail) {
        throw "ToEmail variable is not set. Please set this in Platform \ Variables."
    }

    if (-not $FromEmail) {
        throw "FromEmail variable is not set. Please set this in Platform \ Variables."
    }

    if (-not $EmailServer) {
        throw "EmailServer variable is not set. Please set this in Platform \ Variables."
    }

    if (-not $EmailUser) {
        throw "EmailUser variable is not set. Please set this in Platform \ Variables."
    }

    if (-not $EmailPassword) {
        throw "EmailPassword variable is not set. Please set this in Platform \ Variables."
    }
    
    Email {
        EmailBody -FontFamily 'Calibri' -Size 15 {
            EmailTextBox {
                $Message
            }
            EmailHtml { 
                $Body
            }
        }
    } -To $ToEmail -From $FromEmail -Server $EmailServer -Subject $Message -Username $EmailUser -Password $EmailPassword
}