<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	17/01/2022 00:34
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-SCVMMHealth.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Start-Vm
{
	try
	{
		Enter-PSSession -ComputerName
		
		$disk = Get-Volume -DriveLetter C
		
		# Check windows services.
		
		$arrService = Get-Service -Name $ServiceName
		if ($arrService.Status -ne "Running")
		{
			
		}
		
		else
		{
			
		}

		
		# Check storage.
		
		Get-SCVMMServer
		
		$VM = New-SCVirtualMachine -VMMServer "VMMServer01.Contoso.com" | where { $_.Name -eq "PowerOff" }
		$VM | Start-SCVirtualMachine
	}
	
	catch
	{
		
	}
}

