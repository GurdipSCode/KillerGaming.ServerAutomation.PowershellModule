Function New-HypervVm
{
	[cmdletbinding(SupportsShouldProcess)]
	Param (
		[Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of your new virtual machine")]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[ValidateSet("Small", "Medium", "Large")]
		[string]$VMType = "Small",
		[switch]$Passthru
	)
	
	Write-Verbose "Creating new $VMType virtual machine"
	#universal settings regardless of type
	
	#the ISO for installing Windows 2012
	$ISO = "G:\iso\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"
	
	#all VMs will be on the same network switch
	$Switch = "Work Network"
	
	#path for the virtual machine. All machines will use the same path.
	$Path = "D:\VMs"
	
	# TEMPLATE VHDX
	$templatePath = "F:\Virtual Machines\Templates\Windows Server 2019 Datacenter Full.vhdx"
	
	#path for the new VHDX file. All machines will use the same path.
	$VHDPath =  New-VHD -Path ($path.FullName + "\" + $vmname + ".vhdx") -ParentPath $templatePath -Differencing
	
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
	