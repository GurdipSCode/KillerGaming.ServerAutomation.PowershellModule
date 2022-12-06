# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
	# Find the build folder based on build system
	$ProjectRoot = $ENV:BHProjectPath
	if (-not $ProjectRoot)
	{
		$ProjectRoot = $PSScriptRoot
	}
	
	
	$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
	$PSVersion = $PSVersionTable.PSVersion.Major
	$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
	$lines = '----------------------------------------------------------------------'
	
	$Verbose = @{ }
	if ($ENV:BHCommitMessage -match "!verbose")
	{
		$Verbose = @{ Verbose = $True }
	}
}

Task Default -Depends Deploy

Task Init {
	$lines
	Set-Location $ProjectRoot
	"Build System Details:"
	Get-Item ENV:BH*
	"`n"
}

Task Test -Depends Init  {
	$lines
#	"`n`tSTATUS: Testing with PowerShell $PSVersion"
#	
#	# Gather test results. Store them in a variable and file
#	$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
#	
#	# In Appveyor?  Upload our tests! #Abstract this into a function?
#	If ($ENV:BHBuildSystem -eq 'AppVeyor')
#	{
#		(New-Object 'System.Net.WebClient').UploadFile(
#			"https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
#			"$ProjectRoot\$TestFile")
#	}
#	
#	Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
#	
#	# Failed tests?
#	# Need to tell psake or it will proceed to the deployment. Danger!
#	if ($TestResults.FailedCount -gt 0)
#	{
#		Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
#	}
	"`n"
}

Task Build -Depends Test {
	$lines
	
	.\Run-PSScriptAnalyzer.ps1
	
	Set-Location $ProjectRoot
	Select-String -Path .\KillerGaming.Powershell\KillerGaming.Powershell.psd1 -Pattern FunctionsToExport
	
	# PSSlack\PSSlack.psd1:61:FunctionsToExport = '*'
	
	# Update the psd1 with Set-ModuleFunction:
	$moduleName = Get-Item . | ForEach-Object BaseName
	
	# RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
	$functionNames = Get-ChildItem -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" } -PipelineVariable file | ForEach-Object {
		$ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
		if ($ast.EndBlock.Statements.Name)
		{
			$ast.EndBlock.Statements.Name
		}
	}
	Write-Verbose "Using functions $functionNames"
	
	Update-ModuleManifest -Path ".\KillerGaming.Powershell\$($moduleName).psd1" -FunctionsToExport $functionNames
	
	Update-Metadata -Path $env:BHPSModuleManifest
	
	# Check FunctionsToExport again:
	Select-String -Path .\KillerGaming.Powershell\KillerGaming.Powershell.psd1 -Pattern FunctionsToExport
	
	

	Invoke-PSCodeHealth .\Public .\coveralls -HtmlReportPath .\HealthReport.html
	

	
	# Bump the module version
	Update-Metadata -Path $env:BHPSModuleManifest
}

Task Deploy -Depends Build {
	$lines
	
	$Params = @{
		Path    = $ProjectRoot
		Force   = $true
		Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
	}
	Invoke-PSDeploy @Verbose @Params
}