Import-Module Pester -MaximumVersion 5.*


		$configuration              = [PesterConfiguration]::Default
		$configuration.Run.Path     = "%system.teamcity.build.checkoutDir%\Tests\KillerGaming.Powershell.Tests.ps1"
		$configuration.Run.PassThru = $true
		$testResult = Invoke-Pester -Configuration $configuration | ConvertTo-Pester4Result

		Remove-Module Pester -Force
		Import-Module Pester -MaximumVersion 4.*

        $s = Invoke-PSCodeHealth -Path '%system.teamcity.build.checkoutDir%\KillerGaming.Powershell\Public' -TestsPath '%system.teamcity.build.checkoutDir%\Tests' -HtmlReportPath '.\s.html' -PassThru
        Test-PSCodeHealthCompliance -HealthReport $s
        Remove-Module Pester -Force