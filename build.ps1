task GenerateListOfFunctions {
	param(
    	$Configuration = ''
	)
    # Set exported functions by finding functions exported by *.psm1 file via Export-ModuleMember

	# Going into module folder
	cd .\KillerGaming.Powershell

    Write-Host "Getting functions..."

	$modulePath = (Get-Item .).FullName
	$moduleManifest = Join-Path -Path $modulePath -ChildPath "/KillerGaming.Powershell.psd1"

	Write-Host $moduleManifest

    Set-Location -Path (Get-Item .).FullName
	Select-String -Path KillerGaming.Powershell.psd1 -Pattern FunctionsToExport
	

	# Update the psd1 with Set-ModuleFunction:
	$moduleName = Get-Item . | ForEach-Object BaseName
	
	# RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
	$functionNames = Get-ChildItem -Path ".\Public" -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" } -PipelineVariable file | ForEach-Object {
		$ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
		if ($ast.EndBlock.Statements.Name)
		{
			$ast.EndBlock.Statements.Name
		}
	}
	Write-Verbose "Using functions $functionNames"
	
	Update-ModuleManifest -Path $moduleManifest -FunctionsToExport $functionNames
	
	Update-Metadata -Path $moduleManifest
	
	# Check FunctionsToExport again:
	Select-String -Path $moduleManifest -Pattern FunctionsToExport
}

task RunPSScriptAnalyzer {

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

task . GenerateListOfFunctions, RunPSScriptAnalyzer