$Script:ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
$Script:CodeCoveragePercent = 0.0 # 0 to 1



$Script:Modules = @(
    'BuildHelpers',
    'InvokeBuild',
    'Pester',
    'platyPS',
    'PSScriptAnalyzer',
    'DependsOn',
	'PSCodeHealth'
)

$Script:ModuleInstallScope = 'CurrentUser'

'Starting build...'
'Installing module dependencies...'

Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

# Install-Module -Name $Script:Modules -Scope $Script:ModuleInstallScope -Force -SkipPublisherCheck

Set-BuildEnvironment -Force
Get-ChildItem Env:BH*


$Error.Clear()

"Invoking build action"

.\.build.ps1




# Write-Host 'Import common tasks'
# Get-ChildItem -Path $buildroot\BuildTasks\*.Task.ps1 | ForEach-Object {
#     Write-Host $_.FullName;. $_.FullName}