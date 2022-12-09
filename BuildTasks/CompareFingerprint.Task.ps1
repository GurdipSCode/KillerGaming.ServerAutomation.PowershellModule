

task GenerateListOfFunctionsToExport {
    # Set exported functions by finding functions exported by *.psm1 file via Export-ModuleMember
    $params = @{
        Force    = $true
        Passthru = $true
        Name     = (Resolve-Path (Get-ChildItem -Path $moduleSourcePath -Filter '*.psm1')).Path
    }

    if ( Test-Path .\fingerprint )
    {
        $oldFingerprint = Get-Content .\fingerprint
    }

$bumpVersionType = ''
$fingerprint | Where {$_ -notin $oldFingerprint } | 
    ForEach-Object {$bumpVersionType = 'Minor'; "  $_"}


$oldFingerprint | Where {$_ -notin $fingerprint } | 
    ForEach-Object {$bumpVersionType = 'Major'; "  $_"}

Set-Content -Path .\fingerprint -Value $fingerprint

$ManifestPath = '.\MyModule.psd1'
Step-ModuleVersion -Path $ManifestPath -By $bumpVersionType

}

