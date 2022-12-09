
task RunPSScriptAnalyzer @{
{
    try
    {
        $outputDIR = [Environment]::GetEnvironmentVariable('KillerGaming.PowershellHyperv Module Output Dir', 'Machine')
        $psCodeHealth = Join-Path -Path $outputDIR -ChildPath "PSCodeHealth\HealthReport.html"
        
        Invoke-PSCodeHealth -Path .\KillerGaming.Powershell\Public -HtmlReportPath $psCodeHealth
    }
}
}