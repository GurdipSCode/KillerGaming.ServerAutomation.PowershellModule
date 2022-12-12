Set-BuildEnvironment
Invoke-psake .\psake2.ps1
exit ( [int]( -not $psake.build_success ) )