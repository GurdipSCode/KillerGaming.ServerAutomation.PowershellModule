<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	28/11/2022 18:27
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Run-PSScriptAnalyzer.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



try
{
	if (Get-Module PSScriptAnalyzer)
	{
		Import-Module -Name PSScriptAnalyzer -ErrorAction Stop
	}
	else
	{
		Install-Module PSScriptAnalyzer -Force
	}
}
catch
{
	Write-Error -Message $_
	exit 1
}

try
{
	$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
	Write-Host $outputDIR
	$psscriptAnalyzerDir = Join-Path -Path $outputDIR -ChildPath "PSScriptAnalyzer\psscriptanalyzer.csv"
	$rules = Get-ScriptAnalyzerRule -Severity Warning, Error -ErrorAction Stop
	$results = Invoke-ScriptAnalyzer -Path .\Public -IncludeRule $rules.RuleName -Recurse -ErrorAction Stop | Export-Csv $psscriptAnalyzerDir
	$results
}
catch
{
	Write-Error -Message $_
	exit 1
}
if ($results.Count -gt 0)
{
	Write-Host "Analysis of your code threw $($results.Count) warnings or errors. Please go back and check your code."
	exit 1
}
else
{
	Write-Host 'Awesome code! No issues found!' -Foregroundcolor green
}