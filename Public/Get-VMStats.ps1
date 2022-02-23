<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	06/02/2022 21:05
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-VMStats.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function List-hyperVHosts
{
	[cmdletbinding()]
	param (
		[string]$vmName
	)
	
	$UtilizationReport = Get-VM $vmName | Measure-VM
}