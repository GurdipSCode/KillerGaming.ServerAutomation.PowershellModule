# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = $PSScriptRoot
        }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major

    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

Task Default -Depends Init, Test, CheckSyntax, GenerateListOfFunctions, RunPSScriptAnalyzer, Pester

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    # $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    # # In Appveyor?  Upload our tests! #Abstract this into a function?
    # If($ENV:BHBuildSystem -eq 'AppVeyor')
    # {
    #     (New-Object 'System.Net.WebClient').UploadFile(
    #         "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
    #         "$ProjectRoot\$TestFile" )
    # }

    # Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # # Failed tests?
    # # Need to tell psake or it will proceed to the deployment. Danger!
    # if($TestResults.FailedCount -gt 0)
    # {
    #     Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    # }
    "`n"
}


Task CheckSyntax -Depends Test {
 
$lines

$scripts = Get-ChildItem -Path .\KillerGaming.Powershell -Include *.ps1, *.psm1, *.psd1 -Recurse |
Where-Object {$_.FullName -notmatch 'powershell'}

# TestCases are splatted to the script so we need hashtables
$testCases = $scripts | Foreach-Object {@{file = $_}}

It "Script <file> should be valid powershell" -TestCases $testCases {
param($file)

$file.FullName | Should Exist

    $contents = Get-Content -Path $file.FullName -ErrorAction Stop
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
    $errors.Count | Should Be 0
    }
 }


Task GenerateListOfFunctions -Depends CheckSyntax {

    $lines
    
    $modulePath =  Get-Item Env:BHModulePath | select -ExpandProperty Value
    $moduleManifest = Get-Item Env:BHPSModuleManifest | select -ExpandProperty Value
    
    cd .\KillerGaming.Powershell

    Write-Host "Getting functions..."

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


Task RunPSScriptAnalyzer -Depends GenerateListOfFunctions {

            $lines 

            $modulePath = Get-Item Env:BHPSModulePath | select -ExpandProperty Value
          
            $pubPath = Join-Path $modulePath -ChildPath "Public"

			$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
			Write-Host $outputDIR
			$psscriptAnalyzerDir = Join-Path -Path $outputDIR -ChildPath "PSScriptAnalyzer\psscriptanalyzer.csv"
			$psscriptAnalyzerHtml = Join-Path -Path $outputDIR -ChildPath "PSScriptAnalyzer"
			
			$results = Invoke-ScriptAnalyzer -Path $pubPath -Recurse -ErrorAction Stop | Export-Csv $psscriptAnalyzerDir
			
			cd C:\Scripts\
			.\PSScriptAnalyzerReporter.ps1 -OutputPath $psscriptAnalyzerHtml -CsvPath $psscriptAnalyzerDir
			$results

}

Task Pester -Depends RunPSScriptAnalyzer {

        $lines 

        $outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
        $psCodeHealth = Join-Path -Path $outputDIR -ChildPath "PSCodeHealth\HealthReport.html"
        Write-Host $psCodeHealth
        
        $projectPath = Get-Item Env:BHProjectPath | select -ExpandProperty Value
        $testPath = Join-Path $projectPath -ChildPath "Tests\KillerGaming.Powershell.Tests.ps1"
        Write-Host $testPath
        
        $modulePath = Get-Item Env:BHPSModulePath | select -ExpandProperty Value
        $pubPath = Join-Path $modulePath -ChildPath "Public"
        Write-Host $pubPath
        
        $testResultsPath = Join-Path $outputDIR -ChildPath "testResults/testResult.xml"
        Write-Host $testResultsPath

        Set-Location $projectPath

   $path = Join-Path $ProjectRoot -ChildPath "Tests\KillerGamingPowershell.Tests.ps1"

        
   Import-Module Pester -RequiredVersion 5.3.3

$PesterConfig = New-PesterConfiguration
$PesterConfig.Run.Path = $path
$PesterConfig.Run.PassThru = $true
$PesterConfig.CodeCoverage.Enabled = $true
$PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
$PesterConfig.CodeCoverage.OutputPath = "Pester-Coverage.xml"
$PesterConfig.TestResult.OutputFormat = "NUnitXml"
$PesterConfig.TestResult.OutputPath = "Test.xml"
$PesterConfig.TestResult.Enabled = $true

$testResult = Invoke-Pester -Configuration $PesterConfig | ConvertTo-Pester4Result
$ser = [System.Management.Automation.PSSerializer]::Serialize($testResult) | Out-File $testResultsPath
 #
  #    $configuration.Run.Container = $container
      #  Remove-Module Pester -Force

}

