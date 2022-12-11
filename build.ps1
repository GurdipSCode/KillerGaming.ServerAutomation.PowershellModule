Set-BuildEnvironment

Invoke-psake .\psake1.ps1
exit ( [int]( -not $psake.build_success ) )