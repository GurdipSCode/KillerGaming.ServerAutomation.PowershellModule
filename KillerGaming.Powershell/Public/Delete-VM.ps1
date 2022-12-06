


<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	25/11/2022 15:54
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Delete-VM.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Delete-VM
{
	
	[cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new VMM Server")]
		[ValidateNotNullOrEmpty()]
		[string]$vmmServer,
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new VMM Server")]
		[ValidateNotNullOrEmpty()]
		[string]$vmName
	)
	{
		
		$VM = Get-SCVirtualMachine -VMMServer $vmmServer -Name $vmName
		Remove-SCVirtualMachine -VM $VM
		
	}
}
		