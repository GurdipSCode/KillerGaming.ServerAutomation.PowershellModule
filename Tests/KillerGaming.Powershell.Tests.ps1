<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	23/02/2022 19:35
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	KillerGaming.Powershell.Tests.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>




Import-Module $PSScriptRoot\..\KillerGaming.Powershell -Force


#Integration test example
Describe "Get-SEObject PS$PSVersion Integrations tests" {
	
	Context 'Strict mode' {
		
		Set-StrictMode -Version latest
		$s = sample
		
		It 'should get valid data' {
		
			$s -gt 1 | Should be $True
	
		}
	}
}
