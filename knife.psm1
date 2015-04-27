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
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [string]$ComputerName,

    [PSCredential]$Credential,

    [string]$ChefRepo
  )

  $username = $Credential.UserName

  if($username -notmatch '\\'){
    Write-Verbose 'Updating username with Domain'
    $username = "$env:USERDOMAIN\$username"
    Write-Verbose "Username updated to $username"
  }

  $password = $Credential.GetNetworkCredential().Password
  if($PSCmdlet.ShouldProcess("$Computername with user $username")){
    Write-Verbose "checking configuration on $ComputerName"
    try{
      #$CacheLocation = Get-Location

      if($PSBoundParameters.ContainsKey('ChefRepo')){
        Push-Location $ChefRepo
      }

      & knife winrm $ComputerName chef-client --manual-list --winrm-user $username --winrm-password $password

      if($PSBoundParameters.ContainsKey('ChefRepo')){
        #Set-Location $CacheLocation
        Pop-Location
      }

    }
    catch{
        Write-Warning "There was an issue running chef-client on $ComputerName"
    }
  }
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
  [CmdletBinding(SupportsShouldProcess=$true)]
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
      if($PSCmdlet.ShouldProcess("$book")){
        & knife cookbook upload $book
        Write-Verbose "upload of $book complete!"
      }
  }

  if($PSBoundParameters.ContainsKey('ChefRepo')-and (-not($Cachelocation.path -eq $ChefRepo))){
    Write-Verbose "Changing location back to $CacheLocation"
    Set-Location $Cachelocation
  }
}

<#
  .Synopsis
    Show the configuration and status of a node

  .Description
    Returns a PSObject with Name, Environment, FQDN, IP, RunList, Roles, Recipes,
    Platform, Tags properties

  .Parameter Node
    Chef Node

  .Parameter ChefRepo
    Location of the chef repo, if you are running from the chef repo, you can
    omit this parameter

  .Example
    Show-ChefNode -Node Node1 -ChefRepo c:\Chef-repo

  .Example
    Show-ChefNode -Node Node1

  .Example
    Show-ChefNode -Node Node1,Node2,Node3
#>
Function Get-ChefNode {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string[]]
    $Node,

    [string]
    $ChefRepo
  )
  $CacheLocation = Get-Location
  if($PSBoundParameters.ContainsKey('ChefRepo')){
    Set-Location $ChefRepo
  }

  foreach ($item in $Node){
    try{
      $results = _knifenodeshow -Node $item #& knife node show $item
      $properties = @{
        Name = $results[0].Replace('Node Name:','').Trim()
        Environment = $results[1].Replace('Environment:','').Trim()
        FQDN = $results[2].Replace('FQDN:','').Trim()
        IP = $results[3].Replace('IP:','').Trim()
        RunList = $results[4].Replace('Run List:','').Trim().Split(',')
        Roles = $results[5].Replace('Roles:','').Trim().Split(',')
        Recipes = $results[6].Replace('Recipes:','').Trim().Split(',') | ForEach-Object {($_).Trim()} #removing leading space for each item
        Platform = $results[7].Replace('Platform:','').Trim()
        Tags = $results[8].Replace('Tags:','').Trim().Split(',')
      }
    }
    catch{
      if($PSBoundParameters.ContainsKey('ChefRepo')){
        Set-Location $CacheLocation
      }
      Write-Warning "There was an issue getting information about $item"
      Write-Error $Error[0]
    }
      Write-Output (New-Object -TypeName PSObject -Property $properties)
  }

  if($PSBoundParameters.ContainsKey('ChefRepo')){
    Set-Location $CacheLocation
  }

}

Function Get-ChefEnvironment {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [System.string[]]
    $Environment,

    [System.string]
    $ChefRepo = (Get-Location)
  )

  $CacheLocation = Get-Location

  foreach ($item in $Environment){
    $results = & knife environment show $item
    $properties = @{

    }
    Write-Output $results
  }

  Set-Location $CacheLocation

}

function _knifenodeshow {
  param(
    [string]$Node
  )
    & knife node show $item
}

Export-ModuleMember -Function Get-*
Export-ModuleMember -Function Invoke-*
Export-ModuleMember -Function Copy-*
