 taskx RunPSScriptAnalyzer @{
    Inputs  = (Get-ChildItem -Path $Source -Recurse -File)
    Outputs = $ManifestPath
    Jobs    = {

 
  $scripts = Get-ChildItem -Path $Path -Include *.ps1, *.psm1, *.psd1 -Recurse |
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
 }
    