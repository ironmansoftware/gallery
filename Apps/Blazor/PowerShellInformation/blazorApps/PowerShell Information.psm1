$Variables["Drives"] = Get-PSDrive 
$Variables["Modules"] = Get-Module -ListAvailable 
$Variables["Repositories"] = Get-PSResourceRepository 
$Variables["Providers"] = Get-PSProvider
$Variables["Variables"] = Get-Variable 
$Variables["EnvVariables"] = Dir Env:\ 
$Variables["HostProcesses"] = Get-PSHostProcessInfo