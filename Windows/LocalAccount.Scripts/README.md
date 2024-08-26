# Local Account Scripts

The Local Account Scripts module contains scripts that you can use with PowerShell Universal to manage local accounts on Windows machines.

## Commands

### `New-PSULocalAccount`

This command creates a new local account on a Windows machine.

```powershell
$Password = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
New-PSULocalAccount -Name 'testuser' -Password $Password -ConfirmPassword $Password
```