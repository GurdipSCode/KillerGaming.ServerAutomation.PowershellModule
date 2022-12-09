task GenerateListOfFunctions {
    # Set exported functions by finding functions exported by *.psm1 file via Export-ModuleMember

	# Going into module folder
	cd .\KillerGaming.Powershell

    Write-Host "Getting functions..."

	Write-Host (Get-Item .).FullName

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
	
	Update-ModuleManifest -Path $env:BHPSModuleManifest -FunctionsToExport $functionNames
	
	Update-Metadata -Path $env:BHPSModuleManifest
	
	# Check FunctionsToExport again:
	Select-String -Path .\KillerGaming.Powershell\KillerGaming.Powershell.psd1 -Pattern FunctionsToExport
}

Set-BuildEnvironment
task . GenerateListOfFunctions