# PSake makes variables declared here available in other scriptblocks
# Init some things


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

Install-Module -Name $Script:Modules -Scope $Script:ModuleInstallScope -Force -SkipPublisherCheck

Import-Module -Name $Script:Modules -Force

