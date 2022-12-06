<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.210
	 Created on:   	25/11/2022 16:02
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Checkpoint-VM.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

Function New-HypervVm
{
	[cmdletbinding(SupportsShouldProcess)]
	Param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new virtual machine")]
		[ValidateNotNullOrEmpty()]
		[string]$VMName
	)
	
	$VM = Get-SCVirtualMachine -Name $VMName
	
	$jobVariable = $VM.Name + [guid]::NewGuid()
	
	$newCheckpoint = New-SCVMCheckpoint -RunAsynchronously -JobVariable $jobVariable -VM $VM
	$JSON = $newCheckpoint | ConvertTo-Json
}