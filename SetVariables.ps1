$Script:ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
$Script:CodeCoveragePercent = 0.0 # 0 to 1



$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')        
Write-Host $outputDIR
$varsDir = Join-Path -Path $outputDIR -ChildPath "vars"

Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

$Headers  = "Name, Value"
set-Location $varsDir
$Headers | Out-File buildvars.csv -Append

cd .\KillerGaming.powershell
Set-BuildEnvironment -Force
$vars = Get-ChildItem Env:BH*
$vars
set-Location $varsDir
Get-ChildItem Env:BH* | ForEach-Object { $_.Name + "," +  $_.Value | Out-File buildvars.csv -Append }




# Write-Host 'Import common tasks'
# Get-ChildItem -Path $buildroot\BuildTasks\*.Task.ps1 | ForEach-Object {
#     Write-Host $_.FullName;. $_.FullName}

