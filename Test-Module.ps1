<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	09/01/2022 23:23
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Test-Module.ps1
	===========================================================================
	.DESCRIPTION
	The Test-Module.ps1 script lets you test the functions and other features of
	your module in your PowerShell Studio module project. It's part of your project,
	but it is not included in your module.

	In this test script, import the module (be careful to import the correct version)
	and write commands that test the module features. You can include Pester
	tests, too.

	To run the script, click Run or Run in Console. Or, when working on any file
	in the project, click Home\Run or Home\Run in Console, or in the Project pane, 
	right-click the project name, and then click Run Project.
#>


#Explicitly import the module for testing
Import-Module 'KillerGaming.Powershell'

#Run each module function
Write-HelloWorld

#Sample Pester Test

Describe "Get-HyperVHosts" {
	
	mock 'Get-ADForest'
	
	context 'Return hyperv hosts in domain' {
		## This ensures Test-Path always returns $false "mimicking" the file does not exist
		
		
		
		$null = .\Find-HyperVHosts.ps1
		
		it 'returns hosts' {
			## This checks to see if New-Item attempted to run. If so, we know the script did what we expected
			$assMParams = @{
				CommandName = 'Get-ADForest'
				Times	    = 1
				Exactly	    = $true
			}
			Assert-MockCalled @assMParams
		}
	}
}
