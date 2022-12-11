Set-BuildEnvironment

Invoke-psake . .\psake.ps1
exit ( [int]( -not $psake.build_success ) )