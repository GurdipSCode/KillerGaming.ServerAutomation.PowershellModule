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

Task Default -Depends Init, Test, CheckSyntax, GenerateListOfFunctions, RunPSScriptAnalyzer, RunPSCodeHealth

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

Task RunPSCodeHealth -Depends RunPSScriptAnalyzer {

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

        Import-Module Pester -MaximumVersion 5.*

        $container = New-PesterContainer -Path $ProjectRoot/Tests/KillerGaming.Powershell.Tests.ps1

		$configuration              = [PesterConfiguration]::Default
	 #	$configuration.Run.Path     = $ProjectRoot/Tests
		$configuration.Run.PassThru = $true

        $configuration.Run.Container = $container

		$testResult = Invoke-Pester -Configuration $configuration | ConvertTo-Pester4Result

		Remove-Module Pester -Force
		Import-Module Pester -MaximumVersion 4.*

        $s = Invoke-PSCodeHealth -Path $pubPath -TestsPath $ProjectRoot/Tests -HtmlReportPath $psCodeHealth -PassThru
      
        Test-PSCodeHealthCompliance -HealthReport $s
        Remove-Module Pester -Force

}

# Task SetVersion -Depends RunPSCodeHealth {

# $lines

# $outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
# #$outputDIR = "C:\Repos"
# Write-Host $outputDIR
# $fingerprintsDir = Join-Path -Path $outputDIR -ChildPath "fingerprints"

# # Get outgoing module from Proget
# Install-Module -Name "KillerGaming.Powershell" -Repository "KillerGamingPowershell" -Force
# Import-Module -Name "KillerGaming.Powershell" -Force
# $oldCommands = Get-Command -Module "KillerGaming.Powershell"
# Remove-Module -Name "KillerGaming.Powershell"


# Write-Output 'Calculating fingerprint'
# $oldFingerprint = foreach ( $command in $oldCommands )
# {
#     foreach ( $parameter in $command.parameters.keys )
#     {
#         '{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
#         $command.parameters[$parameter].aliases | 
#             Foreach-Object { '{0}:{1}' -f $command.name, $_}
#     }
# }

# Set-Location -Path $fingerprintsDir
# Set-Content -Path .\oldFingerprint -Value $oldFingerprint

# $modulePath = "C:\Repos\KillerGaming.Powershell\KillerGaming.Powershell\KillerGaming.Powershell"

# # Get new module from src
# Import-Module -Name $modulePath -Force
# $newCommands = Get-Command -Module "KillerGaming.Powershell"
# Remove-Module -Name "KillerGaming.Powershell"


# Write-Output 'Calculating fingerprint'
# $newFingerprint = foreach ( $command in $newCommands )
# {
#     foreach ( $parameter in $command.parameters.keys )
#     {
#         '{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
#         $command.parameters[$parameter].aliases | 
#             Foreach-Object { '{0}:{1}' -f $command.name, $_}
#     }
# }

# Set-Location -Path $fingerprintsDir
# Set-Content -Path .\newFingerprint -Value $newFingerprint

# $bumpVersionType = ''
# $bumpVersionTypeMajor = ''
# $newFingerprint | Where {$_ -notin $oldFingerprint } | 
#     ForEach-Object {$bumpVersionType = 'Minor'; "  $_"}


# $oldFingerprint | Where {$_ -notin $fingerprint } | 
#     ForEach-Object {$bumpVersionTypeMajor = 'Major'; "  $_"}


# if ($bumpVersionType -eq 'Minor') {
# Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType
# }

# elseif ($bumpVersionTypeMajor -eq 'Major') {
# Step-ModuleVersion -Path $ManifestPath -By $bumpVersionTypeMajor
# }



# }


# Task CopyModule -Depends SetVersion  {

#     $lines

# 	$outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
# 	$outputModule = Join-Path -Path $outputDIR -ChildPath "KillerGaming.Powershell"
			

# 	$moduleDir = "./KillerGaming.Powershell/*"

# 	Copy-Item -Path $moduleDir -Destination $outputModule -Recurse 
# }






# Task PublishModule -Depends CopyModule { 

#     $lines
# 	Publish-Module -Path E:\output\KillerGaming.PowershellHyperV\717ee3a38b06b58eb361f00aacbae2da54db5dc8\KillerGaming.Powershell -NuGetApiKey a9337a4573920f521dd03092ab173aa4e6184d94 -Repository KillerGamingPowershell2 
# }
