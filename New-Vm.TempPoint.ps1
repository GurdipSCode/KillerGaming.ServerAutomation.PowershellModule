<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	16/01/2022 17:26
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	New-Vm.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



Import-Module PoShLog

function Start-Vm
{
	try
	{
		
		
		$VM = New-SCVirtualMachine -VMMServer "VMMServer01.Contoso.com" | where { $_.Name -eq "PowerOff" }
		$VM | Start-SCVirtualMachine
	}
	
	catch
	{
		
	}
}
