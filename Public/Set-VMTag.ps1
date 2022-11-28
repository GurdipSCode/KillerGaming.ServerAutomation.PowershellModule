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



$VM = Get-SCVirtualMachine -Name $vmName
if ($VM.Status -ne "PowerOff") { Stop-SCVirtualMachine -VM $VM }
Set-SCVirtualMachine -VM $VM -Tag