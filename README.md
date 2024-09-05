# PowerShell Universal Gallery

Public library of modules for PowerShell Universal.

## What is this repository for?

This repository is a collection of modules that you can use directly with PowerShell Universal. These modules provide pre-built solutions for specific platforms like Azure, Windows and Slack.

## Support

These scripts are not supported through the general Ironman Software support agreement for PowerShell Universal. Bugs and feature requests should be made through this repository. 

## Categories

### [Active Directory](/ActiveDirectory)

Contains scripts and widgets that are specific to Active Directory.

### [Apps](/Apps)

Contains full apps that can be run with PowerShell Universal.

### [Diagnostics](/Diagnostics)

Diagnostic tools for PowerShell Universal.

### [Graph](/Graph)

Contains scripts that interact with the Microsoft Graph.

### [Misc](/Misc)

Miscellaneous scripts, such as weather components.

### [Notifications](/Notifications)

Contains scripts that can be used to send notifications like email and chat apps.

### [PowerShell](/PowerShell)

Contains general purpose PowerShell scripts and widgets.

### [System](/System)

Contains scripts and widgets that return information about the system.

### [Universal](/Universal)

Contains scripts that are specific to PowerShell Universal.

### [Windows](/Windows)

Contains scripts that are specific to Windows environments.

## Usage

### PowerShell 

You can use this repository outside of PowerShell Universal by installing the release to your local machine. PowerShell Universal uses PSResourceGet. You will need to install this module.

```powershell
Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
Register-PSRepository -Name 'PSUScriptLibrary' -SourceLocation 'https://gallery.powershelluniversal.com/feed/index.json'
```

### PowerShell Universal v5

This repository is automatically installed with PowerShell Universal v5 and integrated into the admin console. You can access the library by clicking Platform \ Library.

![](/images/library.png)

The library contains a collection of modules that you can use in your environment. You can install these modules directly from the library page.

![](/images/library-page.png)

You can also access the library from various resource pages.

![](/images/library-button.png)

Solutions installed from the library will appear in the Modules page and their resources will automatically be added.

### PowerShell Universal v4

This repository can be installed with PowerShell Universal v4 by registering it as a module repository.

#### Installation

PowerShell Universal uses PSResourceGet. You will need to install this module.

```powershell
Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
```

To install this repository with PowerShell Universal v4, you can use the following command.

```powershell
Register-PSRepository -Name 'PSUScriptLibrary' -SourceLocation 'https://gallery.powershelluniversal.com/feed/index.json'
```

#### Add Resources to PSU

You can add resources found in this library to your PSU instance by visiting the modules page.  Click Platform \ Modules \ Repositories and select the PSUScriptLibrary repository.

![](/images/modules.png)

## Contribution guidelines

If you would like to contribute to this repository, please submit a pull request. We accept any PowerShell script that you would like to share with the community. We recommend structure it so that it can be used with PowerShell Universal.

### Structure

Each script should be in a folder that contains the script and a `psd1` file that contains the metadata for the script. To include resources in PowerShell Universal, you can create a `.universal` folder. These will be automatically exposed in PSU when the module is imported. You can view examples within the repository to see how this is accomplished.

Tags, images and description of your module will appear directly in the platform.

### Tags

The following tags are used to categorize modules in PowerShell Universal

- `script` - Contains a script resource
- `app` - Contains an App
- `widget` - Contains one or more Portal Widgets
- `api` - Contains API endpoints
- `trigger` - Contains triggers

### Documentation

We prefer that you include comment based help. A `readme.md` is also useful to better describe your module or solution. The readme content will be displayed in PowerShell Universal.

### Tests

We currently do not require tests but prefer any tests are written in Pester. We will run these tests during CI builds.

### Building

The repository is automatically build using the `build.ps1` script. It finds all PSD1 files and generates nuget packages for each module. These will be stored in the output folder. They should not be checked in. A .gitignore has been created to prevent this.

