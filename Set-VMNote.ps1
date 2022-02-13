<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	19/01/2022 21:51
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Set-VMNote.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>




Function Set-VMNote
{
	[CmdletBinding(DefaultParameterSetName = 'Name', SupportsShouldProcess)]
	[OutputType("none", "VirtualMachine")]
	Param (
		
		[Parameter(ParameterSetName = 'VMObject', Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "A Hyper-V virtual machine object.")]
		[ValidateNotNullOrEmpty()]
		[Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
		[Parameter(ParameterSetName = 'Name', Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "Enter the name of a virtual machine.")]
		[Alias('VMName')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Name,
		[Parameter(HelpMessage = "Enter the text for the note.")]
		[string]$Notes,
		[Parameter(HelpMessage = "Specify what action to take with the note.")]
		[ValidateSet("Create", "Append", "Clear")]
		[string]$Action = "Create",
		[Parameter(HelpMessage = "Write the VM object to the pipeline.")]
		[switch]$Passthru,
		[Parameter(ParameterSetName = 'Name', HelpMessage = "Enter the name of a Hyper-V host. The default is the localhost.")]
		[ValidateNotNullOrEmpty()]
		[string]$ComputerName = $env:COMPUTERNAME
		
	)
	DynamicParam
	{
		#allow an alternate credential for remote servers
		if ($Computername -ne $env:computername -OR ($VM -AND $vm[0].computername -ne $env:computername))
		{
			
			#define a parameter attribute object
			$attributes = New-Object System.Management.Automation.ParameterAttribute
			$attributes.HelpMessage = "Enter an alternate credential in the form domain\username or computername\username. If you used a credential to get the VM in any way, then you need to re-use it to set the note."
			
			#define a collection for attributes
			$attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
			$attributeCollection.Add($attributes)
			
			#define the dynamic param
			$dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Credential", [PSCredential], $attributeCollection)
			$dynParam1.Value = [System.Management.Automation.PSCredential]::Empty
			
			#create array of dynamic parameters
			$paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
			$paramDictionary.Add("Credential", $dynParam1)
			
			#use the array
			return $paramDictionary
		}
		
	}
	
	
	Begin
	{
		Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
		
		
		#define a scriptblock to run remotely
		$sb = {
			#uncomment the Write-Host lines for troubleshooting
			#write-host "In scriptblock" -ForegroundColor cyan
			#write-Host "Getting WMI VM object for $($using:vname)" -ForegroundColor green
			try
			{
				$data = Get-WmiObject -Namespace root/virtualization/v2 -Class msvm_VirtualSystemSettingData -filter "ElementName='$using:VName'" -ErrorAction stop
				if (-Not $data.ElementName)
				{
					Throw "Item not found"
				}
			}
			catch
			{
				Write-Warning "Failed to get VirtualSystemSettingData for $($using:vname). $($_.exception.message)."
				#bail out
				return
			}
			if ($using:action -eq 'Clear')
			{
				#write-host "Clear" -ForegroundColor cyan
				$data.Notes = ""
			}
			elseif ($using:action -eq 'Append')
			{
				#write-host "append" -ForegroundColor cyan
				if (([regex]"\w+").ismatch($data.notes))
				{
					#get the existing array
					#write-host "Using existing array" -ForegroundColor cyan
					$vmnotes = $data.notes.trim() -as [array]
				}
				else
				{
					#initialze a new one
					#write-host "Initializing a new one" -ForegroundColor cyan
					$vmnotes = @()
				}
				
				$vmnotes += $using:Notes
				$data.Notes = $vmNotes | Out-String
			}
			else
			{
				#write-host "create" -ForegroundColor Cyan
				$data.Notes = $using:Notes | Out-String
			}
			
			#Write-Host "Apply changes" -ForegroundColor cyan
			$text = $data.GetText("CimDtd20")
			$vmms = Get-WmiObject -Namespace root/virtualization/v2 -Classname msvm_virtualsystemmanagementservice
			$vmms.ModifySystemSettings($text)
		} #close scriptblock
		
		#define parameters to splat to Invoke-Command
		$runParams = @{
			ErrorAction = "Stop"
			Session	    = $null
			Scriptblock = $sb
		}
	} #begin
	
	Process
	{
		
		Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using parameter set $($pscmdlet.ParameterSetName)"
		if (-Not $PSSess)
		{
			#create a PSSession to the remote computer if it doesn't already exist
			#it is assumed all VMs are on the same Hyper-V host
			if ($pscmdlet.ParameterSetName -eq "name")
			{
				$vmhost = $Computername
			}
			else
			{
				$vmhost = $VM[0].computername
			}
			$newps = @{
				ErrorAction  = "Stop"
				Computername = $vmHost
			}
			if ($credential)
			{
				$newps.Add("Credential", $Credential)
			}
			Try
			{
				if ($pscmdlet.ShouldProcess($vmhost, "Create PSSession"))
				{
					$pssess = New-PSSession @newps
				}
			}
			Catch
			{
				Throw $_
			}
			$runParams.session = $PSSess
		}
		
		#define a collection of objects to process based on the detected parameter set
		if ($PSCmdlet.ParameterSetName -eq "VMObject")
		{
			$collection = $VM
		}
		else
		{
			$collection = $Name
		}
		#loop through each item in the collection which will be either a VM object or the name of a VM
		foreach ($item in $collection)
		{
			if ($item.name)
			{
				$vname = $item.name
			}
			else
			{
				$vname = $item
			}
			
			if ($pscmdlet.shouldprocess($vname, "$Action note(s)"))
			{
				#write-verbose ($runParams | Out-string)
				$r = Invoke-Command @runParams
				if ($r -AND $r.returnValue -ne 0)
				{
					Write-Warning "Setting the note for $vmname on $($pssess.computername) failed. Return value is $($r.returnvalue)."
				}
				if ($passthru)
				{
					Invoke-Command { Get-VM $using:vname } -session $pssess
				}
			}
		} #foreach vmobject
		
	} #process
	
	End
	{
		if ($PSSess)
		{
			Write-Verbose "[$((Get-Date).TimeofDay) END    ] Removing PSSession"
			Remove-PSSession -session $PSsess
		}
		Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
	}
} #end