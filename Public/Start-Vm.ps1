<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	09/01/2022 23:26
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Start-Vm.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
Import-Module PoShLog

function Start-Vm
{
	try
	{
		
		New-Logger | # Create new instance of logger configuration
		Set-MinimumLevel -Value Verbose | # Set minimum level, below which no events should be generated
		Add-SinkFile -Path 'E:\AppLogs\ServerAutomation-API\Module\log-.log' -RollingInterval Day | # Add sink that will write our event messages into file
		Add-SinkConsole | # Add sink that will log our event messages into console host
		Start-Logger # Start logging
		
		
		$VM = Get-SCVirtualMachine -Name $vmName -VMMServer $VMMServer | where { $_.Status -eq "PowerOff" }
		$json = $VM | Start-SCVirtualMachine | ConvertTo-Json
	}
	
	catch
	{
		
	}
}

