Import-Module ./knife.psm1 -Force

Describe 'Get-ChefNode'{
  Mock -CommandName _knifenodeshow -ModuleName Knife {
    $return = @"
Node Name:   node1
Environment: mockprod
FQDN:        johndscx04.corp.fmglobal.com
IP:          22.2.1.233
Run List:    role[webserver]
Roles:       webserver
Recipes:     dsc, new_iis, globallockdown, globallockdown::iislogs, globallockdown::ApplicationPoolDefaults, globallockdown::fmgloballog, DSCTestAppPool, dsc::default, new_iis::default, globallockdown::default, DSCTestAppPool::default
Platform:    windows 6.3.9600
Tags:        dsc
"@
    Write-Output ($return -Split '\r?\n')
  }

  $node = Get-ChefNode -Node 'node1' -ChefRepo 'c:\chef-repo'
  $parameters = (Get-Command Get-ChefNode).parameters

  It 'Should accept parameter node'{
    $parameters.ContainsKey('node') | Should Be $true
  }

  It 'Should accept parameter ChefRepo' {
    $parameters.ContainsKey('Chefrepo') | Should Be $true
  }

  It 'Should Call get-node once'{
    Assert-MockCalled -CommandName _knifenodeshow -ModuleName Knife -Exactly 1
  }

  It 'should return an object with an Environment Property that matches mockprod'{
    $node.Environment | Should Be 'mockprod'
  }

  It 'Should return an object with an IP Property that matches 22.2.1.233'{
    $node.IP | Should Be '22.2.1.233'
  }

  It 'Should return an object with Roles that match webserver' {
    $node.Roles | Should Be 'webserver'
  }

  It 'Should return an object with a Recipes Property matches all the recipes'{
    $node.Recipes -contains 'dsc'| Should Be $true #'dsc, new_iis, globallockdown, globallockdown::iislogs, globallockdown::ApplicationPoolDefaults, globallockdown::fmgloballog, DSCTestAppPool, dsc::default, new_iis::default, globallockdown::default, DSCTestAppPool::default'
  }

  It 'Should return an object with a Tags Property that matches dsc'{
    $node.Tags | Should Be 'dsc'
  }

  It 'Should return an object with a Platform Property that matches windows 6.3.9600'{
    $node.Platform | Should Be 'windows 6.3.9600'
  }

  It 'Should return an object with a RunList Property that matches role[webserver]'{
    $node.RunList | Should Be 'role[webserver]'
  }

  It 'Should retuen an object with a FQDN Property that matches johndscx04.corp.fmglobal.com'{
    $node.FQDN | Should Be 'johndscx04.corp.fmglobal.com'
  }

}
