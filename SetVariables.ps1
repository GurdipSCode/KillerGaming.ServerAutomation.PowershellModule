$Script:ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
$Script:CodeCoveragePercent = 0.0 # 0 to 1



$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')        
Write-Host $outputDIR
$varsDir = Join-Path -Path $outputDIR -ChildPath "vars"

Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

set-Location $varsDir

Set-BuildEnvironment -Force
Get-ChildItem Env:BH*
Get-ChildItem Env:BH* | ForEach-Object { $_.Name + "," +  $_.Value | Out-File buildvars.csv -Append }

$global:Path = $Env:BHProjectPath



# Write-Host 'Import common tasks'
# Get-ChildItem -Path $buildroot\BuildTasks\*.Task.ps1 | ForEach-Object {
#     Write-Host $_.FullName;. $_.FullName}

