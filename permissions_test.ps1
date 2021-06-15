<#
.SYNOPSIS
    Test User Permissions
.DESCRIPTION
    Script used to test permissions with a user account.
.EXAMPLE
     PS> Usage is .\permissions_test.ps1 vcenter-fqdn username password
.NOTES
    File Name      : permissions-test.ps1
    Author         : Chris Roberts chrobert@redhat.com
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts
#>

# CLI Arguments for vCenter connection string
$servername=$args[0]
$username=$args[1]
$password=$args[2]

# Connect to the VMware vCenter
function Connect-Vcenter {
    Connect-VIServer -Server $servername -User $username -Password $password | Out-Null
}

# Datacenter Function
function Get-Datacenters {
    Write-Host 'Trying to grab Datacenters' -fore green
    $datacenters = Get-Datacenter
    if ($null -eq $datacenters)
    {
        Write-Host 'Unable to get Datacenters - FAIL' -fore red
    } else {
        Write-Host 'Able to get Datacenters - PASS' -fore green
        Add-Content -Value 'DATACENTERS' -Path .\permissions.txt
        $datacenters | Out-File -Append -FilePath .\permissions.txt
    }
}

# Cluster Function
function Get-Clusters {
    Write-Host 'Trying to grab Clusters' -fore green
    $clusters = Get-Cluster
    if ($null -eq $clusters)
    {
        Write-Host 'Unable to get Clusters - FAIL' -fore red
    } else {
        Write-Host 'Able to get Clusters - PASS' -fore green
        Add-Content -Value 'CLUSTERS' -Path .\permissions.txt
        $clusters | Out-File -Append -FilePath .\permissions.txt
    }
}


# Network Function
function Get-Networks {
    Write-Host 'Trying to grab Networks' -fore green
    $networks = Get-VirtualNetwork
    if ($null -eq $networks)
    {
        Write-Host 'Unable to get Networks - FAIL' -fore red
    } else {
        Write-Host 'Able to get Networks - PASS' -fore green
        Add-Content -Value 'NETWORKS' -Path .\permissions.txt
        $networks | Out-File -Append -FilePath .\permissions.txt
    }
}

# Datastores Function
function Get-Datastores {
    $datastores = Get-Datastore
    Write-Host 'Trying to grab Datastores' -fore green
    if ($null -eq $datastores)
    {
        Write-Host 'Unable to get Datastores - FAIL' -fore red
    } else {
        Write-Host 'Able to get Datastores - PASS' -fore green
        Add-Content -Value 'DATASTORES' -Path .\permissions.txt
        $datastores | Out-File -Append -FilePath .\permissions.txt
    }
}
# Function to get full paths of folders in vSphere environment.
function Get-FolderPath {
	param(
	[parameter(valuefrompipeline = $true,
	position = 0,
	HelpMessage = "Enter a folder")]
	[VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder,
	[switch]$ShowHidden = $false
	)

	begin{
		$excludedNames = "Datacenters","vm","host"
	}

	process{
		$Folder | ForEach-Object{
			$fld = $_.Extensiondata
			$fldType = "yellow"
			if($fld.ChildType -contains "VirtualMachine"){
				$fldType = "blue"
			}
			$path = $fld.Name
			while($fld.Parent){
				$fld = Get-View $fld.Parent
				if((!$ShowHidden -and $excludedNames -notcontains $fld.Name) -or $ShowHidden){
					$path = $fld.Name + "\" + $path
				}
			}
			$row = "" | Select-Object Name,Path,Type
			$row.Name = $_.Name
			$row.Path = $path
			$row.Type = $fldType
			$row
		}
	}
}

# Folder function
function Get-Folders {
    Write-Host 'Trying to grab list of Folders' -fore green
    $folders = Get-Folder | Get-FolderPath
    if ($null -eq $folders) {
        Write-Host 'Unable to get Folders - FAIL' -fore red
    } else {
        Write-Host 'Able to get Folders - PASS' -fore green
        Add-Content -Value 'FOLDERS' -Path .\permissions.txt
        $folders | Out-File -Append -FilePath .\permissions.txt
    }
}

# Resource Pool Function
function Get-Pools {
    Write-Host 'Trying to grab list of Resource Pools' -fore green
    $pools = Get-ResourcePool
    if ($null -eq $pools)
    {
        Write-Host 'Unable to get Resource Pools - FAIL' -fore red
    } else {
        Write-Host 'Able to get Resource Pools - PASS' -fore green
        Add-Content -Value 'POOLS' -Path .\permissions.txt
        $pools | Out-File -Append -FilePath .\permissions.txt
    }
}

# Function to test creating a folder on each datastore for bootdisk prov
function Test-FolderCreate {
    $ds = Get-Datastore | ForEach-Object { $_.Name }
    if ($null -eq $ds) {
        Write-Host 'Unable to find and datastores - SKIPPING' - fore red
    } else {
        foreach ($datastore in $ds) {
            $ds_create = Get-Datastore -Name $datastore
            Write-Host "Creating folder named foreman-test on $datastore" -fore green
            New-PSDrive -Location $ds_create -Name DS -PSProvider VimDatastore -Root "\"
            New-Item -Path DS:\foreman-test -ItemType Directory
            Write-Host 'Directory Created, removing' -fore green
            Remove-Item -Path DS:\foreman-test
            Remove-PSDrive -Name DS -Confirm:$false
        }
        Add-Content -Value 'Folder Test Creation PASS' -Path .\permissions.txt
    }
}

# Function to get the permissions/roles list for every object
function Get-Perms {
    Write-Host 'Getting permissions for all vCenter objects' -fore green
    $si = Get-View ServiceInstance -Server $global:DefaultVIServer

    $authMgr = Get-View -Id $si.Content.AuthorizationManager-Server $global:DefaultVIServer

    $authMgr.RetrieveAllPermissions() |
    Select-Object @{N='Entity';E={Get-View -Id $_.Entity -Property Name -Server $global:DefaultVIServer | Select-Object -ExpandProperty Name}},
        @{N='Entity Type';E={$_.Entity.Type}},
        Principal,
        Propagate,
        @{N='Role';E={$perm = $_; ($authMgr.RoleList | Where-Object{$_.RoleId -eq $perm.RoleId}).Info.Label}} | Format-Table -AutoSize | Out-File -Append -FilePath .\permissions.txt
    $permissions = Get-VIPermission
    $domain = $permissions[0].Principal.Split('\')[0]
    $user = "$domain\$username"
    Write-Host 'Trying to get permissions of objects user has access too' -fore green
    $permissions | Where-Object {$_.Principal –eq $user} | Select-Object Role, Principal, Entity, UID | Out-File -Append -FilePath .\permissions.txt
}

# Lets call our functions to gather info
Connect-Vcenter
Get-Datacenters
Start-Sleep -seconds 3
Get-Clusters
Start-Sleep -seconds 3
Get-Networks
Start-Sleep -seconds 3
Get-Datastores
Start-Sleep -seconds 3
Get-Folders
Start-Sleep -seconds 3
Test-FolderCreate
Start-Sleep -seconds 3
Get-Pools
Start-Sleep -seconds 3
Get-Perms
Write-Host 'Please upload the permissions.txt to the case/email in question' -fore green