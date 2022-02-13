<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
	 Created on:   	15/01/2022 17:13
	 Created by:   	Administrator
	 Organization: 	
	 Filename:     	Find-HyperVHost.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

# Ensure that AD management module is available for PS Session
if (!(get-module -name "ActiveDirectory"))
{
	Add-WindowsFeature RSAT-AD-PowerShell | out-null;
	import-module -name "ActiveDirectory" -DisableNameChecking | out-null;
}

function List-hyperVHosts
{
	[cmdletbinding()]
	param (
		[string]$forest
	)
	try
	{
		Import-Module ActiveDirectory -ErrorAction Stop
	}
	catch
	{
		Write-Warning "Failed to import Active Directory module. Cannot continue. Aborting..."
		break;
	}
	
	$domains = (Get-ADForest -Identity $forest).Domains
	foreach ($domain in $domains)
	{
		#"$domain`: `n"
		[string]$dc = (get-addomaincontroller -DomainName $domain -Discover -NextClosestSite).HostName
		try
		{
			$hyperVs = Get-ADObject -Server $dc -Filter 'ObjectClass -eq "serviceConnectionPoint" -and Name -eq "Microsoft Hyper-V"' -ErrorAction Stop;
		}
		catch
		{
			"Failed to query $dc of $domain";
		}
		foreach ($hyperV in $hyperVs)
		{
			$x = $hyperV.DistinguishedName.split(",")
			$HypervDN = $x[1 .. $x.Count] -join ","
			
			if (!($HypervDN -match "CN=LostAndFound"))
			{
				$Comp = Get-ADComputer -Id $HypervDN -Prop *
				$OutputObj = New-Object PSObject -Prop (
					@{
						HyperVName = $Comp.Name
						OSVersion  = $($comp.operatingSystem) #
						IPv4Address = $Comp.IPv4Address
					})
				$OutputObj
			}
		}
	}
}

function listForests
{
	$GLOBAL:forests = Get-ADForest | select Name;
	if ($forests.length -gt 1)
	{
		#for ($i=0;$i -lt $forests.length;$i++){$forests[$i].Name;}
		$forests | %{ $_.Name; }
	}
	else
	{
		$forests.Name;
	}
}

function listHyperVHostsInForests
{
	listForests | %{ List-HyperVHosts $_ }
}

listHyperVHostsInForests

