<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	14/02/2022 21:26
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-HypervHealth.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	28/01/2022 00:17
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Get-HypervHealth.p1.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Get-HypervHealth
{
	[CmdletBinding()]
	Param (
		[Parameter()]
		[string]$hyperVHost)
	
	$netbiosName = [System.Net.Dns]::GetHostByName($env:computerName)
	
	$myHashtable = @{
		Memory	     = ''
		CPU		     = ''
		Service	     = ''
		Storage	     = ''
		Connectivity = ''
	}
	
	$TestPath = Test-Path "\\GLOHYPERV01\c$"
	
	If ($TestPath -match "True")
	{
		$myHashtable.Connectivity = 'Good'
		New-PSSession -ComputerName "GLOHYPERV01.GLOBAL.GSSIRA.COM" -Credential (Get-Credential)
	}
	
	else
	{
		$myHashtable.Connectivity = 'Degraded'
	}
		
		
	Get-VMHost -ComputerName
	
	# Check service status
	Get-Service vmcompute | %{
		if ($_.Status -eq "Stopped")
		{
			$myHashtable.Service = 'Degraded'
		}
		
		elseif ($_.Status -eq 'Running')
		{
			$myHashtable.Service = 'Good'
		}
	}
	
	# Get free memory. Must be enough for the VM to provision.
	$os = Get-Ciminstance Win32_OperatingSystem
	$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize) * 100, 2)
	
	if ($pctFree > 80)
	{
		$myHashtable.Memory = 'Degraded'
	}
	
	#}
}