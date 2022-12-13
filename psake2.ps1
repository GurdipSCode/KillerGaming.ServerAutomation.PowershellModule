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
        $modulePath = Get-Item Env:BHPSModulePath | select -ExpandProperty Value
        $pubPath = Join-Path $modulePath -ChildPath "Public"
        
        $testResultsPath = Join-Path $outputDIR -ChildPath "testResults/testResult.xml"
        Write-Host $testResultsPath


Install-Module -Name Pester -RequiredVersion 4.0.2 -Force -SkipPublisherCheck
Import-Module -Name Pester -RequiredVersion 4.0.2


$ser = Get-Content $testResultsPath
$testResult = [System.Management.Automation.PSSerializer]::Deserialize($ser)

$d = Invoke-PSCodeHealth -Path $pubPath -TestsResult $testResult

$d
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


Task PublishModule -Depends CopyModule { 

    $lines
	Publish-Module -Path E:\output\KillerGaming.PowershellHyperV\717ee3a38b06b58eb361f00aacbae2da54db5dc8\KillerGaming.Powershell -NuGetApiKey a9337a4573920f521dd03092ab173aa4e6184d94 -Repository KillerGamingPowershell2 
}

