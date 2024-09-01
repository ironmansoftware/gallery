# Email Scripts

This module contains functions for sending emails from PowerShell Universal. 

## Requirements

- [Mailozaurr](https://www.powershellgallery.com/packages/Mailozaurr)

## Variables 

- `$PSUTriggerEmailFromName` - The name that the email will be sent from.
- `$PSUTriggerEmailFromEmail` - The email address that the email will be sent from.
- `$PSUTriggerEmailToEmail` - The email address that the email will be sent to.
- `$PSUTriggerEmailServer` - The SMTP server that will be used to send the email. Required for SMTP.
- `$Secret:PSUTriggerEmailCredential` - The credential that will be used to send the email via SMTP. Needs to be a secret.
- `$Secret:PSUTriggerEmailGraphClientId` - The client ID for the Azure AD application that will be used to send the email via Microsoft Graph. Needs to be a secret. Required for Graph.
- `$Secret:PSUTriggerEmailGraphClientSecret` - The client secret for the Azure AD application that will be used to send the email via Microsoft Graph. Needs to be a secret. Required for Graph.
- `$Secret:PSUTriggerEmailGraphDirectoryId` - The directory ID for the Azure AD application that will be used to send the email via Microsoft Graph. Needs to be a secret. Required for Graph.

## Functions 

### `Send-PSUTriggerEmail`

Configures and sends emails for triggers. 

```powershell
New-PSUTrigger  -TriggerScript 'Email.Scripts\Send-PSUTriggerEmail' -Type 'JobFailed'
```

![Job failed](https://raw.githubusercontent.com/ironmansoftware/scripts/main/images/Notifications/FailedJob.png)