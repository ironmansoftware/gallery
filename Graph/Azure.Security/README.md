# Azure Security

Creates PowerShell Universal roles based on Entra ID groups in Azure. In conjunction with OpenID Connect, the roles will automatically be assigned to users based on their group membership. You can then assign resources to these roles in PowerShell Universal.

## Requirements

- `Microsoft.Graph` module

## Configuration

- `$PSUAzureSecurityTenantId` - The Azure AD tenant ID. Required.
- `$Secret:PSUAzureSecurityCredential` - The Azure AD application client ID (user name) and client secret (password). Required.