<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	15/01/2022 17:13
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Find-HyperVHost.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-HyperVHosts
{
	
	[cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new VMM Server")]
		[ValidateNotNullOrEmpty()]
		[string]$vmmServer
	)
	try
	{
		
		Get-SCVMHost -VMMServer $vmmServer | select Name, OperatingSystem | ConvertTo-Json
	}
	catch
	{
		Write-Warning "Failed to import Active Directory module. Cannot continue. Aborting..."
		break;
	}
	
}

