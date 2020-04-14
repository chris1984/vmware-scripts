<#
.SYNOPSIS
    Get a list of all VM snapshots by size
.DESCRIPTION
    Get a list of all VM snapshots by size
.NOTES
    File Name      : get-snapshots.ps1
    Author         : Chris Roberts chrobert@redhat.com
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts   
#>

# Connect to the VMware vCenter
Connect-VIServer -Server <vcenterfqdn> -User <adminuser> -Password <adminpassword>

# List Snapshots and dump to table
Get-VM | Get-Snapshot | Select VM,Created,Name,SizeMB | FT

#Now we get a list of VMs, with descriptions, size and the date created. Get all VMs where the snapshots are older than 7 days.

Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-7)} | Select-Object VM, Name, Created, SizeMB
