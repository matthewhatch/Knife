<#
  .Synopsis
    Starts the chef configuration evaluation

  .Description
    Starts the chef configuration evaluation for the node passed to the
    ComputerName parameter.

  .Parameter ComputerName
    Node to run the client on

  .Parameter Credential
    Credetnial of the user account to be used to invoke the chef client

  .Example
    $Cred = Get-Credential
    Invoke-Client -Computername Server001 -Credential $Cred
#>
Function Invoke-ChefClient {
  param(
    [string]$ComputerName,

    [PSCredential]$Credential
  )

  $username = $Credential.UserName

  if($username -notmatch 'corp'){
    $username = "corp\$username"
  }

  $password = $Credential.GetNetworkCredential().Password
  & knife winrm $ComputerName chef-client --manual-list --winrm-user $username --winrm-password $password

}

<#
  .Synopsis
    Upload Chef cookbook to Server

  .Description
    Upload Chef cookbook to Chef Server

  .Parameter Cookbook
    Name of the cookbook to upload

  .Parameter ChefRepo
    Location of the Chef repo on the local machine, if you're in the repo
    directory, you don't need to enter anything

  .Example
    Copy-Cookbook -Cookbook Cookbook001



#>
Function Copy-Cookbook {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string[]]$Cookbook,

    [string]$ChefRepo
  )

  Write-Verbose 'Caching Current location'
  $Cachelocation = Get-Location
  if($PSBoundParameters.ContainsKey('ChefRepo') -and (-not($Cachelocation.path -eq $ChefRepo))){
    Write-Verbose "Setting location to $ChefRepo"
    Set-Location $ChefRepo
  }

  foreach ($book in $CookBook){
      Write-Verbose "starting the upload of $book"
      & knife cookbook upload $book
      Write-Verbose "upload of $book complete!"
  }

  if($PSBoundParameters.ContainsKey('ChefRepo')-and (-not($Cachelocation.path -eq $ChefRepo))){
    Write-Verbose "Changing location back to $CacheLocation"
    Set-Location $Cachelocation
  }
}
