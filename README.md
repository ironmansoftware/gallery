# Ironman Software Script Library

Public library of scripts maintained by Ironman Software. 

## What is this repository for?

This repository is a collection of scripts that are maintained by Ironman Software. This repository can be used directly with PowerShell Universal version 4 and 5. 

## Usage

### PowerShell Universal v5

This repository is automatically installed with PowerShell Universal v5 and integrated into the admin console. 

**PowerShell Universal v5 is still in development and more information will be forthcoming.**

### PowerShell Universal v4

This repository can be installed with PowerShell Universal v4 by registering it as a module repository. 

#### Installation

PowerShell Universal uses PowerShellGet v3. You will need to install this module. 

```powershell
Install-Module -Name PowerShellGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
```

To install this repository with PowerShell Universal v4, you can use the following command. 

```powershell
Invoke-WebRequest -Uri '<zipurlhere>' -OutFile 'C:\downloads\modules.zip'
Expand-Archive -Path 'C:\repos\scripts\modules.zip' -DestinationPath 'C:\repos\scripts\modules'
Register-PSRepository -Name 'PSUScriptLibrary' -SourceLocation 'C:\repos\scripts\modules'
```

#### Add Resources to PSU

You can add resources found in this library to your PSU instance by visiting the modules page.  Click Platform \ Modules \ Repositories and select the PSUScriptLibrary repository.

![](/images/modules.png)

## Contribution guidelines

If you would like to contribute to this repository, please submit a pull request. We accept any PowerShell script that you would like to share with the community. We recommend structure it so that it can be used with PowerShell Universal. 

### Structure 

Each script should be in a folder that contains the script and a `psd1` file that contains the metadata for the script. To include resources in PowerShell Universal, you can create a `.universal` folder. These will be automatically exposed in PSU when the module is imported. You can view examples within the repository to see how this is accomplished. 

Tags, images and description of your module will appear directly in the platform. 

### Documentation

We prefer that you include comment based help. A `readme.md` is also useful to better describe your module or solution. The readme content will be displayed in PowerShell Universal.

### Tests

We currently do not require tests but prefer any tests are written in Pester. We will run these tests during CI builds. 

### Building

The repository is automatically build using the `build.ps1` script. It finds all PSD1 files and generates nuget packages for each module. These will be stored in the output folder. They should not be checked in. A .gitignore has been created to prevent this.