# Slack Scripts

## Usage with Triggers

You can use the `Send-PSUSlackNotification` function to send a message to a Slack channel. It automatically processes trigger data to send formatted messages.

```powershell
New-PSUTrigger -TriggerScript 'Slack.Scripts\Send-PSUSlackNotification' -EventType JobFailed
```

