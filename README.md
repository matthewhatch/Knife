#Knife Powerhshell Module

The Knife module is a wrapper around the Chef's Knife, the intention is to
return an object with Get(show) functions

There are only a few commands available, I will be adding them as I need to

##cmdlets
- Invoke-ChefClient
  ```powershell
    $Cred = Get-Credential
    Invoke-ChefClient -ComputerName Server00001 -Credential $Cred
  ```
- Show-ChefNode
```powershell
  Show-ChefNode -Node 'node1' -ChefRepo 'c:\chef-repo'
```
Returns a PSObject:
```
Environment : production
Recipes     : {dsc, new_iis}
IP          : 10.1.254.2
Tags        : {dsc}
RunList     : {role[webserver]}
Roles       : {webserver}
Name        : node1
FQDN        : server0001.somewhere.com
Platform    : windows 6.3.9600
```
