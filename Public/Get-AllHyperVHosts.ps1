<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	02/12/2022 17:56
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-AllHyperVHosts.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-AllHyperVHosts
{
	
	[cmdletbinding()]
	param (

		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new VMM Host Group")]
		[ValidateNotNullOrEmpty()]
		[string]$vmmHostGroup
		
	)
	{
		
		$hosts = Get-SCVMHost -VMHostGroup $vmHostGroup | ConvertTo-Json
		
	}
}
