function Resolve-Module
{
	[Cmdletbinding()]
	param
	(
		[Parameter(Mandatory)]
		[string[]]$Name
	)
	
	Process
	{
		foreach ($ModuleName in $Name)
		{
			$Module = Get-Module -Name $ModuleName -ListAvailable
			Write-Verbose -Message "Resolving Module $($ModuleName)"
			
			if ($Module)
			{
				
				
				Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
				Import-Module -Name $ModuleName -Force
			}
			
			
			else
			{
				Write-Verbose -Message "$($ModuleName) Missing, installing Module"
				Install-Module -Name $ModuleName -Force -SkipPublisherCheck
				Import-Module -Name $ModuleName -Force
			}
		}
	}
	
}

# Grab nuget bits, install modules, set build variables, start build.
	Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
	
	Resolve-Module Psake, PSDeploy, Pester, BuildHelpers, InjectionHunter
	
	Set-BuildEnvironment
	
	Invoke-psake .\psake.ps1
	exit ([int](-not $psake.build_success))

