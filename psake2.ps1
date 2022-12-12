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

Task Default -Depends RunPSCodeHealth

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task RunPSCodeHealth -Depends Init {


        $lines

       $outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')

        
        $testResultsPath = Join-Path $outputDIR -ChildPath "testResults/testResult.xml"
        Write-Host $testResultsPath

Uninstall-Module Pester -Force
Import-Module Pester -RequiredVersion 4.0.2

$ser = Get-Content $testResultsPath
$testResult = [System.Management.Automation.PSSerializer]::Deserialize($ser)

$d = Invoke-PSCodeHealth -Path $pubPath -TestsResult $testResult

$d
}
