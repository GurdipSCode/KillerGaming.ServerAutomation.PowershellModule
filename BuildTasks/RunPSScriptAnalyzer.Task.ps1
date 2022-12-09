taskx RunPSScriptAnalyzer @{
    Inputs  = (Get-ChildItem -Path $Source -Recurse -File)
    Outputs = $ManifestPath
    Jobs    = {
try
{
	$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
	Write-Host $outputDIR
	$psscriptAnalyzerDir = Join-Path -Path $outputDIR -ChildPath "PSScriptAnalyzer\psscriptanalyzer.csv"
	$psscriptAnalyzerHtml = Join-Path -Path $outputDIR -ChildPath "PSScriptAnalyzer"
	
	$results = Invoke-ScriptAnalyzer -Path .\KillerGaming.Powershell\Public -Recurse -ErrorAction Stop | Export-Csv $psscriptAnalyzerDir
	
	cd C:\Scripts\
	.\PSScriptAnalyzerReporter.ps1 -OutputPath $psscriptAnalyzerHtml -CsvPath $psscriptAnalyzerDir
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

    }
}
