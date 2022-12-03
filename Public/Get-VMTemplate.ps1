


<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	28/11/2022 13:24
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-VMTemplate.ps1
	===========================================================================
	.DESCRIPTION
		Gets SCVMM Templates.
#>



Function Get-VMTemplate
{
	[cmdletbinding(SupportsShouldProcess)]
	Param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new virtual machine")]
		[ValidateNotNullOrEmpty()]
		[string]$VMTemplate,
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the type of game server size")]
		[string]$VMMServer
		
	)
	
	
	
	Get-SCVMTemplate -Name $VMTemplate -VMMServer $VMMServer | ConvertTo-Json
}

