# Microsoft Graph User Scripts

This folder contains scripts that demonstrate how to use the Microsoft Graph to manage users in EntraID.

## Pre-requisites

- [Microsoft Graph PowerShell Module](https://www.powershellgallery.com/packages/Microsoft.Graph)

## Adding a Script

These scripts can be added to PowerShell Universal using the Create Script From Command button on Automation \ Scripts. Select the `Graph.Users.Scripts` module and then the command you would like to add. You can then add it to the [portal](https://docs.powershelluniversal.com/portal/portal) for users to execute.

## Commands 

### `New-PsuMgUser`

This command creates a new user in EntraID using Microsoft Graph.

```powershell
New-PsuMgUser -DisplayName "John Doe" -UserPrincipalName "johndoe@ironmansoftware.com" -AccountEnabled
```