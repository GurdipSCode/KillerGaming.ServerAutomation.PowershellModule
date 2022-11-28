﻿


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



$VM = Get-SCVirtualMachine -VMMServer "VMMServer01.Contoso.com" | where { $_.VMHost.Name -eq "VMHost01.Contoso.com" -and $_.Name -eq "VM01" }
Remove-SCVirtualMachine -VM $VM