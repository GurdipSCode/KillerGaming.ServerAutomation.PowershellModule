Function New-HypervVm
{
	[cmdletbinding(SupportsShouldProcess)]
	Param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of the new virtual machine")]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the type of game server size")]
		[string]$VMType,
		[switch]$Passthru
	)
	
	Write-Verbose "Creating new $VMType virtual machine"
	#universal settings regardless of type
	

	
	$SCVMMHost = [System.Environment]::GetEnvironmentVariable('SCVMMHost', 'Machine')
	$VMTemplate = [System.Environment]::GetEnvironmentVariable('GamingTemplateName', 'Machine')
	$Network = [System.Environment]::GetEnvironmentVariable('Network', 'Machine')
	$Path = [System.Environment]::GetEnvironmentVariable('VMPath', 'Machine')
	
	$VMTemplate = Get-SCVMTemplate | where { $_.Name -eq $VMTemplate }
	$VMHost = Get-SCVMHost -ComputerName $SCVMMHost
	$HostRating = Get-SCVMHostRating -DiskSpaceGB 5 -VMTemplate $VMTemplate -VMHost $VMHost -VMName "VM06"

	
	$VMTemplate = Get-SCVMTemplate -VMMServer $SCVMMHost | where { $_.Name -eq $GamingServerTemplateName }
	$VMHost = Get-SCVMHost -ComputerName $SCVMMHost
	New-SCVirtualMachine -VMTemplate $VMTemplate -Name $Name -VMHost $VMHost -Path "C:\VirtualMachinePath" -RunAsynchronously -HardwareProfile $HWProfile -ComputerName "Server01" -FullName "Elisa Daugherty" -OrgName "Contoso" -ProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
	

	New-SCVirtualMachine -
	#define parameter values based on VM Type
	Switch ($VMType)
	{
		"Small" {
			$MemoryStartup = 512MB
			$VHDSize = 10GB
			$ProcCount = 1
			$MemoryMinimum = 512MB
			$MemoryMaximum = 1GB
		}
		"Medium" {
			$MemoryStartup = 512MB
			$VHDSize = 20GB
			$ProcCount = 2
			$MemoryMinimum = 512MB
			$MemoryMaximum = 2GB
		}
		"Large" {
			$MemoryStartup = 1GB
			$VHDSize = 40GB
			$ProcCount = 4
			$MemoryMinimum = 512MB
			$MemoryMaximum = 4GB
		}
	} #end switch
	
	#define a hash table of parameters for New-VM
	$newParam = @{
		Name			   = $Name
		SwitchName		   = $Switch
		MemoryStartupBytes = $MemoryStartup
		Path			   = $Path
		NewVHDPath		   = $VHDPath
		NewVHDSizeBytes    = $VHDSize
		ErrorAction	       = "Stop"
	}
	
	#define a hash table of parameters for Set-VM
	$setParam = @{
		ProcessorCount	   = $ProcCount
		DynamicMemory	   = $True
		MemoryMinimumBytes = $MemoryMinimum
		MemoryMaximumBytes = $MemoryMaximum
		ErrorAction	       = "Stop"
	}
	
	if ($Passthru)
	{
		$setParam.Add("Passthru", $True)
	}
	Try
	{
		Write-Verbose "Creating new virtual machine"
		Write-Verbose ($newParam | out-string)
		$VM = New-VM @newparam
	}
	Catch
	{
		Write-Warning "Failed to create virtual machine $Name"
		Write-Warning $_.Exception.Message
		#bail out
		Return
	}
	
	if ($VM)
	{
		#mount the ISO file
		Try
		{
			Write-Verbose "Mounting DVD $iso"
			Set-VMDvdDrive -vmname $vm.name -Path $iso -ErrorAction Stop
		}
		Catch
		{
			Write-Warning "Failed to mount ISO for $Name"
			Write-Warning $_.Exception.Message
			#don't bail out but continue to try and configure virtual machine
		}
		Try
		{
			Write-Verbose "Configuring new virtual machine"
			Write-Verbose ($setParam | out-string)
			$VM | Set-VM @setparam
		}
		Catch
		{
			Write-Warning "Failed to configure virtual machine $Name"
			Write-Warning $_.Exception.Message
			#bail out
			Return
		}
		
	} #if $VM
}
	