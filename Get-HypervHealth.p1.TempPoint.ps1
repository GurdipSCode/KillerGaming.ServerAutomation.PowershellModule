<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	28/01/2022 00:17
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-HypervHealth.p1.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

foreach ($hypervHost in $hypervHosts)
{
	
	
	New-PSSession -ComputerName $hypervHost
	
}