<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	25/11/2022 14:34
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Set-VMTag.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

Function Set-VMTag
{
	[cmdletbinding(SupportsShouldProcess)]
	Param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new virtual machine")]
		[ValidateNotNullOrEmpty()]
		[string]$VMTemplate,
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the type of game server size")]
		[string]$VMMServer,
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the type of game server size")]
		[string]$VMTag
		
	)

	$VM = Get-SCVirtualMachine -Name $vmName
	Set-SCVirtualMachine -VM $VM -Tag

}