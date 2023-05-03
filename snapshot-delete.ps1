<#
.SYNOPSIS
    Delete snapshots over a certain amount of days
.DESCRIPTION
    Script used to delete snapshots in a VMware cluster over a certain amount of days
    Replace Line# 18 with your vCenter URL and username/password you are going to authenticate with
    Replace Line# 21 with the cluster you are wanting to query against.
.NOTES
    File Name      : snapshot-delete.ps1
    Author         : Chris Roberts chrobert@redhat.com
    Prerequisite   : PowerShell V2
.LINK
    Script posted at:
    http://github.com/chris1984/vmware-scripts   
#>

# Connect to the VMware vCenter
Connect-VIServer -Server <vcenterfqdn> -User <adminuser> -Password <adminpassword>

# Set your cluster name here
$cluster = "your_cluster_name"

# Set how far back you want to look for snapshots to delete
$days_to_look = -90

# We query the cluster and get all snapshots by the date set on line 24
Get-cluster $cluster | Get-VM | get-snapshot | Where { $_.Created -lt (Get-Date).AddDays($days_to_look)} | Select VM,Name

# We remove the snapshots forcefully (without any confirmation) DANGER!!!!!
remove-snapshot -snapshot $snapshots_to_be_deleted -confirm:$false