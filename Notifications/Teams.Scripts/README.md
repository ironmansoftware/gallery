# Microsoft Teams Scripts

## Usage with Triggers

You can use the `Send-PSUTeamsNotification` function to send a message to a Microsoft Teams channel. It automatically processes trigger data to send formatted messages.

```powershell
New-PSUTrigger -TriggerScript 'Teams.Scripts\Send-PSUTeamsNotification' -EventType JobFailed
```
